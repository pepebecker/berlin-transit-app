//
//  Station.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 24/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

public class Station: NSObject, NSCoding {
    public var id = String()
    public var name = String()
    public var latitude = Double()
    public var longitude = Double()
    public var distance = Int()
    public var lines = [[String:Any]]()
    
    override public init() {
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        if let id = aDecoder.decodeObject(forKey: "id") as? String {
            self.id = id
        }
        
        if let name = aDecoder.decodeObject(forKey: "name") as? String {
            self.name = name
        }
        
        if let latitude = aDecoder.decodeObject(forKey: "latitude") as? Double {
            self.latitude = latitude
        }
        
        if let longitude = aDecoder.decodeObject(forKey: "longitude") as? Double {
            self.longitude = longitude
        }
        
        if let distance = aDecoder.decodeObject(forKey: "distance") as? Int {
            self.distance = distance
        }
        
        if let lines = aDecoder.decodeObject(forKey: "lines") as? [[String:Any]] {
            self.lines = lines
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.longitude, forKey: "longitude")
        aCoder.encode(self.distance, forKey: "distance")
        aCoder.encode(self.lines, forKey: "lines")
    }
}
