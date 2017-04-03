//
//  VBBUtils.swift
//  Berlin Transit
//
//  Created by Pepe Becker on 24/03/2017.
//  Copyright © 2017 Pepe Becker. All rights reserved.
//

import UIKit

public class VBBUtils: NSObject {
    static var currentTask: URLSessionDataTask?
    
    class func getHostname() -> String {
        let defaults = UserDefaults.standard
        
        if let developerMode = defaults.value(forKey: "developerMode") as? Bool {
            if developerMode {
                var host = String()
                if let hostname = defaults.value(forKey: "developerHostname") as? String {
                    host = hostname
                    if let port = defaults.value(forKey: "developerPort") as? String {
                        host += ":\(port)"
                    }
                }
                return host
            }
        }
        
        return "https://transport.rest"
    }
    
    class func makeRequest(url: URL, completion: @escaping (Any, Error?)->Void) {
        var request = URLRequest(url: url)
        request.addValue("com.pepebecker.vbb-app", forHTTPHeaderField: "X-Identifier")
        
        print("VBB GET: \((request.url?.absoluteString)!)")
        if currentTask != nil {
            currentTask?.cancel()
        }
        
        currentTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error sending request: \(error!.localizedDescription)")
                if error!.localizedDescription != "cancelled" {
                    completion([], error)
                }
                return
            }
            
            guard let data = data else {
                print("Data is empty")
                completion([], error)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                completion(json, nil)
            } catch {
                print("Error serializing JSON: \(error)")
            }
        }
        
        currentTask?.resume()
    }
    
    public class func getMinutes(interval: TimeInterval) -> Int {
        let futureTime = Date(timeIntervalSince1970: interval)
        let seconds = futureTime.timeIntervalSinceNow
        
        let minutes = Int(Double(seconds / 60).rounded(.up))
        return minutes
    }
    
    public class func getMinutes(timestamp: Int) -> Int {
        return self.getMinutes(interval: TimeInterval(timestamp))
    }
    
    public class func getTimestamp(date: Date) -> Int {
        return Int(date.timeIntervalSince1970)
    }
}
