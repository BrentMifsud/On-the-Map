//
//  ConfirmPinViewController.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-04.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import UIKit
import MapKit

class ConfirmPinViewController: UIViewController {

	@IBOutlet weak var mediaTextField: UITextField!
	@IBOutlet weak var mapView: MKMapView!

	var locationName: String!
	var coordinate: CLLocationCoordinate2D!

	override func viewDidLoad() {
        super.viewDidLoad()

		mapView.delegate = self

		mediaTextField.attributedPlaceholder =
			NSAttributedString(
				string: "Enter a URL to share",
				attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
		)

		searchForLocation()

        // Do any additional setup after loading the view.
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard locationName != nil else {
			self.dismiss(animated: true, completion: nil)
			return
		}
	}
    
	@IBAction func confirmPinButtonTapped(_ sender: Any) {
	}
}

extension ConfirmPinViewController: MKMapViewDelegate {

	func searchForLocation(){
		CLGeocoder().geocodeAddressString(locationName) { [unowned self] (placemark, error) in
			guard error == nil else {
				self.presentErrorAlert(title: "Search Failed", message: "Unable to find location: \(self.locationName!)" , completion: {
					self.dismiss(animated: true, completion: nil)
				})
				return
			}

			self.coordinate = placemark!.first!.location!.coordinate
			self.addPin(coordinate: self.coordinate)

		}
	}

	func addPin(coordinate: CLLocationCoordinate2D){
		let annotation = MKPointAnnotation()
		annotation.coordinate = coordinate
		annotation.title = locationName

		let mapRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

		DispatchQueue.main.async {
			self.mapView.addAnnotation(annotation)
			self.mapView.setRegion(mapRegion, animated: true)
			self.mapView.regionThatFits(mapRegion)
		}
	}
}
