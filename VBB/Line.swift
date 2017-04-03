//
//  Line.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 24/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

public class Line: NSObject {
    public var name = String()
    public var type = String()
    public var image = String()
    public var direction1 = String()
    public var direction2 = String()
    public var when1 = Int()
    public var when2 = Int()
    public var color = ["fg": String(), "bg": String(), "logo": String()]
}
