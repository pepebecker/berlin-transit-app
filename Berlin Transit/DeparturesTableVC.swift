//
//  DeparturesTableVC.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 24/02/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

class DeparturesTableVC: UITableViewController {
    
    var station = [String:Any]()
    var currentLine = String()
    var departures = [[String:Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.departures = self.createTableDeparturesList(deps: self.departures)
        self.tableView.reloadData()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    func refreshData() {
        loadDeparturesData(id: self.station["id"] as! String) { deps in
            DispatchQueue.main.async {
                self.departures = self.createTableDeparturesList(deps: deps)
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    func createTableDeparturesList(deps: [[String:Any]]) -> [[String:Any]] {
        var list = [[String:Any]]()
        
        let sorted = deps.sorted(by: { (dep1, dep2) -> Bool in
            if let when1 = dep1["when"] as? Int, let when2 = dep2["when"] as? Int {
                return when1 < when2
            } else {
                return false
            }
        })
        
        for dep in sorted {
            var departure = [String:Any]()
            if let product = dep["product"] as? [String:Any] {
                if let line = product["line"] as? String {
                    if self.currentLine != line {
                        continue
                    }
                }
            }
            if let direction = dep["direction"] as? String {
                departure["direction"] = direction
            }
            if let when = dep["when"] as? Int {
                let now = NSDate()
                let date = Date(timeIntervalSince1970: TimeInterval(when))
                let calendar = NSCalendar.current
                let minutes = calendar.component(.minute, from: date)
                let nowMinutes = calendar.component(.minute, from: now as Date)
                let time = minutes - nowMinutes
                var timeText = String()
                if (time == 0) {
                    timeText = "now"
                } else {
                    timeText = "\(time) min"
                }
                departure["time"] = timeText
            }
            list.append(departure)
        }
        return list
    }
    
    func loadDeparturesData(id: String, completion: @escaping ([[String:Any]])->Void) {
        if let id = self.station["id"] as? String {
            if let url = URL(string: "https://transport.rest/stations/\(id)/departures") {
                makeRequest(request: URLRequest(url: url)) { deps in
                    if let deps = deps as? [[String:Any]] {
                        completion(deps)
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.departures.count > 0 {
            return 1
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.departures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "departureCell", for: indexPath)

        if let direction = self.departures[indexPath.row]["direction"] as? String {
            cell.textLabel?.text = direction
        }
        
        if let time = self.departures[indexPath.row]["time"] as? String {
            cell.detailTextLabel?.text = time
        }

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
