//
//  ViewController.swift
//  Project16
//
//  Created by henry on 11/04/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
        
        mapView.addAnnotations([london, oslo, paris, rome, washington])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "map"), style: .plain, target: self, action: #selector(changeMapType))
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 1 If the annotation isn't from a capital city, it must return nil so iOS uses a default view.
        guard annotation is Capital else { return nil }
        //2
        let identifier = "Capital"
            //3
        //TODO: challenges 1
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            annotationView?.pinTintColor = .green
            //4
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            //5
            let btn = UIButton(type : .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
            annotationView?.pinTintColor = .blue
        } else {
            //6
            annotationView?.annotation = annotation
            annotationView?.pinTintColor = .yellow
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        let placeName = capital.title
//        let placeInfo = capital.info
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "webView") as? WebViewController{
            vc.selecttedCapital = placeName
            navigationController?.pushViewController(vc, animated: true)
        }
        
        
//        let alert = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//
//        present(alert, animated:  true)
    }
    @objc func changeMapType(){
        let alert = UIAlertController(title: "Choose Map Type", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Satellite", style: .default){
            //[weak mapView]
            _ in
            self.mapView?.mapType = MKMapType.satellite
        })
        alert.addAction(UIAlertAction(title: "Hybrid", style: .default){
            //[weak mapView]
            _ in
            self.mapView?.mapType = MKMapType.hybrid
        })
        alert.addAction(UIAlertAction(title: "Satellite Flyover", style: .default){
            //[weak mapView]
            _ in
            self.mapView?.mapType = MKMapType.satelliteFlyover
        })
        alert.addAction(UIAlertAction(title: "Standard", style: .default){
            //[weak mapView]
            _ in
            self.mapView?.mapType = MKMapType.mutedStandard
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}


