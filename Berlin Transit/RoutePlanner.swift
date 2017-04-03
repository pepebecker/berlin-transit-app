//
//  RoutePlanner.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 23/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit
import VBB

class RoutePlanner: UITableViewController {

    @IBOutlet weak var depatureCell: UITableViewCell!
    @IBOutlet weak var arrivalCell: UITableViewCell!
    @IBOutlet weak var timeCell: UITableViewCell!
    @IBOutlet weak var searchCell: UITableViewCell!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    var stationPicker = StationPicker()
    
    var origin: Station?
    var destination: Station?
    
    var selectingDestination = false
    var timeCellSelected = false
    
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

extension RoutePlanner {
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.timeCellSelected {
                return 4
            } else {
                return 3
            }
        default:
            return 1
        }
    }
    */
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                selectOrigin()
                break
            case 1:
                selectDestination()
                break
            case 2:
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.timeCellSelected = true
                let index = IndexPath(row: 1, section: 0)
                self.tableView.insertRows(at: [index], with: .automatic)
                break
            default:
                print("Not supported yet")
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        if indexPath.section == 1 {
            self.performSegue(withIdentifier: "showRoutes", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 3 {
            if self.timeCellSelected {
                return 128
            } else {
                return 0
            }
        } else {
            return 44;
        }
    }
}

extension RoutePlanner {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRoutes" {
            if let routesTableVC = segue.destination as? AvailableRoutesTableVC {
                routesTableVC.origin = self.origin
                routesTableVC.destination = self.destination
            }
        }
    }
}

extension RoutePlanner: StationPickerDelegate {
    func stationPicker(didPickStation station: Station, sender: StationPicker) {
        sender.dismiss(animated: true, completion: nil)
        
        if self.selectingDestination {
            self.destination = station
            self.arrivalCell.detailTextLabel?.text = station.name
            self.arrivalCell.detailTextLabel?.textColor = UIColor.darkText
        } else {
            self.origin = station
            self.depatureCell.detailTextLabel?.text = station.name
            self.depatureCell.detailTextLabel?.textColor = UIColor.darkText
        }
    }
}
