//
//  ViewController.swift
//  CarFinder
//
//  Created by Nathan Lorenz on 2018-01-02.
//  Copyright © 2018 Nathan Lorenz. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class ViewController: UIViewController {
    var locationManager = CLLocationManager()
    
    var latitude1 = 0.0
    var longitude1 = 0.0
    
    var latStr = ""
    var longStr = ""

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        request.returnsObjectsAsFaults = false
        
        do
        {
            let results = try context.fetch(request)
            for result in results as! [NSManagedObject]
            {
                if let theLatitude = result.value(forKey: "latitude") as? String
                {
                   
                    latStr = theLatitude
                    let double1 = Double(latStr)
                    latitude1 = double1!
                }
                if let theLongitude = result.value(forKey: "longitude") as? String
                {
                    longStr = theLongitude
                    let double2 = Double(longStr)
                    longitude1 = double2!
                    
                }
                
                
               
                
               
                
            }
        }
        catch
        {
            print("error")
        }
        
        let newPin = MKPointAnnotation()
        newPin.coordinate = CLLocationCoordinate2DMake(latitude1, longitude1)
        newPin.title = "Parked Car"
        mapView.addAnnotation(newPin)
        
        
        let latitude:CLLocationDegrees = latitude1
        
        let longitude:CLLocationDegrees = longitude1
        
        let latDelta:CLLocationDegrees = 0.005
        
        let lonDelta:CLLocationDegrees = 0.005
        
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region = MKCoordinateRegionMake(location, span)
        
        mapView.setRegion(region, animated: false)
        
       
        
    }
    
    
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.01, 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }

        
    }
    
}

