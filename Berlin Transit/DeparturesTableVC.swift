//
//  DeparturesTableVC.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 24/02/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

class DeparturesTableVC: UITableViewController {
    
    var station = Station()
    var currentLine = Line()
    var departures = [[String:Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        
        self.tableView.reloadData()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshControl?.beginRefreshing()
        self.tableView.setContentOffset(CGPoint(x: 0, y: -(refreshControl?.frame.size.height)!), animated: true)
        self.refreshData()
    }
    
    func refreshData() {
        DataKit.getLines(id: self.station.id, duration: 60) { lines, error in
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.departures.removeAll()
            for line in lines {
                if line.name == self.currentLine.name {
                    self.departures.append(["direction": line.direction1, "time": line.when1])
                }
            }
            
            self.departures = self.departures.sorted(by: { (dep1, dep2) -> Bool in
                if let time1 = dep1["time"] as? Int, let time2 = dep2["time"] as? Int {
                    return time1 < time2
                } else {
                    return false
                }
            })
            
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.departures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "departureCell", for: indexPath)
        
        if let direction = self.departures[indexPath.row]["direction"] as? String {
            cell.textLabel?.text = direction
        }

        if let time = self.departures[indexPath.row]["time"] as? Int {
            let minutes = TimeInterval(time).getMinutes()
            
            var text = "\(minutes) min"
            if minutes <= 0 {
                text = "now"
            }
            
            cell.detailTextLabel?.text = text
        }

        return cell
    }

}
