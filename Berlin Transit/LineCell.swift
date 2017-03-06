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
        case Roud
        case Rect
    }

    @IBOutlet var icon: UIImageView!
    @IBOutlet var lineRect: UIView!
    @IBOutlet var lineLabel: UILabel!
    @IBOutlet var direction1Label: UILabel!
    @IBOutlet var direction2Label: UILabel!
    @IBOutlet var time1Label: UILabel!
    @IBOutlet var time2Label: UILabel!
    
    var lineShape: LineShape = .Rect
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
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
        }
        
        if (self.direction2Label.text?.isEmpty)! {
            self.direction2Label.isHidden = true
            self.direction1Label.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        }
        
        if (self.time2Label.text?.isEmpty)! {
            self.time2Label.isHidden = true
            self.time1Label.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
