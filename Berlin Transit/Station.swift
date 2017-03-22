//
//  Station.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 21/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

@objc class Station: NSObject {
    var id = String()
    var name = String()
    var latitude = Double()
    var longitude = Double()
    var distance = Int()
    var lines = [[String:Any]]()
}
