//
//  RoutePlaner.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 23/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

class RoutePlaner: UITableViewController {

    @IBOutlet weak var depatureCell: UITableViewCell!
    @IBOutlet weak var arrivalCell: UITableViewCell!
    @IBOutlet weak var timeCell: UITableViewCell!
    @IBOutlet weak var searchCell: UITableViewCell!
    
    var stationPicker = StationPicker()
    
    var origin: Station?
    var destination: Station?
    
    var selectingDestination = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stationPicker.pickerDelegate = self
        self.stationPicker.canCancel = true
        self.stationPicker.autoFocus = true
        self.stationPicker.resetOnViewDisappear = true
    }
    
    func selectOrigin() {
        self.selectingDestination = false
        self.stationPicker.title = "From"
        self.present(self.stationPicker, animated: true, completion: nil)
    }
    
    func selectDestination() {
        self.selectingDestination = true
        self.stationPicker.title = "To"
        self.present(self.stationPicker, animated: true, completion: nil)
    }
}

extension RoutePlaner {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                selectOrigin()
                break
            case 1:
                selectDestination()
                break
            default:
                print("Not supported yet")
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.timeCell.detailTextLabel?.text = "Not supported yet"
            }
        }
        
        if indexPath.section == 1 {
            self.performSegue(withIdentifier: "showRoutes", sender: self)
        }
    }
}

extension RoutePlaner {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRoutes" {
            if let routesTableVC = segue.destination as? AvailableRoutesTableVC {
                routesTableVC.origin = self.origin
                routesTableVC.destination = self.destination
            }
        }
    }
}

extension RoutePlaner: StationPickerDelegate {
    func stationPicker(didPickStation station: Station, sender: StationPicker) {
        sender.dismiss(animated: true, completion: nil)
        
        if self.selectingDestination {
            self.destination = station
            self.arrivalCell.detailTextLabel?.text = station.name
        } else {
            self.origin = station
            self.depatureCell.detailTextLabel?.text = station.name
        }
    }
}
