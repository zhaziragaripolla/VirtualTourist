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

    private var editItem: UIBarButtonItem!
    public var viewModel: MapViewModel!
    
    private let mapView = MKMapView(frame: .zero)
    
    private var isEditingMode = false {
        didSet {
            configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Virtual tourist"
        mapView.delegate = self
        
        layoutUI()
        viewModel?.fetchSavedPins()
    }
    
    fileprivate func layoutUI() {
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        mapView.delegate = self
        
        editItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(didTapEditItem(_:)))
        navigationItem.setRightBarButton(editItem, animated: true)
        
        let gestureRecognize = UILongPressGestureRecognizer(target: self, action: #selector(didLongTap(_:)))
        mapView.addGestureRecognizer(gestureRecognize)
    }

    private func configureView() {
        editItem.title = isEditingMode ? "Done" : "Edit"
    }
    
    @objc func didTapEditItem(_ sender: Any) {
        isEditingMode = !isEditingMode
    }
    
    @objc func didLongTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        // Long press gesture causes dropping a new pin.
        if gestureRecognizer.state == .began {
            self.becomeFirstResponder()
            
            // Getting location of gesture in the map view to initialize a MKPointAnnotation.
            let location = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            let newPin: MKPointAnnotation = MKPointAnnotation()
            newPin.coordinate = coordinate
            
            // Add pin to MapView.
            mapView.addAnnotation(newPin)
            
            // Save a pin to a view model.
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
        
        // View annotation selection is handled depending on Editing mode.
        
        // In case of editing mode, selection of annotation pin causes its deletion.
        if isEditingMode, let coordinate = view.annotation?.coordinate {
            
            // Deleting Core Data entity is delegated to view model.
            viewModel?.deletePin(longitude: Float(coordinate.longitude), latitude: Float(coordinate.latitude))
            
            // MapView is removing selected annotation.
            mapView.removeAnnotation(view.annotation!)
        }
        else {
            
            // In non-Editing mode, selection causes showing a new VC with details of selected pin.
            showPinPhotos(coordinate: view.annotation!.coordinate)
        }
    }
    
    // Helper function to instatiate a PhotoAlbumVC to show photos of selected pin.
    private func showPinPhotos(coordinate: CLLocationCoordinate2D) {
        if let vm = viewModel.getDetailView(longitude: Float(coordinate.longitude), latitude: Float(coordinate.latitude)) {
            let vc = PhotoAlbumViewController()
            vc.viewModel = vm
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension MapViewController: PinDataServiceProtocol {
    func reloadData() {
        mapView.reloadInputViews()
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
}

