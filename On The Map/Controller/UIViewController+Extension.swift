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
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func addPinButtonTapped(_ sender: Any) {
		performSegue(withIdentifier: "addPin", sender: nil)
	}

	func isDownloading(_ downloading: Bool){
		UIApplication.shared.isNetworkActivityIndicatorVisible = downloading
	}

}
