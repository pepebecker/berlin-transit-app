//
//  DataKit.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 21/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit
import CoreLocation

class DataKit: NSObject {
    private class func castDicToStation(stationDict: [String:Any]) -> Station {
        let station = Station()
        
        if let id = stationDict["id"] as? String {
            station.id = id
        }
        
        if let name = stationDict["name"] as? String {
            station.name = name
        }
        
        if let latitude = stationDict["latitude"] as? Double, let longitude = stationDict["longitude"] as? Double {
            station.latitude = latitude
            station.longitude = longitude
        }
        
        if let distance = stationDict["distance"] as? Int {
            station.distance = distance
        }
        
        if let lines = stationDict["lines"] as? [[String:Any]] {
            station.lines = lines
        }
        
        return station
    }
    
    private class func castArrayToStatiosList(stationsArray: [[String:Any]]) -> [Station] {
        var stations = [Station]()
        for stationDict in stationsArray {
            stations.append(self.castDicToStation(stationDict: stationDict))
        }
        return stations
    }
    
    private class func castDictToLine(lineDict: [String:Any]) -> Line {
        let line = Line()
        if let product = lineDict["product"] as? [String:Any] {
            if let name = product["line"] as? String {
                line.name = name
            }
            if let line_type = product["type"] as? [String:Any], let type = line_type["type"] as? String {
                line.type = type
                
                if let isMetro = product["metro"] as? Bool, let isExpress = product["express"] as? Bool {
                    if isMetro {
                        line.image = "metro-\(type)"
                    } else if isExpress {
                        line.image = "express-\(type)"
                    }
                }
                
                if !VBB_LOGOS.contains(line.image) {
                    line.image = type
                }
                
                if let colors = loadColors() {
                    if ["suburban", "subway", "tram"].contains(type) {
                        if let line_color = colors[type]?[line.name] as? [String:String] {
                            if let bg = line_color["bg"], let fg = line_color["fg"] {
                                line.color = ["bg": bg, "fg": fg]
                            }
                        }
                    }
                    else if let color = line_type["color"] as? String {
                        line.color = ["bg": color, "fg": "fff"]
                    }
                    else if let line_color = colors["unknown"] as? [String:String] {
                        if let bg = line_color["bg"], let fg = line_color["fg"] {
                            line.color = ["bg": bg, "fg": fg]
                        }
                    }
                    
                    if let isMetro = product["metro"] as? Bool, isMetro {
                        if let line_color = colors["metro"] as? [String:String] {
                            if let bg = line_color["bg"], let fg = line_color["fg"] {
                                line.color = ["bg": bg, "fg": fg]
                            }
                        }
                    }
                }
            }
        }
        if let direction = lineDict["direction"] as? String {
            line.direction1 = direction
        }
        if let when = lineDict["when"] as? Int {
            line.when1 = when
        }
        
        return line
    }
    
    private class func castArrayToLinesList(linesArray: [[String:Any]]) -> [Line] {
        var lines = [Line]()
        for lineDict in linesArray {
            lines.append(self.castDictToLine(lineDict: lineDict))
        }
        return lines
    }
    
    class func combineLines(lines: [Line]) -> [Line] {
        var list = [Line]()
        for line in lines {
            let index = list.index {
                return $0.name == line.name
            }
            
            if let index = index {
                if list[index].direction2.isEmpty && line.direction1 != list[index].direction1 {
                    list[index].direction2 = line.direction1
                    list[index].when2 = line.when1
                }
            } else {
                list.append(line)
            }
        }
        return list
    }
    
    class func getNearbyStations(location: CLLocation, completion: @escaping ([Station], Error?)->Void) {
        let latitude = Double(location.coordinate.latitude)
        let longitude = Double(location.coordinate.longitude)
        
        if let url = URL(string: "https://transport.rest/stations/nearby?latitude=\(latitude)&longitude=\(longitude)") {
            makeRequest(request: URLRequest(url: url)) { stationsArray, error in
                if let stationsArray = stationsArray as? [[String:Any]] {
                    DispatchQueue.main.async {
                        completion(castArrayToStatiosList(stationsArray: stationsArray), error)
                    }
                } else {
                    print("Error casting stationsArray to [[String:Any]]")
                    completion([], error)
                }
            }
        } else {
            print("Error creating request URL")
            completion([], nil)
        }
    }
    
