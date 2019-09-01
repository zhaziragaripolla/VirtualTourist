//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 8/31/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var pins = [Pin]()
    let viewModel = PinDataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Virtual tourist"
        mapView.delegate = self
        
        pins = viewModel.pins
        for pin in pins {
            
            let newPin: MKPointAnnotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude))
            
            // Set the coordinates.
            newPin.coordinate = coordinate
            
            // Set the title.
            newPin.title = "title"
            
            // Set subtitle.
            newPin.subtitle = "subtitle"
            
            // Added pins to MapView.
            mapView.addAnnotation(newPin)
        }
    }
    
    @IBAction func didLongTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.becomeFirstResponder()
            print("begin")
            
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            let newPin: MKPointAnnotation = MKPointAnnotation()
            
            // Set the coordinates.
            newPin.coordinate = coordinate
            
            // Set the title.
            newPin.title = "title"
            
            // Set subtitle.
            newPin.subtitle = "subtitle"
            
            // Add pins to MapView.
            mapView.addAnnotation(newPin)
            viewModel.save(lat: Float(coordinate.latitude), long: Float(coordinate.longitude))
            
        }
    }

}

extension ViewController: MKMapViewDelegate {
    
    // Delegate method called when addAnnotation is done.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let myPinIdentifier = "PinAnnotationIdentifier"
        
        // Generate pins.
        let myPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: myPinIdentifier)
        
        // Add animation.
        myPinView.animatesDrop = true
        
        // Display callouts.
        myPinView.canShowCallout = true
        
        // Set annotation.
        myPinView.annotation = annotation
        
        print("latitude: \(annotation.coordinate.latitude), longitude: \(annotation.coordinate.longitude)")
        
        return myPinView
    }
    
}

