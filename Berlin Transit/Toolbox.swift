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

var currentTask: URLSessionDataTask?

let VBB_LOGOS: [String] = ["bus", "express-bus", "express", "ferry", "metro-bus", "metro-tram",
                           "on-call-bus", "regional", "special-bus", "suburban", "subway", "tram"]

func makeRequest(request: URLRequest, completion: @escaping (Any, Error?)->Void) {
    if currentTask != nil {
        currentTask?.cancel()
    }
    
    currentTask = URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            print("Error sending request: \(error!.localizedDescription)")
            completion([], error)
            return
        }
        
        guard let data = data else {
            print("Data is empty")
            completion([], error)
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            completion(json, nil)
        } catch {
            print("Error serializing JSON: \(error)")
        }
    }
    
    currentTask?.resume()
}

func loadFavorites() -> [Station] {
    let defaults = UserDefaults.standard
    if let list = defaults.array(forKey: "favoriteStations") as? [Station] {
        return list
    } else {
        return []
    }
}


func isFavoriteStation(station: Station) -> Bool {
    for favorite in loadFavorites() {
        if station.id == favorite.id {
           return true
        }
    }
    return false
}

func addToFavoriteStations(station: Station) {
//    let defaults = UserDefaults.standard
//    
//    var favoriteStations = Array(loadFavorites())
//    
//    if !isFavoriteStation(station: station) {
//        favoriteStations.append(station)
//        defaults.set(favoriteStations, forKey: "favoriteStations")
//    }
}

func removeFromFavoriteStations(station: Station) {
//    let defaults = UserDefaults.standard
//    
//    var favoriteStations = Array(loadFavorites())
//    
//    if isFavoriteStation(station: station) {
//        if let index = favoriteStations.index(where: { (_station) -> Bool in
//            return compareStations(station1: station, station2: _station)
//        }) {
//            favoriteStations.remove(at: index)
//            defaults.set(favoriteStations, forKey: "favoriteStations")
//        }
//    }
}

func moveFavoriteStation(fromIndex: Int, toIndex: Int) {
    let defaults = UserDefaults.standard
    
    var favoriteStations = Array(loadFavorites())
    
    if fromIndex > -1 && fromIndex < favoriteStations.count {
        if toIndex > -1 && toIndex < favoriteStations.count {
            let station = favoriteStations[fromIndex]
            favoriteStations.remove(at: fromIndex)
            favoriteStations.insert(station, at: toIndex)
            defaults.set(favoriteStations, forKey: "favoriteStations")
        }
    }
}

func downloadColors() {
    if let url = URL(string: "https://cdn.rawgit.com/derhuerst/vbb-util/f172b1f/lines/colors.json") {
        makeRequest(request: URLRequest(url: url), completion: { colors, error in
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

func loadColors() -> [String:[String:Any]]? {
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

extension TimeInterval {
    func getMinutes() -> Int {
        let futureTime = Date(timeIntervalSince1970: self)
        let seconds = futureTime.timeIntervalSinceNow
        
        let minutes = Int(Double(seconds / 60).rounded(.up))
        
        return minutes
    }
}

extension UIColor {
    var toHexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
    }
    
    convenience init(hex: String) {
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
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

var activeHudView = UIView()

extension MBProgressHUD {
    class func tapHide() {
        self.hide(for: activeHudView, animated: true)
    }
    
    class func showWithCancelAdded(to: UIView, animated: Bool) {
        activeHudView = to
        let hud = self.showAdded(to: to, animated: animated)
        hud.detailsLabel.text = "Tap to cancel"
        hud.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHide)))
    }
}
