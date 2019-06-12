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
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	override func viewDidAppear(_ animated: Bool) {
		super .viewDidAppear(animated)

		//MARK: Persistent Login feature
		guard !UdacityClient.firstTimeLogin() else {
			return
		}

		guard sessionIsValid(sessionExpiry: UdacityClient.sessionExpiry) else {
			//TODO: Add username and password to keyvault so that new session can be retrieved without logging in again
			showLoginFailure(message: "Session is expired. Please Login again.")
			return
		}

		performSegue(withIdentifier: "completeLogin", sender: nil)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		emailTextField.text = ""
		passwordTextField.text = ""
	}

	@IBAction func loginButtonTapped(_ sender: Any) {
		setLoggingIn(true)
		UdacityClient.getLoginSession(username: emailTextField.text ?? "", password: passwordTextField.text ?? "", completion: handleLoginResponse(success:error:))
	}

	@IBAction func signUpButtonTapped(_ sender: Any) {
		let app = UIApplication.shared
		app.open(URL(string: "https://auth.udacity.com/sign-up")!, options: [:], completionHandler: nil)
	}


	func showLoginFailure(message: String) {
		let alertVC = UIAlertController(title: "Login Failed", message: message, preferredStyle: .alert)
		alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		show(alertVC, sender: nil)
	}

	fileprivate func setLoggingIn(_ loggingIn: Bool){
		if loggingIn {
			activityIndicator.startAnimating()
		} else {
			activityIndicator.stopAnimating()
		}
		emailTextField.isEnabled = !loggingIn
		passwordTextField.isEnabled = !loggingIn
		loginButton.isEnabled = !loggingIn
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

		setLoggingIn(false)
	}

	func sessionIsValid(sessionExpiry: String) -> Bool {
		guard !sessionExpiry.isEmpty else {
			return false
		}

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
