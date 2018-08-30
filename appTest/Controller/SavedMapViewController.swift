//
//  SavedMapViewController.swift
//  appTest
//
//  Created by Valentin Camara on 31/07/2018.
//  Copyright © 2018 Valentin Camara. All rights reserved.
//

import UIKit
import MapKit

class SavedMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    var locations = globalLocation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewRegion = MKCoordinateRegionMakeWithDistance(locations[0].coordinate, 600, 600)
        addPolyLineToMap(locations: self.locations)

        self.map.addAnnotations(getMapAnnotations())
        self.map.setRegion(viewRegion, animated: true)
    }
    
    @IBAction func goBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func addPolyLineToMap(locations: [CLLocation]) {
        let coordinates = locations.map({ (location: CLLocation!) -> CLLocationCoordinate2D in
            return location.coordinate
        })
        let polyline = MKPolyline(coordinates: coordinates, count: locations.count)
        self.map.add(polyline)
    }
    
    func getMapAnnotations() -> [Annotation] {
        var annotations:Array = [Annotation]()
        //load plist file
        let annotation = self.locations
        //iterate and create annotations
        for item in annotation {
            let lat = item.coordinate.latitude
            let long = item.coordinate.longitude
            let annotation = Annotation(latitude: lat, longitude: long)
            annotation.subtitle = "Latitude: \(lat)\nLongitude: \(long)\nAltitude: \(item.altitude)"
            annotations.append(annotation)
        }
        return annotations
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay);
            pr.strokeColor = UIColor.red.withAlphaComponent(0.5);
            pr.lineWidth = 5;
            return pr;
        }
        return MKOverlayRenderer()
    }
}

class Annotation: NSObject, MKAnnotation {
    var latitude: Double
    var longitude:Double
    var subtitle: String?
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
