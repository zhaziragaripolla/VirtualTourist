//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Zhazira Garipolla on 8/31/19.
//  Copyright © 2019 Zhazira Garipolla. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    public var viewModel: MapViewModel?
    // Create User Defaults to save zoom and location
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Virtual tourist"
        mapView.delegate = self
        
        viewModel?.fetchSavedPins()
    }
    
    @IBAction func didLongTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.becomeFirstResponder()
            print("begin")
            
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            let newPin: MKPointAnnotation = MKPointAnnotation()
            newPin.coordinate = coordinate
            
            // Add pins to MapView.
            mapView.addAnnotation(newPin)
            
            // TODO: use a delegate?
            // Save a pin
            viewModel?.savePin(longitude: Float(coordinate.longitude), latitude: Float(coordinate.latitude))
        }
    }

}

extension MapViewController: MKMapViewDelegate {
    
    // Delegate method called when addAnnotation is done.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let myPinIdentifier = "PinAnnotationIdentifier"
        
        // Generate pins.
        let myPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: myPinIdentifier)
        
        // Add animation.
        myPinView.animatesDrop = true
        myPinView.canShowCallout = true
        myPinView.annotation = annotation

        return myPinView
    }
    
}

extension MapViewController: PinDataServiceProtocol, AlertShowerProtocol {
    func showAlert(with message: String) {
        // TODO: show alert
    }
    
    func savedPinsFetched(pins: [Pin]) {
        for pin in pins {
            let newPin: MKPointAnnotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude))
        
            // Set the coordinates.
            newPin.coordinate = coordinate

            // Add pins to MapView.
            mapView.addAnnotation(newPin)
        }
    }
    
//    func taskCompleted() {
//        let vc = SampleViewController()
//        navigationController?.pushViewController(vc, animated: true)
//    }
}

