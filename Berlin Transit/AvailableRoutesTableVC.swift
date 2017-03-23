//
//  AvailableRoutesTableVC.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 20/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

class AvailableRoutesTableVC: UITableViewController {
    
    var availableRoutes = [[String:Any]]()
    
    var origin: Station?
    var destination: Station?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.refreshData()
    }
    
    func refreshData() {
        if let originID = self.origin?.id, let destinationID = self.destination?.id {
            getRoutes(from: originID, to: destinationID) { routes in
                DispatchQueue.main.async {
                    self.availableRoutes = routes
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func getRoutes(from: String, to: String, completion: @escaping ([[String:Any]])->Void) {
        if let url = URL(string: "https://transport.rest/routes?from=\(from)&to=\(to)") {
            makeRequest(request: URLRequest(url: url), completion: { routes, error in
                if let routes = routes as? [[String:Any]] {
                    completion(routes)
                } else {
                    print("Failed to cast routes")
                }
            })
        } else {
            print("Failed to create request url")
        }
    }
}

//MARK: - UITableViewDelegate
extension AvailableRoutesTableVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availableRoutes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell", for: indexPath)
        
        if let parts = self.availableRoutes[indexPath.row]["parts"] as? [[String:Any]] {
            var content = String()
            for part in parts {
                if let product = part["product"] as? [String:Any] {
                    if let line = product["line"] as? String {
                        content += line + " "
                    }
                }
            }
            cell.textLabel?.text = content
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
