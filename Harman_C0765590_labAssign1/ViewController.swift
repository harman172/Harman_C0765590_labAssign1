//
//  ViewController.swift
//  Harman_C0765590_labAssign1
//
//  Created by Harmanpreet Kaur on 2020-01-14.
//  Copyright © 2020 Harmanpreet Kaur. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnDirections: UIButton!
    @IBOutlet weak var segments: UISegmentedControl!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let location = CLLocationCoordinate2D(latitude: 43.64, longitude: -79.38)
        
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapGesture))
        tapGesture.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(tapGesture)
        
    }

    @objc func doubleTapGesture(gestureRecognizer: UIGestureRecognizer){
        
        clearAll()
        
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        
        mapView.addAnnotation(annotation)
        
//        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
//
//        CLGeocoder().reverseGeocodeLocation(location) { (<#[CLPlacemark]?#>, <#Error?#>) in
//            <#code#>
//        }
        
    }

    
    @IBAction func showRoute(_ sender: UIButton) {
        for overlay in mapView.overlays{
            mapView.removeOverlay(overlay)
        }
        getRoute(loc1: mapView.annotations[mapView.annotations.count - 1].coordinate, loc2: mapView.annotations[0].coordinate)
        
        
        
    }
    
    
    func getRoute(loc1: CLLocationCoordinate2D, loc2: CLLocationCoordinate2D){
        let sourcePlacemark = MKPlacemark(coordinate: loc1)
        let destinationPLacemark = MKPlacemark(coordinate: loc2)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPLacemark)
        
        if segments.selectedSegmentIndex == 0{
            directionRequest.transportType = .automobile
        } else{
            directionRequest.transportType = .walking
        }
        
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else{
                if let error = error{
                    print("Error finding directions")
                }
                return
            }
            
            let route = directionResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline{
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.blue
            rendrer.lineWidth = 2
            return rendrer
        }
        return MKOverlayRenderer()
    }

 
    func clearAll(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
        
        for overlay in mapView.overlays{
            mapView.removeOverlay(overlay)
        }
    }

    @IBAction func zoomIn(_ sender: UIButton) {
        var region: MKCoordinateRegion = mapView.region
        region.span.latitudeDelta /= 2.0
        region.span.longitudeDelta /= 2.0
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func zoomOut(_ sender: UIButton) {
        
        var region: MKCoordinateRegion = mapView.region
        region.span.latitudeDelta = min(region.span.latitudeDelta * 2.0, 180.0)
        region.span.longitudeDelta = min(region.span.longitudeDelta * 2.0, 180.0)
        mapView.setRegion(region, animated: true)
    }
}

