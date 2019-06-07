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

	override func viewDidLoad() {
        super.viewDidLoad()

		locationTextField.attributedPlaceholder = NSAttributedString(
			string: "Enter your location here",
			attributes: [NSAttributedString.Key.foregroundColor: UIColor.white]
		)
    }

	@IBAction func findOnMapButtonTapped(_ sender: Any) {
		guard let locationText = locationTextField.text else { return }

		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let confirmPinVC = storyboard.instantiateViewController(withIdentifier: "ConfirmPinViewController") as! ConfirmPinViewController
		confirmPinVC.locationName = locationText
	}
}
