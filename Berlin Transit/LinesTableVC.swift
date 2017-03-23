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
    
    // MARK: - Propeties
    
    var station = Station()
    var lines = [Line]()
    var selectedLine = Line()
    
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
            DataKit.addToFavoriteStations(station: self.station)
        } else {
            self.navigationItem.rightBarButtonItem?.title = String.fontAwesomeIcon(name: .heartO)
            DataKit.removeFromFavoriteStations(station: self.station)
        }
    }
    
    func toggleFavorite() {
        if DataKit.isFavoriteStation(station: self.station) {
            self.setFavorite(favorite: false)
        } else {
            self.setFavorite(favorite: true)
        }
    }
    
    func refreshData() {
        if DataKit.isFavoriteStation(station: self.station) {
            self.setFavorite(favorite: true)
        } else {
            self.setFavorite(favorite: false)
        }
        
        DataKit.getLines(id: self.station.id) { _lines, error in
            if let navView = self.navigationController?.view {
                MBProgressHUD.hide(for: navView, animated: true)
            }
            
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                    self.refreshControl?.endRefreshing()
                }))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.lines = DataKit.combineLines(lines: _lines)
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
        
        let line = self.lines[indexPath.row]
        
        cell.icon.image = UIImage(named: line.image)
        
        cell.lineLabel.text = line.name
        
        cell.lineBackgroundColor = UIColor(hex: line.color["bg"]!)
        
        cell.lineTextColor = UIColor(hex: line.color["fg"]!)

        if line.type == "suburban" {
            cell.lineShape = .Round
        } else {
            cell.lineShape = .Rect
        }

        cell.direction1Label.text = line.direction1

        cell.direction2Label.text = line.direction2
        
        if TimeInterval(line.when1).getMinutes() <= 0 {
            cell.time1Label.text = "now"
        } else {
            cell.time1Label.text = "\(TimeInterval(line.when1).getMinutes()) min"
        }
        
        if TimeInterval(line.when2).getMinutes() <= 0 {
            cell.time2Label.text = "now"
        } else {
            cell.time2Label.text = "\(TimeInterval(line.when2).getMinutes()) min"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedLine = self.lines[indexPath.row]
        self.performSegue(withIdentifier: "showDepartures", sender: self)
    }
}
