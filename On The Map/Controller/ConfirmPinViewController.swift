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
	var updateExistingPin: Bool!
	var existingStudentLocations: [StudentLocation]!

	override func viewDidLoad() {
        super.viewDidLoad()

		mapView.delegate = self

		mediaTextField.attributedPlaceholder =
			NSAttributedString(
				string: "Enter a URL to share",
				attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
		)

		searchForLocation()

    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		guard locationName != nil else {
			self.dismiss(animated: true, completion: nil)
			return
		}
	}
    
	@IBAction func confirmPinButtonTapped(_ sender: Any) {
		guard let mediaText = mediaTextField.text else {
			return
		}

		guard mediaText != "" else {
			presentErrorAlert(title: "Empty Media Field", message: "You must provide a url.")
			return
		}

		let studentLocationRequest = StudentLocationRequest(uniqueKey: UdacityClient.getAccountId(), firstName: "Bob", lastName: "MacBeth", mapString: locationName, mediaURL: mediaText, latitude: Float(coordinate.latitude), longitude: Float(coordinate.longitude))

		if updateExistingPin {
			updateExistingPin(studentLocationRequest: studentLocationRequest)
		} else {
			postNewPin(studentLocationRequest: studentLocationRequest)
		}
	}

	func postNewPin(studentLocationRequest: StudentLocationRequest){
		UdacityClient.postStudentLocation(studentLocationRequest: studentLocationRequest) { [unowned self] (success, error) in
			if success {
				self.navigationController?.popToRootViewController(animated: true)
			} else {
				self.presentErrorAlert(title: "Unable to post new pin", message: "The following error occured:\n\(error?.localizedDescription ?? "Unable to post pin")")
			}
		}
	}

	func updateExistingPin(studentLocationRequest: StudentLocationRequest){
		guard !existingStudentLocations.isEmpty else {return}

		UdacityClient.putStudentLocation(studentLocationRequest: studentLocationRequest, objectId: existingStudentLocations[0].objectId) { (success, error) in
			if success {
				self.navigationController?.popToRootViewController(animated: true)
			} else {
				self.presentErrorAlert(title: "Unable to post new pin", message: "The following error occured:\n\(error?.localizedDescription ?? "Unable to update pin"))")
			}
		}
	}
}

extension ConfirmPinViewController: MKMapViewDelegate {

	func searchForLocation(){
		CLGeocoder().geocodeAddressString(locationName) { [unowned self] (placemark, error) in
			guard error == nil else {
				self.presentErrorAlert(title: "Search Failed", message: "Unable to find location: \(self.locationName!)")
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
