//
//  FavoritesTableVC.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 24/02/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit
import MBProgressHUD

class FavoritesTableVC: UITableViewController {
    
    var stations = [Station]()
    var selectedStation = Station()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let attributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 20)] as [String: Any]
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)
        self.navigationItem.leftBarButtonItem?.title = String.fontAwesomeIcon(name: .bars)
        self.navigationItem.leftBarButtonItem?.target = self
        self.navigationItem.leftBarButtonItem?.action = #selector(reorderButtonPressed)
        
        self.stations = DataKit.loadFavorites()
        self.tableView.reloadData()
    }
    
    func reorderButtonPressed() {
        if self.tableView.isEditing {
            self.tableView.setEditing(false, animated: true)
        } else {
            self.tableView.setEditing(true, animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.stations.count > 0 {
            return 1
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell", for: indexPath)

        cell.textLabel?.text = self.stations[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let station = self.stations[sourceIndexPath.row]
        self.stations.remove(at: sourceIndexPath.row)
        self.stations.insert(station, at: destinationIndexPath.row)
        DataKit.moveFavoriteStation(fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedStation = self.stations[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let linesTableVC = storyboard.instantiateViewController(withIdentifier: "linesTable") as? LinesTableVC {
            linesTableVC.title = self.selectedStation.name
            linesTableVC.station = self.selectedStation
            if let navView = self.navigationController?.view {
                MBProgressHUD.showAdded(to: navView, animated: true)
            }
            self.navigationController?.pushViewController(linesTableVC, animated: true)
        }
    }
}





