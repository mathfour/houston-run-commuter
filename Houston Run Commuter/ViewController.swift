import UIKit
import CoreLocation
import MapKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
  
  private var currentCoordinate: CLLocationCoordinate2D?
  let manager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    stopNumber.text = ""
    minToArrival.text = ""
    routeNumber.text = ""
    
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    let result = formatter.string(from: date)
    currentTime.text = result
    
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.requestWhenInUseAuthorization()
    manager.startUpdatingLocation()
    
    //        locationManager = CLLocationManager()
    //        locationManager?.delegate = self
    
    
  }
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBOutlet weak var stopNumber: UILabel!
  @IBOutlet weak var routeNumber: UILabel!
  @IBOutlet weak var minToArrival: UILabel!
  @IBOutlet weak var textField: UITextField!
  
  @IBOutlet weak var currentTime: UILabel!
  @IBOutlet weak var currentTimeNotDate: UILabel!
  
  @IBAction func refreshLatLong(_ sender: UIButton) {
    manager.startUpdatingLocation()
  }
  
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations[0]
    
    let currentLat = location.coordinate.latitude
    print(currentLat)
    
    let currentLong = location.coordinate.longitude
    print(currentLong)
    
    
    manager.stopUpdatingLocation() // to stop constantly getting location
    
    currentCoordinate = manager.location?.coordinate // important
    
  }
  
  
  
  
  @IBAction func buttonPush(_ sender: Any) {
    
    let busStop : String? = self.textField.text
    
    self.stopNumber.text = ""
    self.minToArrival.text = ""
    self.routeNumber.text = ""
    
    print("bus stop is \(busStop!)")
    
    let config = URLSessionConfiguration.default // Session Configuration
    let session = URLSession(configuration: config) // Load configuration into Session
    
//    Add back in for production
//    let currentLatNum = currentCoordinate?.latitude
//    let currentLongNum = currentCoordinate?.longitude
    
    let latHoustonConversion = (arc4random_uniform(10)+796)
    let longHoustonConversion = (arc4random_uniform(20)+2695)
    
    
    let cupertinoLat = currentCoordinate?.latitude
    let cupertinoLong = currentCoordinate?.longitude
    
    let houstonRandomLat: Double = cupertinoLat! - Double(latHoustonConversion)/100
    let houstonRandomLong: Double = cupertinoLong! + Double(longHoustonConversion)/100
    
    let currentLatNum = houstonRandomLat
    let currentLongNum = houstonRandomLong
    
    print(currentLatNum, ", ",currentLongNum)

    
    
    //    let currentLatStr = String(describing: currentCoordinate?.latitude)
    //    let currentLongStr = String(describing: currentCoordinate?.longitude)
    
    let currentLatStr: String! = "\(currentLatNum)"
    let currentLongStr: String! = "\(currentLongNum)"
    
    
    //    let currentLat : String = "29.763"
    //    let currentLong: String = "-95.363"
    //
    //    let useThisUrlToGetStopCodes: String? = "https://houstonmetro.azure-api.net/data/GeoAreas('\(currentLatStr.description)|\(currentLongStr.description)|0.5')/Stops?$format=json&subscription-key=8f5df090e61646659538452c75882d59"
    
    let useThisUrlToGetStopCodes: String? = "https://houstonmetro.azure-api.net/data/GeoAreas('\(currentLatStr.description)%7C\(currentLongStr.description)%7C0.25')/Stops?$format=json&subscription-key=8f5df090e61646659538452c75882d59"
    
    print("*****************************")
    print("getting bus stop number: \n", useThisUrlToGetStopCodes!)
    print("*****************************")
    
    
    let urlForStops = URL(string: useThisUrlToGetStopCodes!)!
    
    
    let task = session.dataTask(with: urlForStops, completionHandler: {
      (data, response, error) in
      
      if error != nil {
        
        print(error!.localizedDescription)
        
      } else {
        
        do {
          
          if let jsonfred = try JSONSerialization.jsonObject(with: data!) as? [String: Any]{
            
            if let d = jsonfred["d"] as? [String: Any] {
              
              if let results = d["results"] as? [[String: Any]] {
                
                
                for result in results {
                  
                  if let stopCode = result["StopCode"] as? String {
                    
                    print("stopCode is", stopCode)
                    
                    
                    let useThisUrl: String? = "https://api.ridemetro.org/data/Stops('Ho414_4620_\(stopCode)')/Arrivals?&$format=json&subscription-key=8f5df090e61646659538452c75882d59"
                    print("*****************************")
                    print("this is the url for the routes and arrival times: " , useThisUrl!)
                    print("*****************************")
                    
                    let url = URL(string: useThisUrl!)!
                    
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
                                  
                                  if let busRoute = result["RouteName"] as? String {
                                    if let arrivalTime = result["LocalArrivalTime"] as? String {
                                      
                                      if let number = Double(arrivalTime.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
                                        let arTime = trunc(number/1000)
                                        print("the arTime is \(arTime)")
                                        
                                        let timezoneAdjust: Double = -5
                                        
                                        
                                        let arrival = Date(timeIntervalSince1970: TimeInterval(Double(arTime)))
                                        print("arrival time is \(arrival)")
                                        
                                        let now = trunc(Date().timeIntervalSince1970 + timezoneAdjust*60*60)
                                        
                                        print("it is now \(now)")
                                        
                                        let diff = trunc((arTime - now)/60)
                                        print("minutes until arrival is \(diff)")
                                        print("*****************************")
                                        
                                        
//                                        let busStop : String? = self.textField.text
//                                        
//                                        self.stopNumber.text = ""
//                                        self.minToArrival.text = ""
//                                        self.routeNumber.text = ""
                                        //                                                                                print("bus stop is \(busStop!)")
                                        
                                        
                                        
                                        DispatchQueue.main.async {
                                          
                                          self.stopNumber.text = self.stopNumber.text! + stopCode + "\n"
                                          
                                          self.routeNumber.text = self.routeNumber.text! + busRoute + "\n"
                                          
                                          self.minToArrival.text = self.minToArrival.text! + String(diff) + "\n"
                                        }
                                        
                                        let date = Date()
                                        let formatter = DateFormatter()
                                        formatter.dateFormat = "h:mm a"
                                        let result = formatter.string(from: date)
                                        self.currentTimeNotDate.text = result
                                        
                                      }
                                      
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
                
              }
            }
          }
        } catch {
          
          print("error in JSONSerialization")
          
        }
      }
      
    }
      
      
    )
    task.resume()
    
  }
}














//@IBAction func buttonPush2(_ sender: Any) {
//
//    let config = URLSessionConfiguration.default // Session Configuration
//    let session = URLSession(configuration: config) // Load configuration into Session
//
//    let useThisUrlToGetStopCodes: String? = "https://houstonmetro.azure-api.net/data/GeoAreas('" + currentLat! + "|" + currentLong! + "|0.5')/Stops?subscription-key=8f5df090e61646659538452c75882d59"
//
//    print("*****************************")
//    print("getting bus stop number: ", useThisUrlToGetStopCodes!)
//    print("*****************************")
//
//    let urlForStops = URL(string: useThisUrlToGetStopCodes!)!
//
//    let task = session.dataTask(with: urlForStops, completionHandler: {
//        (data, response, error) in
//
//        if error != nil {
//
//            print(error!.localizedDescription)
//
//        } else {
//
//            do {
//
//                if let jsonfred = try JSONSerialization.jsonObject(with: data!) as? [String: Any]{
//
//                    if let d = jsonfred["d"] as? [String: Any] {
//
//                        if let results = d["results"] as? [[String: Any]] {
//
//
//
//                            for result in results {
//
//                                if let stopCode = result["StopCode"] as? String {
//
//
//
//
//
//
//
//
//
//                                    DispatchQueue.main.async {
//
//                                        self.stopNumber.text = self.stopNumber.text! + self.textField.text! + "\n"
//
//                                        self.routeNumber.text = self.routeNumber.text! + busRoute + "\n"
//
//                                        self.minToArrival.text = self.minToArrival.text! + String(diff) + "\n"
//                                    }
//
//                                    let date = Date()
//                                    let formatter = DateFormatter()
//                                    formatter.dateFormat = "h:mm a"
//                                    let result = formatter.string(from: date)
//                                    self.currentTimeNotDate.text = result
//
//                                }
//
//                            }
//                        }
//                    }
//                }
//            }
//        }
//
//    } catch {
//
//        print("error in JSONSerialization")
//
//    }
//
//
//}
//
//
//})
//task.resume()
//
//}





// https://api.ridemetro.org/data/Stops('Ho414_4620_2446')/Arrivals?&$format=json&subscription-key=8f5df090e61646659538452c75882d59
