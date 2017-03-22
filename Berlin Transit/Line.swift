//
//  Line.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 22/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

@objc class Line: NSObject {
    var name = String()
    var type = String()
    var image = String()
    var direction1 = String()
    var direction2 = String()
    var when1 = Int()
    var when2 = Int()
    var color = ["fg": String(), "bg": String()]
}
