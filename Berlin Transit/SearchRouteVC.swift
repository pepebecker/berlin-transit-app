//
//  SearchRouteVC.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 21/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

class SearchRouteVC: UIViewController {
    
    @IBOutlet weak var fromView: UIView!
    @IBOutlet weak var toView: UIView!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var switchLabel: UILabel!
    
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
        
        let fromTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectOrigin))
        let toTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectDestination))
        let switchTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(switchStations))
        let searchTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchPressed))
        
        self.fromView.addGestureRecognizer(fromTapRecognizer)
        self.toView.addGestureRecognizer(toTapRecognizer)
        self.switchLabel.addGestureRecognizer(switchTapRecognizer)
        self.searchLabel.addGestureRecognizer(searchTapRecognizer)
    }
    
    func switchStations() {
        print("Switch")
        let tmp = self.origin
        self.origin = self.destination
        self.destination = tmp
        
        self.fromLabel.text = self.origin?.name
        self.toLabel.text = self.destination?.name
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
    
    func searchPressed() {
        self.performSegue(withIdentifier: "showRoutes", sender: self)
    }
}

// MARK: - Navigation
extension SearchRouteVC {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRoutes" {
            if let routesTableVC = segue.destination as? AvailableRoutesTableVC {
                routesTableVC.origin = self.origin
                routesTableVC.destination = self.destination
            }
        }
    }
}

extension SearchRouteVC: StationPickerDelegate {
    func stationPicker(didPickStation station: Station, sender: StationPicker) {
        sender.dismiss(animated: true, completion: nil)
        
        if self.selectingDestination {
            self.destination = station
            self.toLabel.text = station.name
        } else {
            self.origin = station
            self.fromLabel.text = station.name
        }
    }
}