    class func queryStations(searchText: String, completion: @escaping ([Station], Error?)->Void ) {
        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        if let url = URL(string: "https://transport.rest/stations?completion=true&query=\(query!)") {
            makeRequest(request: URLRequest(url: url)) { (stationsArray, error: Error?) in
                if let stationsArray = stationsArray as? [[String:Any]] {
                    DispatchQueue.main.async {
                        completion(castArrayToStatiosList(stationsArray: stationsArray), error)
                    }
                } else {
                    print("Error casting stationsArray to [[String:Any]]")
                    completion([], error)
                }
            }
        } else {
            print("Error creating request URL")
            completion([], nil)
        }
    }
    
    class func getLines(id: String, duration: Int = 10, completion: @escaping ([Line], Error?)->Void) {
        if let url = URL(string: "https://transport.rest/stations/\(id)/departures?duration=\(duration)") {
            makeRequest(request: URLRequest(url: url)) { linesArray, error in
                if let linesArray = linesArray as? [[String:Any]] {
                    var linesList = self.castArrayToLinesList(linesArray: linesArray)
                    
                    linesList = linesList.sorted(by: { (line1, line2) -> Bool in
                        let types: [String:Int] = [
                            "suburban": 0,
                            "subway": 1,
                            "tram": 2,
                            "metro-tram": 3,
                            "express-tram": 4,
                            "bus": 5,
                            "metro-bus": 6,
                            "express-bus": 7,
                            "regional": 8,
                            "express": 9,
                            "ferry": 10
                        ]
                        
                        if let type1 = types[line1.image], let type2 = types[line2.image] {
                            return type1 < type2
                        }
                        
                        return false
                    })
                    
                    DispatchQueue.main.async {
                        completion(linesList, error)
                    }
                } else {
                    print("Error casting linesArray to [[String:Any]]")
                    completion([], error)
                }
            }
        } else {
            print("Error creating request URL")
            completion([], nil)
        }
    }
    
    // MARK: - Favorites
    class func loadFavorites() -> [Station] {
        let defaults = UserDefaults.standard
        if let favoritesData = defaults.object(forKey: "favoriteStations") as? Data { // NSData
            if let favorites = NSKeyedUnarchiver.unarchiveObject(with: favoritesData) as? [Station] {
                return favorites
            }
        }
        
        return []
    }
    
    
    class func isFavoriteStation(station: Station) -> Bool {
        for favorite in loadFavorites() {
            if station.id == favorite.id {
                return true
            }
        }
        return false
    }
    
    class func addToFavoriteStations(station: Station) {
        let defaults = UserDefaults.standard
        
        var favoriteStations = Array(loadFavorites())
        
        if !isFavoriteStation(station: station) {
            favoriteStations.append(station)
            let favoritesData = NSKeyedArchiver.archivedData(withRootObject: favoriteStations)
            defaults.setValue(favoritesData, forKey: "favoriteStations")
            defaults.synchronize()
        }
    }
    
    class func removeFromFavoriteStations(station: Station) {
        let defaults = UserDefaults.standard

        var favoriteStations = Array(loadFavorites())

        if isFavoriteStation(station: station) {
            if let index = favoriteStations.index(where: { (favorite) -> Bool in
                return station.id == favorite.id
            }) {
                favoriteStations.remove(at: index)
                let favoritesData = NSKeyedArchiver.archivedData(withRootObject: favoriteStations)
                defaults.setValue(favoritesData, forKey: "favoriteStations")
                defaults.synchronize()
            }
        }
    }
    
    class func moveFavoriteStation(fromIndex: Int, toIndex: Int) {
        let defaults = UserDefaults.standard
        
        var favoriteStations = Array(loadFavorites())
        
        if fromIndex > -1 && fromIndex < favoriteStations.count {
            if toIndex > -1 && toIndex < favoriteStations.count {
                let station = favoriteStations[fromIndex]
                favoriteStations.remove(at: fromIndex)
                favoriteStations.insert(station, at: toIndex)
                let favoritesData = NSKeyedArchiver.archivedData(withRootObject: favoriteStations)
                defaults.setValue(favoritesData, forKey: "favoriteStations")
                defaults.synchronize()
            }
        }
    }
}
