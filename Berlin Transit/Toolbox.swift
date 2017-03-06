//
//  Toolbox.swift
//  Berlin Public Transport
//
//  Created by Pepe Becker on 13/02/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import Foundation
import UIKit

var currentTask: URLSessionDataTask?

let VBB_LOGOS: [String] = ["bus", "express-bus", "express", "ferry", "metro-bus", "metro-tram",
                           "on-call-bus", "regional", "special-bus", "suburban", "subway", "tram"]

func makeRequest(request: URLRequest, completion: @escaping (Any)->Void) {
    if currentTask != nil {
        currentTask?.cancel()
    }
    
    currentTask = URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            print(error!)
            return
        }
        
        guard let data = data else {
            print("Data is empty")
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            completion(json)
        } catch {
            print("Error serializing JSON: \(error)")
        }
    }
    
    currentTask?.resume()
}

func loadFavorites() -> [[String:Any]] {
    let defaults = UserDefaults.standard
    if let list = defaults.array(forKey: "favoriteStations") as? [[String:Any]] {
        return list
    } else {
        return []
    }
}

func compareStations(station1: [String:Any], station2: [String:Any]) -> Bool {
    if let station1_id = station1["id"] as? String, let station2_id = station2["id"] as? String {
        return station1_id == station2_id
    } else {
        return false
    }
}

func isFavoriteStation(station: [String:Any]) -> Bool {
    for favorite in loadFavorites() {
        if compareStations(station1: station, station2: favorite) {
            return true
        }
    }
    return false
}

func addToFavoriteStations(station: [String:Any]) {
    let defaults = UserDefaults.standard
    
    var favoriteStations = Array(loadFavorites())
    
    if !isFavoriteStation(station: station) {
        favoriteStations.append(station)
        defaults.set(favoriteStations, forKey: "favoriteStations")
    }
}

func removeFromFavoriteStations(station: [String:Any]) {
    let defaults = UserDefaults.standard
    
    var favoriteStations = Array(loadFavorites())
    
    if isFavoriteStation(station: station) {
        if let index = favoriteStations.index(where: { (_station) -> Bool in
            return compareStations(station1: station, station2: _station)
        }) {
            favoriteStations.remove(at: index)
            defaults.set(favoriteStations, forKey: "favoriteStations")
        }
    }
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
        makeRequest(request: URLRequest(url: url), completion: { colors in
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
        var asInt   = NSInteger(self)
        let ago = (asInt < 0)
        
        if (ago) {
            asInt = -asInt
        }
        
        let minutes = (asInt / 60) % 60
//        let hours = ((asInt / 3600))%24
//        
//        minutes += hours * 60
        
        let now = NSDate()
        let calendar = NSCalendar.current
        let nowMinutes = calendar.component(.minute, from: now as Date)
//        let nowHours = calendar.component(.hour, from: now as Date)
//        
//        nowMinutes += nowHours * 60
        
        let time = minutes - nowMinutes
        
        return time
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
