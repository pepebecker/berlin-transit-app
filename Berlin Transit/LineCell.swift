//
//  LineCell.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 17/02/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

class LineCell: UITableViewCell {

    @IBOutlet var lineView: LineView!
    @IBOutlet var direction1Label: UILabel!
    @IBOutlet var direction2Label: UILabel!
    @IBOutlet var time1Label: UILabel!
    @IBOutlet var time2Label: UILabel!
    @IBOutlet weak var centerDirection1Label: NSLayoutConstraint!
    
    var lineViewColor: UIColor = .darkGray
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (self.lineView.label.text?.isEmpty)! {
            self.lineView.isHidden = true
        } else {
            self.lineView.isHidden = false
        }
        
        self.lineView.backgroundColor = self.lineViewColor
        
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
