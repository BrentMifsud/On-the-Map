//
//  UIViewController+Extension.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import UIKit

extension UIViewController {

	@IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
		UdacityClient.clearUserdefaults()

		UdacityClient.deleteLoginSession { [unowned self] (success, error) in
			self.presentingViewController?.dismiss(animated: true, completion: nil)
		}
	}


	func presentOverwriteAlert(students: [StudentLocation]){
		let alertVC = UIAlertController(title: "Overwrite Pin?", message: "You already have a pin placed on the map.\nWould you like to overwrite it with a new one?", preferredStyle: .alert)

		alertVC.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [unowned self] (_) in
			self.performSegue(withIdentifier: "addPin", sender: (true, students))
		}))

		alertVC.addAction(UIAlertAction(title: "No", style: .default, handler: nil))

		present(alertVC, animated: true, completion: nil)
	}


	func presentErrorAlert(title: String, message: String){
		let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alertVC, animated: true, completion: nil)
	}


	func isDownloading(_ downloading: Bool){
		UIApplication.shared.isNetworkActivityIndicatorVisible = downloading
	}


	func subscribeToKeyboardNotifications() {
		self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTap)))
	}


	func unsubscribeFromKeyboardNotifications() {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

		self.view.removeGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardOnTap)))
	}
	

	@objc func dismissKeyboardOnTap(){
		self.view.endEditing(true)
	}

}
