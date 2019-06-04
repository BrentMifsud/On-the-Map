//
//  MapViewController.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

	@IBOutlet weak var mapView: MKMapView!
	
	var annotations = [MKPointAnnotation]()

    override func viewDidLoad() {
        super.viewDidLoad()

		if StudentLocations.locations.count == 0 {
			refreshStudentLocations()
		}
    }

	@IBAction func refreshButtonTapped(_ sender: Any) {
		refreshStudentLocations()
	}

	func refreshStudentLocations() {
		isDownloading(true)

		StudentLocations.refreshStudentLocations { (error) in
			guard error == nil else { return }

			unowned let mapVC = self

			mapVC.mapView.removeAnnotations(mapVC.annotations)
			mapVC.annotations = [MKPointAnnotation]()

			for studentLocation in StudentLocations.locations {
				mapVC.annotations.append(studentLocation.getMapAnnotation())
			}

			mapVC.mapView.addAnnotations(mapVC.annotations)
			mapVC.isDownloading(false)
		}
	}
}

extension MapViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

		let reuseId = "pin"

		var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
			pinView!.canShowCallout = true
			pinView!.pinTintColor = .red
			pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
		} else {
			pinView!.annotation = annotation
		}

		return pinView
	}

	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if control == view.rightCalloutAccessoryView {
			let app = UIApplication.shared
			if let toOpen = view.annotation?.subtitle! {
				app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
			}
		}
	}
}
