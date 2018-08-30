//
//  newTripViewController.swift
//  appTest
//
//  Created by Valentin Camara on 20/07/2018.
//  Copyright © 2018 Valentin Camara. All rights reserved.
//

import UIKit
import MapKit

class newTripViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var speedArray: [Double] = []
    var startingTime: Date!
    var endingTime: Date!
    var locations: [CLLocation] = []

    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var activityButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLabel.text = ""
        
        self.locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }

    func addPolyLineToMap(locations: [CLLocation]) {
        var coordinates = locations.map({ (location: CLLocation!) -> CLLocationCoordinate2D in
            return location.coordinate
        })
        let polyline = MKPolyline(coordinates: &coordinates, count: locations.count)
        self.map.add(polyline)
    }
    
    //This is to specify how the map reads the polyline
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay);
            pr.strokeColor = UIColor.red.withAlphaComponent(0.5);
            pr.lineWidth = 5;
            return pr;
        }
        return MKOverlayRenderer()
    }
    
    //This function called when the location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locSpeed: CLLocationSpeed = manager.location!.speed
        //Sometimes speed can be negative if we don't move and we don't want that
        if locSpeed < 0 {
            locSpeed = 0
        }
        
        //Conversion to km/h
        locSpeed = locSpeed * 3.6
        //We put speed at all time to calculate the average speed in the end
        speedArray.append(locSpeed)
        let duration = newTripViewController.calculateTime(startingTime: startingTime, endingTime: Date())
        let distance = self.distance(duration: duration)
        displayLabel.text = "Distance: " + String(format: "%.3f", distance) + " km. \nDuration: " + String(format: "%d' %d\"", duration/60, duration%60) + "\n" + "Speed: " + String(format: "%.1f", locSpeed) + " km/h "
        let userLocation = locations.last
        
        //Recentering the area
        let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation!.coordinate, 600, 600)
       
        self.locations.append(userLocation!)
        addPolyLineToMap(locations: self.locations)
        
        self.map.setRegion(viewRegion, animated: true)
    }

    var activityOnGoing = false
    @IBAction func activityButton(_ sender: Any) {
        if !activityOnGoing {
            locationManager.startUpdatingLocation()
            startingTime = Date()
            activityButton.setTitle("Stop activity", for: .normal)
        } else {
            locationManager.stopUpdatingLocation()
            activityButton.setTitle("Start activity", for: .normal)
            endingTime = Date()
            let timeInterval = newTripViewController.calculateTime(startingTime: startingTime, endingTime: endingTime)
            
            let alert = UIAlertController(title: "Save activity", message: "Write a name", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "Name of the activity"
            }
            let action = UIAlertAction(title: "Save", style: .default) { (action: UIAlertAction) in
                let trip = Trip(context: PersistenceService.context)
                trip.averageSpeed = self.averageSpeed()
                trip.distance = self.distance(duration: timeInterval)
                trip.startingTime = self.startingTime! as NSDate
                trip.endingTime = self.endingTime! as NSDate
                trip.name = alert.textFields!.first!.text
                trip.location = self.locations
                PersistenceService.saveContext()
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            displayLabel.text = String(format: "%d' %d\"", timeInterval/60, timeInterval%60)
        }
        activityOnGoing = !activityOnGoing
    }

    func averageSpeed() -> Double {
        let total = (speedArray.reduce(0, +))
        let res = total / Double(speedArray.count)
        return res
    }
    
    static func calculateTime(startingTime: Date, endingTime: Date) -> Int {
        let timeInterval = endingTime.timeIntervalSince(startingTime)
        return Int(timeInterval)
    }
    
    func distance(duration: Int) -> Double {
        let distance = ((averageSpeed() / 3600) * Double(duration))
        print(distance)
        return distance
    }

}
