import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
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
    
    @IBAction func buttonPush(_ sender: Any) {
        let busStop : String? = textField.text
//        stopNumber.text = ""
//        routeNumber.text = ""
        
        print("bus stop is \(busStop!)")
        
        
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        
        let useThisUrl: String? = "https://api.ridemetro.org/data/Stops('Ho414_4620_" + busStop! + "')/Arrivals?&$format=json&subscription-key=8f5df090e61646659538452c75882d59"
        print("*****************************")
        print(useThisUrl!)
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
                                            
                                            

                                            
                                            DispatchQueue.main.async {
                                                
                                                self.stopNumber.text = self.stopNumber.text! + self.textField.text! + "\n"
                                               
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



// https://api.ridemetro.org/data/Stops('Ho414_4620_2446')/Arrivals?&$format=json&subscription-key=8f5df090e61646659538452c75882d59
