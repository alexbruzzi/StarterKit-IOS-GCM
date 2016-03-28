//
//  Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import CoreLocation


@objc(ViewController)  // match the ObjC symbol name inside Storyboard
class ViewController: UIViewController, CLLocationManagerDelegate {

  @IBOutlet weak var registeringLabel: UILabel!
  @IBOutlet weak var registrationProgressing: UIActivityIndicatorView!
    
  var locationManager: CLLocationManager!
    
  var label = UILabel(frame: CGRectMake(10, 460, 300, 50))

  override func viewDidLoad() {
    super.viewDidLoad()
    
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    
    // Add buttons for Events
    
    // add app login button
    let button   = UIButton(type: UIButtonType.System) as UIButton
    button.frame = CGRectMake(10, 100, 200, 50)
    button.backgroundColor = UIColor.greenColor()
    button.setTitle("App Login", forState: UIControlState.Normal)
    button.addTarget(self, action: "AppLoginBtnHandler:", forControlEvents: UIControlEvents.TouchUpInside)
    self.view.addSubview(button)
    
    // add app logout button
    let button2   = UIButton(type: UIButtonType.System) as UIButton
    button2.frame = CGRectMake(10, 200, 200, 50)
    button2.backgroundColor = UIColor.blueColor()
    button2.setTitle("App Logout", forState: UIControlState.Normal)
    button2.addTarget(self, action: "AppLogoutBtnHandler:", forControlEvents: UIControlEvents.TouchUpInside)
    self.view.addSubview(button2)
    
    // add page view button
    let button3   = UIButton(type: UIButtonType.System) as UIButton
    button3.frame = CGRectMake(10, 300, 200, 50)
    button3.backgroundColor = UIColor.redColor()
    button3.setTitle("Page View", forState: UIControlState.Normal)
    button3.addTarget(self, action: "PageViewBtnHandler:", forControlEvents: UIControlEvents.TouchUpInside)
    self.view.addSubview(button3)
    
    // add product page view button
    let button4   = UIButton(type: UIButtonType.System) as UIButton
    button4.frame = CGRectMake(10, 400, 200, 50)
    button4.backgroundColor = UIColor.purpleColor()
    button4.setTitle("Product Page View", forState: UIControlState.Normal)
    button4.addTarget(self, action: "ProductPageViewBtnHandler:", forControlEvents: UIControlEvents.TouchUpInside)
    self.view.addSubview(button4)
    
    // Get GCM Registration Key
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateRegistrationStatus:",
        name: appDelegate.registrationKey, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "showReceivedMessage:",
        name: appDelegate.messageKey, object: nil)
    registrationProgressing.hidesWhenStopped = true
    registrationProgressing.startAnimating()
    
    // Create a label for showing Response IDs
    label.text = "Events Results here..."
    label.numberOfLines = 3
    self.view.addSubview(label)


  }
  
    
    
    func showAPIResult(response: NSString) -> (Void) {
        print(response)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.label.text = response as String
        }
        
    }
    
    func AppLoginBtnHandler(sender:UIButton!){
        let api = OctoAPI()
        let userId = 4
        
        api.sendAppLoginCall(userId) { (result) -> Void in
            self.showAPIResult(result)
        }
    }
    
    
    func AppLogoutBtnHandler(sender:UIButton!){
        let api = OctoAPI()
        let userId = 4
        api.sendAppLogoutCall(userId) { (result) -> Void in
            self.showAPIResult(result)
        }
    }
    
    
    func PageViewBtnHandler(sender:UIButton) {
        
        let api = OctoAPI()
        
        let routeUrl = "/Home"
        let categories = ["something", "something else"]
        let tags = ["cat1", "cat2"]
        let userId = 4
        
        api.sendPageViewCall(userId, routeUrl: routeUrl,
            categories: categories, tags: tags) { (result) -> Void in
                self.showAPIResult(result)
        }
    }
    
    
    func ProductPageViewBtnHandler(sender:UIButton) {
        
        let api = OctoAPI()
        
        let userId = 4
        let routeUrl = "/Home/Phone"
        let productName = "Smartphone Series S02"
        let price = 999.00
        let productId = 635373
        let categories = ["electronics", "phones"]
        let tags = ["selfie", "cheap"]
        
        api.sendProductPageViewCall(userId, routeUrl: routeUrl,
            productId: productId, price: price, productName: productName,
            categories: categories, tags: tags) { (result) -> Void in
                self.showAPIResult(result)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        OctoAPI.updateLocation(locations)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError: \(error.description)")
        
    }
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
        if status == .AuthorizedAlways {
            if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
    }

  func updateRegistrationStatus(notification: NSNotification) {
    registrationProgressing.stopAnimating()
    if let info = notification.userInfo as? Dictionary<String,String> {
      if let error = info["error"] {
        registeringLabel.text = "Error registering!"
        showAlert("Error registering with GCM", message: error)
      } else if let _ = info["registrationToken"] {
        print(info["registrationToken"])
        
        registeringLabel.text = "Registered!"
        let message = "Check the xcode debug console for the registration token that you " +
        " can use with the demo server to send notifications to your device"
        //showAlert("Registration Successful!", message: message)
      }
    } else {
      print("Software failure. Guru meditation.")
    }
  }

  func showReceivedMessage(notification: NSNotification) {
    print("show recieved message called")
    if let info = notification.userInfo as? Dictionary<String,AnyObject> {
      if let aps = info["aps"] as? Dictionary<String, String> {
        showAlert("Message received", message: aps["alert"]!)
      }
    } else {
      print("Software failure. Guru meditation.")
    }
  }

  func showAlert(title:String, message:String) {
    if #available(iOS 8.0, *) {
      let alert = UIAlertController(title: title,
          message: message, preferredStyle: .Alert)
      let dismissAction = UIAlertAction(title: "Dismiss", style: .Destructive, handler: nil)
      alert.addAction(dismissAction)
      self.presentViewController(alert, animated: true, completion: nil)
    } else {
        // Fallback on earlier versions
      let alert = UIAlertView.init(title: title, message: message, delegate: nil,
          cancelButtonTitle: "Dismiss")
      alert.show()
    }
  }

  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}
