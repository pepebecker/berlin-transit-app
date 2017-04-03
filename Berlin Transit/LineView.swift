//
//  LineView.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 28/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit
import VBB

class LineView: UIView {
    
    var label = UILabel()
    var padding = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    var line: Line? {
        didSet {
            if let line = self.line {
                self.label.text = line.name
                self.label.textColor = VBBColors.color(hex: line.color["fg"]!)
                self.backgroundColor = VBBColors.color(hex: line.color["bg"]!)
                self.adjustSize()
            }
        }
    }
    var fontSize: CGFloat = 17 {
        didSet {
            self.label.font = UIFont(name: self.label.font.fontName, size: self.fontSize)
            self.adjustSize()
        }
    }
    var adjustConstraints = true

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    func commonInit() {
        self.label.font = UIFont(name: "TransitFront-Negativ", size: 22)
        self.label.textAlignment = .center
        self.clipsToBounds = true
        self.label.textColor = UIColor.lightText
        self.label.text = "NONE"
        self.backgroundColor = UIColor.darkGray
        self.addSubview(self.label)
        self.adjustSize()
    }
    
    func adjustSize() {
        if let line = self.line {
            if ["suburban", "bus", "ferry"].contains(line.type) {
                self.padding.left = self.fontSize * 0.4
                self.padding.right = self.fontSize * 0.4
            } else {
                self.padding.left = self.fontSize * 0.2
                self.padding.right = self.fontSize * 0.2
            }
        }
        
        self.label.sizeToFit()
        let width = self.label.frame.width + self.padding.left + self.padding.right
        let height = self.label.frame.height + self.padding.top + self.padding.bottom
        self.frame.size = CGSize(width: width, height: height)
        
        self.removeConstraints(self.constraints)
        
        if self.adjustConstraints {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
            self.heightAnchor.constraint(equalToConstant: height).isActive = true            
        }
        
        self.label.frame.origin = CGPoint(x: self.padding.left, y: self.padding.top)
        self.adjustCornerRadius()
    }
    
    func adjustCornerRadius() {
        if let line = self.line {
            if ["suburban", "bus", "ferry"].contains(line.type) {
                self.layer.cornerRadius = self.frame.height / 2
            } else {
                self.layer.cornerRadius = 3
            }
        }
    }
    
    deinit {
        self.label.removeFromSuperview()
    }
}
