//
//  ViewController.swift
//  Houston Run Commuter
//
//  Created by Bon Crowder on 8/10/17.
//  Copyright © 2017 Bon Crowder. All rights reserved.
//

import UIKit





class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonPush(_ sender: Any) {
        
        print("woohoo")
        
        
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string: "https://api.ridemetro.org/data/Stops('Ho414_4620_2446')/Arrivals?&$format=json&subscription-key=8f5df090e61646659538452c75882d59")!
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            if error != nil {
                
                print(error!.localizedDescription)
                
            } else {
                
                do {
                    
                    if let jsonfred = try JSONSerialization.jsonObject(with: data!) as? [String: Any]{
                        
                        if let d = jsonfred["d"] as? [String: Any] {
                            
                            if let results = d["results"] as? [[String: Any]] {
                                
                                for result in results {
                                    
                                    if let arrivalTime = result["LocalArrivalTime"] as? String {
                                        
                                        if let number = Double(arrivalTime.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                                            let arTime = trunc(number/1000)
                                            print("the arTime is \(arTime)")
                                            
                                            let timezoneAdjust: Double = -5
                                            
                                            
                                            let arrival = Date(timeIntervalSince1970: TimeInterval(Double(arTime)))
                                            print("arrival time is \(arrival)")
                                            
                                            let now = trunc(Date().timeIntervalSince1970 + timezoneAdjust*60*60)
                                            
                                            print("it is now \(now)")
                                            
                                            var diff = trunc((arTime - now)/60)
                                            print("minutes until arrival is \(diff)")
                                            
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                } catch {
                    
                    print("error in JSONSerialization")
                    
                }
                
                
            }
            
            
        })
        task.resume()
        
    }
}



// https://api.ridemetro.org/data/Stops('Ho414_4620_2446')/Arrivals?&$format=json&subscription-key=8f5df090e61646659538452c75882d59
