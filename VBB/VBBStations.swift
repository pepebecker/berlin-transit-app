//
//  VBBStations.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 24/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit
import CoreLocation

public class VBBStations: NSObject {
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
                
                if !VBBLogos.hasLogo(name: line.image) {
                    line.image = type
                }
                
                // Colors
                
                if let type_color = line_type["color"] as? String {
                    line.color["logo"] = type_color
                    line.color["bg"] = type_color
                    line.color["fg"] = "FFFFFF"
                }
                
                if let colors = VBBColors.loadColors() {
                    
                    if let isMetro = product["metro"] as? Bool, let isExpress = product["express"] as? Bool, isMetro, !isExpress {
                        if let line_color = colors["metro"] as? [String:String] {
                            if let bg = line_color["bg"], let fg = line_color["fg"] {
                                line.color["bg"] = bg
                                line.color["fg"] = fg
                            }
                        }
                    }
                    
                    if let line_color = colors[type]?[line.name] as? [String:String] {
                        if let bg = line_color["bg"], let fg = line_color["fg"] {
                            line.color["bg"] = bg
                            line.color["fg"] = fg
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
    
    public class func combineLines(lines: [Line]) -> [Line] {
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
    
    public class func getNearbyStations(location: CLLocation, completion: @escaping ([Station], Error?)->Void) {
        let latitude = Double(location.coordinate.latitude)
        let longitude = Double(location.coordinate.longitude)
        
        if let url = URL(string: "\(VBBUtils.getHostname())/stations/nearby?latitude=\(latitude)&longitude=\(longitude)") {
            VBBUtils.makeRequest(url: url) { stationsArray, error in
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
    
    public class func queryStations(searchText: String, completion: @escaping ([Station], Error?)->Void ) {
        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        if let url = URL(string: "\(VBBUtils.getHostname())/stations?completion=true&query=\(query!)") {
            VBBUtils.makeRequest(url: url) { (stationsArray, error: Error?) in
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
    
    public class func getLines(id: String, duration: Int = 10, when: Date = Date(), completion: @escaping ([Line], Error?)->Void) {
        if let url = URL(string: "\(VBBUtils.getHostname())/stations/\(id)/departures?duration=\(duration)&when=\(VBBUtils.getTimestamp(date: when))") {
            VBBUtils.makeRequest(url: url) { linesArray, error in
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
    
    public class func getRoutes(from: String, to: String, when: Date = Date(), completion: @escaping ([[String:Any]])->Void) {
        if let url = URL(string: "\(VBBUtils.getHostname())/routes?from=\(from)&to=\(to)&when=\(VBBUtils.getTimestamp(date: when))") {
            VBBUtils.makeRequest(url: url, completion: { routes, error in
                if let routes = routes as? [[String:Any]] {
                    completion(routes)
                } else {
                    print("Failed to cast routes")
                }
            })
        } else {
            print("Failed to create request url")
        }
    }
}
