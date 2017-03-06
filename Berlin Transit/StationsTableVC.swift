//
//  StationsTableVC.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 15/02/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit
import CoreLocation
import MBProgressHUD

class StationsTableVC: UITableViewController, CLLocationManagerDelegate {

    @IBOutlet var locationButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    
    var database = [[String:Any]]()
    var stationsList = [[String:Any]]()
    
    var selectedStation = [String:Any]()
    
    let locationManager: CLLocationManager! = CLLocationManager()
    var pressedLocationButton = false
    var usingCurrentLocation = false
    var isUpdatingLocation = false
    var currentLocationText = "Current Location"
    var progressHud: MBProgressHUD?
    
    var colors = [String:[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        let textField = self.searchBar.value(forKey: "searchField") as? UITextField
        textField?.returnKeyType = .done
        textField?.enablesReturnKeyAutomatically = false
        
        self.locationButton.target = self
        self.locationButton.action = #selector(locationButtonPressed)
        
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
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
        
        let latitude = Double((self.locationManager.location?.coordinate.latitude)!)
        let longitude = Double((self.locationManager.location?.coordinate.longitude)!)
        
        if let url = URL(string: "https://transport.rest/stations/nearby?latitude=\(latitude)&longitude=\(longitude)") {
            makeRequest(request: URLRequest(url: url)) { stations in
                if let stations = stations as? [[String:Any]] {
                    DispatchQueue.main.async {
                        if stations.count > 0 {
                            self.stationsList = stations
                        } else {
                            self.stationsList.removeAll()
                        }
                        self.tableView.reloadData()
                        if let progressHud = self.progressHud {
                            progressHud.hide(animated: true)
                            self.locationManager.stopUpdatingLocation()
                            self.isUpdatingLocation = false
                            self.progressHud = nil
                        }
                    }
                } else {
                    print("Error casting stations to [[String:Any]]")
                }
            }
        } else {
            print("Error creating request URL")
        }
    }
    
    func setSearchBar(useCurrentLocation: Bool) {
        let textField = self.searchBar.value(forKey: "searchField") as? UITextField
        
        if (useCurrentLocation) {
            self.stationsList.removeAll()
            self.tableView.reloadData()
            textField?.textColor = self.view.tintColor
            textField?.text = currentLocationText
            textField?.resignFirstResponder()
            usingCurrentLocation = true
        } else {
            self.stationsList.removeAll()
            self.tableView.reloadData()
            textField?.textColor = UIColor.darkText
            usingCurrentLocation = false
        }
    }
    
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.stationsList.count > 0 {
            self.tableView.separatorStyle = .singleLine;
            return self.stationsList.count
        } else {
            self.tableView.separatorStyle = .none;
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell", for: indexPath)
        
        if self.stationsList.count > 0 {
            cell.textLabel?.text = self.stationsList[indexPath.row]["name"] as? String
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.stationsList.count > 0 {
            return 44
        } else{
            return 200
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.stationsList.count > 0 {
            self.selectedStation = self.stationsList[indexPath.row]
            performSegue(withIdentifier: "showLines", sender: self)
        } else {
            if self.searchBar.isFirstResponder {
                self.searchBar.resignFirstResponder()
            } else {
                self.searchBar.becomeFirstResponder()
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showLines" {
            let linesTableVC = segue.destination as! LinesTableVC
            if let name = self.selectedStation["name"] as? String {
                linesTableVC.title = name
                linesTableVC.station = self.selectedStation
            }
            if let navView = self.navigationController?.view {
                MBProgressHUD.showAdded(to: navView, animated: true)
            }
        }
    }
}

extension StationsTableVC: UISearchBarDelegate {
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
                self.stationsList.removeAll()
                self.tableView.reloadData()
            }
            return
        }
        
        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        if let url = URL(string: "https://transport.rest/stations?completion=true&query=\(query!)") {
            makeRequest(request: URLRequest(url: url)) { stations in
                if let stations = stations as? [[String:Any]] {
                    DispatchQueue.main.async {
                        if stations.count > 0 {
                            self.stationsList = stations
                        } else {
                            self.stationsList.removeAll()
                        }
                        self.tableView.reloadData()
                    }
                } else {
                    print("Error casting stations to [[String:Any]]")
                }
            }
        } else {
            print("Error creating request URL")
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}
