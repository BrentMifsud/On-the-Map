//
//  LoginViewController.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginButton: UIButton!

	override func viewDidAppear(_ animated: Bool) {
		super .viewDidAppear(animated)

		//Persistant Login. Udacity sessions have short expiry times.
		guard !UdacityClient.getSessionId().isEmpty
			&& !UdacityClient.getAccountId().isEmpty
			&& !UdacityClient.getSessionExpiry().isEmpty else { return }

		guard sessionIsValid(sessionExpiry: UdacityClient.getSessionExpiry()) else {
			//TODO: Add username and password to keyvault so that new session can be retrieved without logging in again
			showLoginFailure(message: "Session is expired. Please Login again.")
			return
		}

		performSegue(withIdentifier: "completeLogin", sender: nil)
	}

	@IBAction func loginButtonTapped(_ sender: Any) {
		UdacityClient.getLoginSession(username: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
	}

	func showLoginFailure(message: String) {
		let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
		alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		show(alertVC, sender: nil)
	}

}

extension LoginViewController {
	func handleLoginResponse(success: Bool, error: Error?){
		unowned let loginVC = self

		if success {
			loginVC.performSegue(withIdentifier: "completeLogin", sender: nil)
		} else {
			showLoginFailure(message: error?.localizedDescription ?? "Placeholder Login Error Message")
		}
	}

	func sessionIsValid(sessionExpiry: String) -> Bool {
		let dateFormatter = DateFormatter()

		dateFormatter.locale = Locale(identifier: "en_US_POSIX")
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		dateFormatter.timeZone = TimeZone.autoupdatingCurrent

		let expiryDate = dateFormatter.date(from: sessionExpiry)

		switch Date().compare(expiryDate!).rawValue {
		case 1:
			return false
		case -1:
			return true
		default:
			return false
		}
	}
}
