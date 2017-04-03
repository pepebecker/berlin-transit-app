//
//  Toolbox.swift
//  Berlin Public Transport
//
//  Created by Pepe Becker on 13/02/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

var activeHudView = UIView()

extension MBProgressHUD {
    
    class func hideActive() {
        self.hide(for: activeHudView, animated: true)
    }
    
    class func showWithCancelAdded(to: UIView, animated: Bool) {
        let hud = self.showAdded(to: to)
        hud.detailsLabel.text = "Tap to cancel"
        hud.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideActive)))
    }
    
    class func showAdded(to: UIView) -> MBProgressHUD {
        activeHudView = to
        return self.showAdded(to: to, animated: true)
    }
}
