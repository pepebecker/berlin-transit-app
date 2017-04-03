//
//  LinesTableVC.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 15/02/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit
import VBB
//import MBProgressHUD

class LinesTableVC: UITableViewController {
    
    // MARK: - Propeties
    
    var station = Station()
    var selectedLine = Line()
    
    // 7 Lines: Suburban, Subway, Tram, Bus, Express, Regional, Ferry
    var lineGroups: [[Line]] = [[Line](), [Line](), [Line](), [Line](), [Line](), [Line](), [Line]()]
    let lineTitles = ["Suburban", "Subway", "Tram", "Bus", "Regional", "Express", "Ferry"]
    
    // MARK: - Delgate Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        self.navigationItem.rightBarButtonItem?.target = self
        self.navigationItem.rightBarButtonItem?.action = #selector(toggleFavorite)
        let attributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 24)] as [String: Any]
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.red
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - Helper Methods
    
    func setFavorite(favorite: Bool) {
        if favorite {
            self.navigationItem.rightBarButtonItem?.title = String.fontAwesomeIcon(name: .heart)
            VBBFavorites.addToFavoriteStations(station: self.station)
        } else {
            self.navigationItem.rightBarButtonItem?.title = String.fontAwesomeIcon(name: .heartO)
            VBBFavorites.removeFromFavoriteStations(station: self.station)
        }
    }
    
    func toggleFavorite() {
        if VBBFavorites.isFavoriteStation(station: self.station) {
            self.setFavorite(favorite: false)
        } else {
            self.setFavorite(favorite: true)
        }
    }
    
    func refreshData() {
        if VBBFavorites.isFavoriteStation(station: self.station) {
            self.setFavorite(favorite: true)
        } else {
            self.setFavorite(favorite: false)
        }
        
        VBBStations.getLines(id: self.station.id) { _lines, error in
//            MBProgressHUD.hideActive()
            
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                    self.refreshControl?.endRefreshing()
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.lineGroups.removeAll()
            for _ in 1...7 {
                self.lineGroups.append([Line]())
            }
            
            let lines = VBBStations.combineLines(lines: _lines)
            
            let convert = ["suburban": 0, "subway": 1, "tram": 2, "bus": 3, "regional": 4, "dont-include-express": 5, "ferry": 6]
            
            for line in lines {
                if let index = convert[line.type] {
                    self.lineGroups[index].append(line)
                }
            }
            
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - Navigation
extension LinesTableVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDepartures" {
            if let departuresTableVC = segue.destination as? DeparturesTableVC {
                departuresTableVC.title = self.selectedLine.name
                departuresTableVC.station = self.station
                departuresTableVC.currentLine = self.selectedLine
            }
        }
    }
}

// MARK: - Table view data source
extension LinesTableVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.lineGroups.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lineGroups[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.lineGroups[section].count > 0 {
            return 26
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: LineHeaderView? = LineHeaderView()
        
        let line = self.lineGroups[section][0]
        
        view?.image = VBBLogos.getLogo(name: line.type)
        
        view?.title = self.lineTitles[section]
        
        if let color = line.color["logo"] {
            view?.backgroundColor =  VBBColors.color(hex: color)
        }
        
        if section == 5 {
            view?.textColor = .black
        } else {
            view?.textColor = .white
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "lineCell", for: indexPath) as! LineCell
        
        let line = self.lineGroups[indexPath.section][indexPath.row]
        
        cell.lineView.line = line
        cell.lineView.fontSize = 15
        cell.lineViewColor = VBBColors.color(hex: line.color["bg"]!)

        cell.direction1Label.text = line.direction1

        cell.direction2Label.text = line.direction2
        
        if VBBUtils.getMinutes(timestamp: line.when1) <= 0 {
            cell.time1Label.text = "now"
        } else {
            cell.time1Label.text = "\(VBBUtils.getMinutes(timestamp: line.when1)) min"
        }
        
        if VBBUtils.getMinutes(timestamp: line.when2) <= 0 {
            cell.time2Label.text = "now"
        } else {
            cell.time2Label.text = "\(VBBUtils.getMinutes(interval: TimeInterval(line.when2))) min"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedLine = self.lineGroups[indexPath.section][indexPath.row]
        self.performSegue(withIdentifier: "showDepartures", sender: self)
    }
}
