//
//  DeparturesTableVC.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 24/02/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit
import VBB

class DeparturesTableVC: UITableViewController {
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var lineLabel: UILabel!
    
    var station = Station()
    var currentLine = Line()
    var departures = [[String:Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lineView = LineView()
        lineView.adjustConstraints = false
        lineView.line = self.currentLine
        self.navigationItem.titleView = lineView
        
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
        VBBStations.getLines(id: self.station.id, duration: 60) { lines, error in
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "departureCell", for: indexPath) as! DepartureCell
        
        if let direction = self.departures[indexPath.row]["direction"] as? String {
            cell.title = direction
        }

        if let time = self.departures[indexPath.row]["time"] as? Int {
            let minutes = VBBUtils.getMinutes(timestamp: time)
            
            var text = "\(minutes) min"
            if minutes <= 0 {
                text = "now"
            }
            
            cell.detail = text
        }

        return cell
    }

}
