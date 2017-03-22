//
//  StationPicker.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 21/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit
import CoreLocation
import MBProgressHUD
import FontAwesome_swift

@objc protocol StationPickerDelegate {
    @objc func stationPicker(didPickStation station: Station, sender: StationPicker)
    @objc optional func stationPicker(prepareFor segue: UIStoryboardSegue, sender: StationPicker)
}

@objc class StationPicker: UINavigationController {
    
    var pickerDelegate: StationPickerDelegate?
    
    let tableViewController = UITableViewController()
    
    // Location
    let locationManager: CLLocationManager! = CLLocationManager()
    var pressedLocationButton = false
    var usingCurrentLocation = false
    var isUpdatingLocation = false
    var currentLocationText = "Current Location"
    var progressHud: MBProgressHUD?
    
    // SearchBar
    let searchBar = UISearchBar()
    var searchTextField = UITextField()
    var searchBarIcon: UIImage?
    
    var canCancel = false
    var autoFocus = false
    var resetOnViewDisappear = false
    
    var stations = [Station]()
    
    // MARK: - Delegate Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = " "
        self.tableViewController.navigationItem.backBarButtonItem = backButtonItem

        // TableViewController
        self.setViewControllers([self.tableViewController], animated: false)
        self.tableViewController.tableView.delegate = self
        self.tableViewController.tableView.dataSource = self
        self.tableViewController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "stationCell")
        
        if self.canCancel {
            // Cancel Button
            self.tableViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        } else {
            self.tableViewController.navigationItem.leftBarButtonItems?.removeAll()
        }
        
        // Location Button
        let locationButtonText = String.fontAwesomeIcon(name: .locationArrow)
        let attributes = [NSFontAttributeName: UIFont.fontAwesome(ofSize: 24)] as [String: Any]
        let rightBarButtonItem = UIBarButtonItem(title: locationButtonText, style: .plain, target: self, action: #selector(locationButtonPressed))
        rightBarButtonItem.setTitleTextAttributes(attributes, for: .normal)
        self.tableViewController.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        // Location Service
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        // SearchBar
        self.searchBar.sizeToFit()
        self.searchBar.placeholder = "Enter a station name"
        self.searchBarIcon = self.searchBar.image(for: .search, state: .normal)
        self.tableViewController.tableView.tableHeaderView = self.searchBar
        self.searchBar.delegate = self
        self.searchTextField = self.searchBar.value(forKey: "searchField") as! UITextField
        self.searchTextField.returnKeyType = .done
        self.searchTextField.enablesReturnKeyAutomatically = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableViewController.title = self.title
        
        if let text = self.searchBar.text, text.isEmpty {
            self.tableViewController.tableView.scrollRectToVisible(self.searchBar.frame, animated: true)
        }
        
        if self.autoFocus {
            self.searchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.resetOnViewDisappear {
            self.setSearchBar(useCurrentLocation: false)
            self.searchBar.text?.removeAll()
            self.searchBar.resignFirstResponder()
        }
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Helper Methods
    
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func locationButtonPressed() {
        self.pressedLocationButton = true
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
                return
            }
            if CLLocationManager.authorizationStatus() == .denied {
                print("You have denied this app to use the Location Services.")
                return
            }
        } else {
            print("Location Services are not enabled. Please go to Settings and enable Location Services.")
            return
        }
        
        if !self.isUpdatingLocation {
            self.locationManager.startUpdatingLocation()
            self.isUpdatingLocation = true
        }
        
        self.setSearchBar(useCurrentLocation: true)
        
        if let superview = self.view.superview {
            if self.progressHud == nil {
                self.progressHud = MBProgressHUD.showAdded(to: superview, animated: true)
                self.progressHud?.hide(animated: true, afterDelay: 10)
            }
        }
        
        if let location = self.locationManager.location {
            DataKit.getNearbyStations(location: location) { nearbyStations, error in
                self.stations = nearbyStations
                
                self.tableViewController.tableView.reloadData()
                if let progressHud = self.progressHud {
                    progressHud.hide(animated: true)
                    self.locationManager.stopUpdatingLocation()
                    self.isUpdatingLocation = false
                    self.progressHud = nil
                }
                
                guard error == nil else {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                        self.setSearchBar(useCurrentLocation: false)
                        self.searchBar.text?.removeAll()
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
        } else {
            if let progressHud = self.progressHud {
                progressHud.hide(animated: true)
                self.locationManager.stopUpdatingLocation()
                self.isUpdatingLocation = false
                self.progressHud = nil
            }
            
            let alert = UIAlertController(title: "Error", message: "Failed to get current location", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                self.setSearchBar(useCurrentLocation: false)
                self.searchBar.text?.removeAll()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setSearchBar(useCurrentLocation: Bool) {
        self.stations.removeAll()
        self.tableViewController.tableView.reloadData()
        
        if (useCurrentLocation) {
            self.searchTextField.textColor = self.view.tintColor
            self.searchTextField.text = currentLocationText
            self.searchTextField.resignFirstResponder()
            let locationIcon = UIImage.fontAwesomeIcon(name: .locationArrow, textColor: self.view.tintColor, size: CGSize(width: 30, height: 30))
            self.searchBar.setImage(locationIcon, for: .search, state: .normal)
            usingCurrentLocation = true
        } else {
            self.searchTextField.textColor = UIColor.darkText
            self.searchBar.setImage(searchBarIcon, for: .search, state: .normal)
            usingCurrentLocation = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.pickerDelegate?.stationPicker?(prepareFor: segue, sender: self)
    }
}

extension StationPicker: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.stations.count > 0 {
            tableView.separatorStyle = .singleLine;
            return self.stations.count
        } else {
            tableView.separatorStyle = .none;
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell", for: indexPath)
        
        if self.stations.count > 0 {
            cell.textLabel?.text = self.stations[indexPath.row].name
            cell.textLabel?.textColor = UIColor.darkText
            cell.textLabel?.textAlignment = .left
            cell.selectionStyle = .default
        } else {
            cell.textLabel?.text = "Please search for a station."
            cell.textLabel?.textColor = UIColor.darkGray
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.stations.count > 0 {
            return 44
        } else{
            return 200
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.stations.count > 0 {
            self.pickerDelegate?.stationPicker(didPickStation: self.stations[indexPath.row], sender: self)
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            if self.searchBar.isFirstResponder {
                self.searchBar.resignFirstResponder()
            } else {
                self.searchBar.becomeFirstResponder()
            }
        }
    }
}

extension StationPicker: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if self.pressedLocationButton {
            if status == .authorizedWhenInUse {
                self.locationButtonPressed()
            }
            
            if status == .denied {
                print("Location Services denied.")
            }
        }
    }
}

extension StationPicker: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if self.usingCurrentLocation {
            setSearchBar(useCurrentLocation: false)
            if (self.searchBar.text?.characters.count)! > self.currentLocationText.characters.count {
                self.searchBar.text = searchText.replacingOccurrences(of: currentLocationText, with: "")
            } else {
                self.searchBar.text?.removeAll()
            }
        }
        
        if searchText.isEmpty {
            setSearchBar(useCurrentLocation: false)
            DispatchQueue.main.async {
                self.stations.removeAll()
                self.tableViewController.tableView.reloadData()
            }
            return
        }
        
        DataKit.queryStations(searchText: searchText) { queriedStations, error in
            guard error == nil else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if queriedStations.count > 0 {
                self.stations = queriedStations
            } else {
                self.stations.removeAll()
            }
            self.tableViewController.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}

