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
    @IBOutlet weak var editItem: UIBarButtonItem!
    public var viewModel: MapViewModel?
    
    private var isEditingMode = false {
        didSet {
            configureView()
        }
    }
    // Create User Defaults to save zoom and location
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Virtual tourist"
        mapView.delegate = self
        
        viewModel?.fetchSavedPins()
    }
    
    func configureView() {
        editItem.title = isEditingMode ? "Done" : "Edit"
    }
    
    @IBAction func didTapEditItem(_ sender: Any) {
        isEditingMode = !isEditingMode
    }
    
    @IBAction func didLongTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.becomeFirstResponder()
            
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if isEditingMode, let coordinate = view.annotation?.coordinate {
          viewModel?.deletePin(longitude: Float(coordinate.longitude), latitude: Float(coordinate.latitude))
            mapView.removeAnnotation(view.annotation!)
        }
        else {
            if let coordinate = view.annotation?.coordinate,
                let vm = viewModel?.getDetailView(longitude: Float(coordinate.longitude), latitude: Float(coordinate.latitude)) {
                let vc = SampleViewController()
                vc.viewModel = vm
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

extension MapViewController: PinDataServiceProtocol, AlertShowerProtocol {
    func reloadData() {
        mapView.reloadInputViews()
    }
    
    func showAlert(with message: String) {
        // TODO: show alert
    }
    
    func savedPinsFetched(pins: [Pin]) {
        for pin in pins {
            let newPin: MKPointAnnotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude))
        
            print(coordinate.longitude, coordinate.latitude)
            // Set the coordinates.
            newPin.coordinate = coordinate

            // Add pins to MapView.
            mapView.addAnnotation(newPin)
        }
    }
}

