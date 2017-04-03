//
//  VBBFavorites.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 24/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

public class VBBFavorites: NSObject {
    public class func loadFavorites() -> [Station] {
        let defaults = UserDefaults.standard
        if let favoritesData = defaults.object(forKey: "favoriteStations") as? Data {
            NSKeyedUnarchiver.setClass(Station.self, forClassName: "Station")
            if let favorites = NSKeyedUnarchiver.unarchiveObject(with: favoritesData) as? [Station] {
                return favorites
            }
        }
        
        return []
    }
    
    
    public class func isFavoriteStation(station: Station) -> Bool {
        for favorite in loadFavorites() {
            if station.id == favorite.id {
                return true
            }
        }
        return false
    }
    
    public class func addToFavoriteStations(station: Station) {
        let defaults = UserDefaults.standard
        
        var favoriteStations = Array(loadFavorites())
        
        if !isFavoriteStation(station: station) {
            favoriteStations.append(station)
            NSKeyedArchiver.setClassName("Station", for: Station.self)
            let favoritesData = NSKeyedArchiver.archivedData(withRootObject: favoriteStations)
            defaults.setValue(favoritesData, forKey: "favoriteStations")
            defaults.synchronize()
        }
    }
    
    public class func removeFromFavoriteStations(station: Station) {
        let defaults = UserDefaults.standard
        
        var favoriteStations = Array(loadFavorites())
        
        if isFavoriteStation(station: station) {
            if let index = favoriteStations.index(where: { (favorite) -> Bool in
                return station.id == favorite.id
            }) {
                favoriteStations.remove(at: index)
                NSKeyedArchiver.setClassName("Station", for: Station.self)
                let favoritesData = NSKeyedArchiver.archivedData(withRootObject: favoriteStations)
                defaults.setValue(favoritesData, forKey: "favoriteStations")
                defaults.synchronize()
            }
        }
    }
    
    public class func moveFavoriteStation(fromIndex: Int, toIndex: Int) {
        let defaults = UserDefaults.standard
        
        var favoriteStations = Array(loadFavorites())
        
        if fromIndex > -1 && fromIndex < favoriteStations.count {
            if toIndex > -1 && toIndex < favoriteStations.count {
                let station = favoriteStations[fromIndex]
                favoriteStations.remove(at: fromIndex)
                favoriteStations.insert(station, at: toIndex)
                NSKeyedArchiver.setClassName("Station", for: Station.self)
                let favoritesData = NSKeyedArchiver.archivedData(withRootObject: favoriteStations)
                defaults.setValue(favoritesData, forKey: "favoriteStations")
                defaults.synchronize()
            }
        }
    }
}
