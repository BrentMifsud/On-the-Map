//
//  AddPinViewController.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import UIKit

class AddPinViewController: UIViewController {

	@IBOutlet weak var locationTextField: UITextField!

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
		if let locationText = locationTextField.text {
			if locationText == "" {
				presentErrorAlert(title: "Invalid Location", message: "You must enter a location\nto place a map pin.")
			} else {
				performSegue(withIdentifier: "confirmPin", sender: (locationTextField.text ?? ""))
			}
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "confirmPin" {
			let destinationVC = segue.destination as! ConfirmPinViewController
			let locationString = sender as! String
			destinationVC.locationName = locationString
			destinationVC.updateExistingPin = updatePin
			destinationVC.existingStudentLocations = studentLocations
		}
	}
}
