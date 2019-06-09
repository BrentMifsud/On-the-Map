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

		mapView.delegate = self
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		refreshStudentLocations()
	}

	@IBAction func refreshButtonTapped(_ sender: Any) {
		refreshStudentLocations()
	}

	func refreshStudentLocations() {
		isDownloading(true)

		StudentLocations.refreshStudentLocations { [unowned self] (error) in
			guard error == nil else { return }

			self.mapView.removeAnnotations(self.annotations)
			self.annotations = [MKPointAnnotation]()

			for studentLocation in StudentLocations.locations {
				self.annotations.append(studentLocation.getMapAnnotation())
			}

			self.mapView.addAnnotations(self.annotations)
			self.isDownloading(false)
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "addPin" {
			let destinationVC = segue.destination as? AddPinViewController
			let updateStudentInfo = sender as? (Bool, [StudentLocation])
			destinationVC?.updatePin = updateStudentInfo?.0
			destinationVC?.studentLocations = updateStudentInfo?.1
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
			pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIButton
		} else {
			pinView!.annotation = annotation
		}

		return pinView
	}

	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if control == view.rightCalloutAccessoryView {
			let app = UIApplication.shared
			if let toOpen = view.annotation?.subtitle! {
				app.open(URL(string: toOpen) ?? URL(string: "")!, options: [:], completionHandler: nil)
			}
		}
	}
}
