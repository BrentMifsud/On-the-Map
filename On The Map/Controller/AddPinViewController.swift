//
//  AddPinViewController.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import UIKit
import MapKit

class AddPinViewController: UIViewController {

	@IBOutlet weak var locationTextField: UITextField!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	var updatePin: Bool!
	var studentLocations: [StudentLocation]!

	override func viewDidLoad() {
        super.viewDidLoad()

		locationTextField.attributedPlaceholder = NSAttributedString(
			string: "Enter your location here",
			attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
		)
    }

	@IBAction func findOnMapButtonTapped(_ sender: Any) {
		guard let locationText = locationTextField.text else { return }

		guard locationText != "" else {
			presentErrorAlert(title: "Invalid Location", message: "You must enter a location\nto place a map pin.")
			return
		}
		searchForLocation(locationText)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "confirmPin" {
			let destinationVC = segue.destination as! ConfirmPinViewController
			let locationDetails = sender as!  (String, CLLocationCoordinate2D)
			destinationVC.locationName = locationDetails.0
			destinationVC.coordinate = locationDetails.1
			destinationVC.updateExistingPin = updatePin
			destinationVC.existingStudentLocations = studentLocations
		}
	}

	fileprivate func isGeocoding(_ geocoding: Bool){
		geocoding ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
		isDownloading(geocoding)
	}

	fileprivate func searchForLocation(_ locationText: String) {
		isGeocoding(true)
		CLGeocoder().geocodeAddressString(locationText) { [unowned self] (placemark, error) in
			guard let placemark = placemark else {
				self.presentErrorAlert(title: "Search Failed", message: "Unable to find location: \(locationText)")
				return
			}

			let coordinate = placemark.first!.location!.coordinate
			self.isGeocoding(false)
			self.performSegue(withIdentifier: "confirmPin", sender: (locationText, coordinate))
		}
	}
}
