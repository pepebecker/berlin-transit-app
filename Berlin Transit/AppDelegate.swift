//
//  AppDelegate.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 15/02/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit
import MBProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var selectedStation = Station()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if let tabBarVC = window?.rootViewController as? UITabBarController {
            if let stationPicker = tabBarVC.viewControllers?[1] as? StationPicker {
                stationPicker.pickerDelegate = self
            }
            
            tabBarVC.selectedIndex = 1
            let size = CGSize(width: 30, height: 30)
            tabBarVC.viewControllers?[0].tabBarItem.image = UIImage.fontAwesomeIcon(name: .heartO, textColor: .black, size: size)
            tabBarVC.viewControllers?[0].tabBarItem.selectedImage = UIImage.fontAwesomeIcon(name: .heart, textColor: .black, size: size)
            tabBarVC.viewControllers?[1].tabBarItem.image = UIImage.fontAwesomeIcon(name: .search, textColor: .black, size: size)
            tabBarVC.viewControllers?[3].tabBarItem.image = UIImage.fontAwesomeIcon(name: .mapO, textColor: .black, size: size)
            tabBarVC.viewControllers?[3].tabBarItem.selectedImage = UIImage.fontAwesomeIcon(name: .map, textColor: .black, size: size)
        }

        downloadColors()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate: StationPickerDelegate {
    func stationPicker(didPickStation station: Station, sender: StationPicker) {
        selectedStation = station
        sender.performSegue(withIdentifier: "showLines", sender: sender)
    }
    
    func stationPicker(prepareFor segue: UIStoryboardSegue, sender: StationPicker) {
        if segue.identifier == "showLines" {
            if let linesTableVC = segue.destination as? LinesTableVC {
                linesTableVC.title = self.selectedStation.name
                linesTableVC.station = self.selectedStation
                MBProgressHUD.showWithCancelAdded(to: sender.view, animated: true)
            }
        }
    }
}

