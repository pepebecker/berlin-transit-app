//
//  LineHeaderView.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 28/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

class LineHeaderView: UIView {
    
    var image: UIImage?
    var title: String?
    var textColor: UIColor = .white
    
    private let imageView = UIImageView()
    private let label = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var offset: CGFloat = 8
        
        if let image = self.image {
            self.imageView.image = image
            self.imageView.frame.origin = CGPoint(x: offset, y: 0)
            self.imageView.frame.size = CGSize(width: self.frame.height, height: self.frame.height)
            self.addSubview(self.imageView)
            offset += self.imageView.frame.width + 8
        }
        
        self.label.font = UIFont(name: "TransitFront-Negativ", size: 14)
        self.label.textColor = self.textColor
        self.label.text = self.title
        self.label.frame.origin = CGPoint(x: offset, y: 0)
        self.label.frame.size = CGSize(width: self.frame.size.width / 2 - offset, height: self.frame.size.height)
        self.addSubview(self.label)
    }

}
