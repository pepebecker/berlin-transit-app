//
//  VBBLogos.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 24/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

public class VBBLogos: NSObject {
    static let logoNames = ["bus", "express-bus", "express", "ferry", "metro-bus", "metro-tram",
                               "on-call-bus", "regional", "special-bus", "suburban", "subway", "tram"]
    
    public class func hasLogo(name: String) -> Bool {
        return self.logoNames.contains(name)
    }
    
    public class func getLogo(name: String) -> UIImage? {
        if self.hasLogo(name: name) {
            return UIImage(named: name)
        } else {
            return nil
        }
    }
}
