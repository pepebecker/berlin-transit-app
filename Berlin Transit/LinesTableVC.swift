//
//  LinesTableVC.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 15/02/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit
import MBProgressHUD

class LinesTableVC: UITableViewController {

    @IBOutlet var favoriteButton: UIBarButtonItem!
    
    var station = [String:Any]()
    var departures = [[String:Any]]()
    var lines = [[String:Any]]()
    var selectedLine = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        self.favoriteButton.target = self
        self.favoriteButton.action = #selector(toggleFavorite)
        self.favoriteButton.tintColor = UIColor(colorLiteralRed: 1, green: 0.7, blue: 0, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    func toggleFavorite() {
        if isFavoriteStation(station: self.station) {
            self.favoriteButton.image = UIImage(named: "star")
            removeFromFavoriteStations(station: self.station)
        } else {
            self.favoriteButton.image = UIImage(named: "starFilled")
            addToFavoriteStations(station: self.station)
        }
    }
    
    func refreshData() {
        if isFavoriteStation(station: self.station) {
            self.favoriteButton.image = UIImage(named: "starFilled")
        } else {
            self.favoriteButton.image = UIImage(named: "star")
        }
        
        if let station_id = self.station["id"] as? String {
            loadDeparturesData(id: station_id) { departures in
                DispatchQueue.main.async {
                    self.departures = departures
                    self.lines.removeAll()
                    for departure in departures {
                        var line = [String:Any]()
                        if let product = departure["product"] as? [String:Any] {
                            if let line_name = product["line"] as? String {
                                line["name"] = line_name
                            }
                            if let line_type = product["type"] as? [String:Any] {
                                if let type = line_type["type"] as? String {
                                    line["type"] = type
                                    
                                    var image_name = String()
                                    if let isMetro = product["metro"] as? Bool, let isExpress = product["express"] as? Bool {
                                        if isMetro {
                                            image_name = "metro-\(type)"
                                        } else if isExpress {
                                            image_name = "express-\(type)"
                                        }
                                    }
                                    if !VBB_LOGOS.contains(image_name) {
                                        image_name = type
                                    }
                                    line["image"] = image_name
                                    
                                    if let colors = loadColors() {
                                        if let line_name = line["name"] as? String {
                                            if ["suburban", "subway", "tram"].contains(type) {
                                                if let line_color = colors[type]?[line_name] as? [String:String] {
                                                    if let bg = line_color["bg"], let fg = line_color["fg"] {
                                                        line["color"] = ["bg": bg, "fg": fg]
                                                    }
                                                }
                                            }
                                            else if let color = line_type["color"] as? String {
                                                line["color"] = ["bg": color, "fg": "fff"]
                                            }
                                            else if let line_color = colors["unknown"] as? [String:String] {
                                                if let bg = line_color["bg"], let fg = line_color["fg"] {
                                                    line["color"] = ["bg": bg, "fg": fg]
                                                }
                                            }
                                        }
                                        
                                        if let isMetro = product["metro"] as? Bool, isMetro {
                                            if let line_color = colors["metro"] as? [String:String] {
                                                if let bg = line_color["bg"], let fg = line_color["fg"] {
                                                    line["color"] = ["bg": bg, "fg": fg]
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if let direction = departure["direction"] as? String {
                            line["direction"] = direction
                        }
                        if let when = departure["when"] as? Int {
//                            let now = NSDate()
//                            let date = Date(timeIntervalSince1970: TimeInterval(when))
//                            let calendar = NSCalendar.current
//                            let minutes = calendar.component(.minute, from: date)
//                            let nowMinutes = calendar.component(.minute, from: now as Date)
//                            let time = minutes - nowMinutes
//                            var timeText = String()
//                            if (time == 0) {
//                                timeText = "now"
//                            } else {
//                                timeText = "\(time) min"
//                            }
//                            line["time"] = timeText
                            let minutes = TimeInterval(when).getMinutes()
                            var timeText = String()
                            if (minutes == 0) {
                                timeText = "now"
                            } else {
                                timeText = "\(minutes) min"
                            }
                            line["time"] = timeText
                        }
                        self.lines.append(line)
                    }
                    
                    self.lines = self.combineLines(lines: self.lines)
                    
                    self.lines = self.lines.sorted(by: { (line1, line2) -> Bool in
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
                        
                        if let type1 = types[line1["image"] as! String] {
                            if let type2 = types[line2["image"] as! String] {
                                return type1 < type2
                            }
                        }
                        
                        return false
                    })
                    
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                    
                    if let navView = self.navigationController?.view {
                        MBProgressHUD.hide(for: navView, animated: true)
                    }
                }
            }
        }
    }
    
    func combineLines(lines: [[String: Any]]) -> [[String: Any]] {
        var list = [[String:Any]]()
        for line in lines {
            let index = list.index {
                if let name1 = $0["name"] as? String, let name2 = line["name"] as? String {
                    return name1 == name2
                } else {
                    return false
                }
            }
            
            if let index = index {
                if list[index]["direction2"] == nil && line["direction"] as! String != list[index]["direction1"] as! String {
                    list[index]["direction2"] = line["direction"] as! String
                    list[index]["time2"] = line["time"] as! String
                }
            } else {
                var newLine = line
                newLine["direction1"] = line["direction"] as! String
                newLine["time1"] = line["time"] as! String
                list.append(newLine)
            }
        }
        return list
    }

    func loadDeparturesData(id: String, completion: @escaping ([[String:Any]])->Void) {
        if let id = self.station["id"] as? String {
            if let url = URL(string: "https://transport.rest/stations/\(id)/departures") {
                makeRequest(request: URLRequest(url: url)) { departures in
                    if let departures = departures as? [[String:Any]] {
                        completion(departures)
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.lines.count > 0 {
            return 1
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lines.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lineCell", for: indexPath) as! LineCell
        
        if let image_name = self.lines[indexPath.row]["image"] as? String {
            cell.icon.image = UIImage(named: image_name)
        }
        
        if let line_name = self.lines[indexPath.row]["name"] as? String {
            cell.lineLabel.text = line_name
        } else {
            cell.lineLabel.text = ""
        }
        
        if let color = self.lines[indexPath.row]["color"] as? [String:String] {
            if let bg = color["bg"] {
                cell.lineRect.backgroundColor = UIColor(hex: bg)
            }
            
            if let fg = color["fg"] {
                cell.lineLabel?.textColor = UIColor(hex: fg)
            }
        } else {
            print("Could not parse color")
        }
        
        if let type = self.lines[indexPath.row]["type"] as? String {
            if type == "suburban" {
                cell.lineShape = .Roud
            } else {
                cell.lineShape = .Rect
            }
        }
        
        if let direction1 = self.lines[indexPath.row]["direction1"] as? String {
            cell.direction1Label.text = direction1
        } else {
            cell.direction1Label.text = ""
        }
        
        if let direction2 = self.lines[indexPath.row]["direction2"] as? String {
            cell.direction2Label.text = direction2
        } else {
            cell.direction2Label.text = ""
        }
        
        if let time1 = self.lines[indexPath.row]["time1"] as? String {
            cell.time1Label.text = time1
        } else {
            cell.time1Label.text = ""
        }
        
        if let time2 = self.lines[indexPath.row]["time2"] as? String {
            cell.time2Label.text = time2
        } else {
            cell.time2Label.text = ""
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let name = self.lines[indexPath.row]["name"] as? String {
            self.selectedLine = name
        }
        self.performSegue(withIdentifier: "showDepartures", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDepartures" {
            let departuresTableVC = segue.destination as! DeparturesTableVC
            departuresTableVC.title = self.selectedLine
            departuresTableVC.station = self.station
            departuresTableVC.currentLine = self.selectedLine
            departuresTableVC.departures = self.departures
        }
    }
}
