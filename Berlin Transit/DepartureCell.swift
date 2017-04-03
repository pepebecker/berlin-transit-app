//
//  DepartureCell.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 28/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

class DepartureCell: UITableViewCell {

    @IBOutlet private var directionLabel: UILabel!
    @IBOutlet private var timeLabel: UILabel!
    
    var title: String?
    var detail: String?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.directionLabel.text = self.title
        self.timeLabel.text = self.detail
    }

}
