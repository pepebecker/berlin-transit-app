//
//  SettingsVC.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 03.04.17.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

class SettingsVC: UITableViewController {

    @IBOutlet var developerModeSwitch: UISwitch!
    @IBOutlet var hostnameField: UITextField!
    @IBOutlet var portField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        
        let defaults = UserDefaults.standard
        
        if let developerMode = defaults.value(forKey: "developerMode") as? Bool {
            self.developerModeSwitch.isOn = developerMode
        } else {
            self.developerModeSwitch.isOn = false
        }
        
        if let developerHostname = defaults.value(forKey: "developerHostname") as? String {
            self.hostnameField.text = developerHostname
        }
        
        if let developerPort = defaults.value(forKey: "developerPort") as? String {
            self.portField.text = developerPort
        }
        
        self.developerModeSwitch.addTarget(self, action: #selector(setDeveloperMode), for: .valueChanged)
        self.hostnameField.addTarget(self, action: #selector(setDeveloperHostname), for: .editingDidEnd)
        self.portField.addTarget(self, action: #selector(setDeveloperPort), for: .editingDidEnd)
    }
    
    func setDeveloperMode(sender: UISwitch) {
        let defaults = UserDefaults.standard
        defaults.set(sender.isOn, forKey: "developerMode")
    }
    
    func setDeveloperHostname(sender: UITextField) {
        let defaults = UserDefaults.standard
        defaults.set(sender.text, forKey: "developerHostname")
    }
    
    func setDeveloperPort(sender: UITextField) {
        let defaults = UserDefaults.standard
        defaults.set(sender.text, forKey: "developerPort")
    }
}
