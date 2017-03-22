//
//  LineCell.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 17/02/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

class LineCell: UITableViewCell {
    
    enum LineShape {
        case Round
        case Rect
    }

    @IBOutlet var icon: UIImageView!
    @IBOutlet var lineRect: UIView!
    @IBOutlet var lineLabel: UILabel!
    @IBOutlet var direction1Label: UILabel!
    @IBOutlet var direction2Label: UILabel!
    @IBOutlet var time1Label: UILabel!
    @IBOutlet var time2Label: UILabel!
    @IBOutlet weak var centerDirection1Label: NSLayoutConstraint!
    
    var lineShape: LineShape = .Rect
    var lineTextColor: UIColor = .darkText
    var lineBackgroundColor: UIColor = .lightGray
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (self.lineLabel.text?.isEmpty)! {
            self.lineLabel.isHidden = true
            self.lineRect.isHidden = true
        } else {
            if self.lineShape == .Rect {
                self.lineRect.layer.cornerRadius = 3
            } else {
                self.lineRect.layer.cornerRadius = self.lineRect.frame.height / 2
            }
            self.lineRect.backgroundColor = self.lineBackgroundColor
            self.lineLabel.textColor = self.lineTextColor
            self.lineLabel.isHidden = false
            self.lineRect.isHidden = false
        }
        
        if (self.direction2Label.text?.isEmpty)! {
            self.direction2Label.isHidden = true
            self.time2Label.isHidden = true
            self.centerDirection1Label.priority = UILayoutPriorityDefaultHigh
        } else {
            self.direction2Label.isHidden = false
            self.time2Label.isHidden = false
            self.centerDirection1Label.priority = UILayoutPriorityDefaultLow
        }
    }
}
