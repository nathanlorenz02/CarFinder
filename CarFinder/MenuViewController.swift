//
//  MenuViewController.swift
//  CarFinder
//
//  Created by Nathan Lorenz on 2018-01-02.
//  Copyright © 2018 Nathan Lorenz. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import UserNotifications

class MenuViewController: UIViewController, UNUserNotificationCenterDelegate {
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var parkCarOutlet: UIButton!
    @IBOutlet weak var findCarOutlet: UIButton!
    @IBOutlet weak var removeCarLocationOutlet: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var popUpView: UIView!
    @IBOutlet weak var activitiyIndicator: UIActivityIndicatorView!
    var timer = Timer()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(MenuViewController.status), userInfo: nil, repeats: true)
        
        parkCarOutlet.layer.cornerRadius = 5
        findCarOutlet.layer.cornerRadius = 5
        removeCarLocationOutlet.layer.cornerRadius = 5
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge], completionHandler: {didAllow, error in
            if didAllow
            {
                
            }
            else
            {
                
            }
            
        })
        
        UNUserNotificationCenter.current().delegate = self
        popUpView.layer.cornerRadius = 10
        
        
        
       
    }
    
    @objc func status()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        request.returnsObjectsAsFaults = false
        
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
               statusLabel.text = "Car is parked"
                UserDefaults.init(suiteName: "group.com.nathanlorenz.carfinder")?.setValue(statusLabel.text, forKey: "status")
            }
            else
            {
               statusLabel.text = "Car isn't parked"
                UserDefaults.init(suiteName: "group.com.nathanlorenz.carfinder")?.setValue(statusLabel.text, forKey: "status")
            }
        }
        catch
        {
            print("Error: Couldn't load car status.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func removeCarLocation(_ sender: Any)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
           try context.execute(deleteRequest)
           try context.save()
            
            
        }
        catch
        {
            print("Error: Couldn't remove car location.")
            let alert2 = UIAlertController(title: "There was a error", message: "We encountered a error in trying to remove your cars location.", preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert2.addAction(okButton)
            self.present(alert2, animated: true, completion: nil)
        }
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        

    }
    
    
    @IBAction func parkMyCar(_ sender: Any)
    {
        
        self.view.addSubview(popUpView)
        popUpView.center = self.view.center
        activitiyIndicator.startAnimating()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let findCar = UNNotificationAction(identifier: "action1", title: "Find Car", options: UNNotificationActionOptions.foreground)
        
        let category = UNNotificationCategory(identifier: "category", actions: [findCar], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 900, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = "Parked Car"
        content.body =  "We have marked your car's location."
        content.categoryIdentifier = "category"
        
        let request = UNNotificationRequest(
            identifier: "notfication", content: content, trigger: trigger
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "action1"
        {
            self.performSegue(withIdentifier: "openMap", sender: self)
        }
        completionHandler()
    }
    
    
    @IBAction func findMyParkedCar(_ sender: Any)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult> (entityName: "Location")
        
        request.returnsObjectsAsFaults = false
        
        do
        {
            let results = try context.fetch(request)
            if results.count > 0
            {
                self.performSegue(withIdentifier: "openMap", sender: self)
            }
            else
            {
                let alert = UIAlertController(title: "Your car isn't parked.", message: "You haven't set a location for your car.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        catch
        {
            let alert2 = UIAlertController(title: "Sorry we encounterd a error.", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert2.addAction(okAction)
            self.present(alert2, animated: true, completion: nil)
        }
        
       
    }
    
    

    
}

extension MenuViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
       let latestLocation: CLLocation = locations[locations.count - 1]
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        
        location.setValue(String(format: "%.9f", latestLocation.coordinate.latitude), forKey: "latitude")
        location.setValue(String(format: "%.9f", latestLocation.coordinate.longitude), forKey: "longitude")
        
        do
        {
            try context.save()
            self.popUpView.removeFromSuperview()
            activitiyIndicator.stopAnimating()
            print("saved")
        }
        catch
        {
            let alert2 = UIAlertController(title: "There was a error", message: nil, preferredStyle: .alert)
            let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert2.addAction(okButton)
            self.present(alert2, animated: true, completion: nil)
        }
        
    }
    
}


