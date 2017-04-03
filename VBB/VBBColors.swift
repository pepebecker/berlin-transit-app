//
//  VBBColors.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 24/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

public class VBBColors: NSObject {
    public class func downloadColors() {
        if let url = URL(string: "https://cdn.rawgit.com/juliuste/vbb-util/master/lines/colors.json") {
            VBBUtils.makeRequest(url: url, completion: { colors, error in
                if let colors = colors as? [String:Any] {
                    let defaults = UserDefaults.standard
                    defaults.set(colors, forKey: "colors")
                    defaults.set(true, forKey: "colorsUpToDate")
                } else {
                    print("Could not parse colors")
                    print(colors)
                }
            })
        }
    }
    
    public class func loadColors() -> [String:[String:Any]]? {
        let defaults = UserDefaults.standard
        
        if let upToDate = defaults.value(forKey: "colorsUpToDate") as? Bool {
            if !upToDate {
                downloadColors()
            }
        } else {
            print("Key 'colorsUpToDate' doesn't exist")
            defaults.set(false, forKey: "colorsUpToDate")
            return loadColors()
        }
        
        if let colors = defaults.value(forKey: "colors") as? [String:[String:Any]] {
            return colors
        } else {
            print("Key 'colors' doesn't exist")
            downloadColors()
        }
        
        return nil
    }
    
    public class func color(hex: String) -> UIColor {
        var modifiedHex = hex.replacingOccurrences(of: "#", with: "")
        
        if modifiedHex.characters.count == 3 {
            var newHex = String()
            for char in modifiedHex.characters {
                newHex.append(contentsOf: [char, char])
            }
            modifiedHex = newHex
        }
        
        let scanner = Scanner(string: modifiedHex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        return UIColor.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
    public class func getHex(color: UIColor) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
}
