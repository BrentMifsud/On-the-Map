//
//  ListViewController.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import UIKit

class PinListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

	@IBAction func addPinButtonTapped(_ sender: Any) {
		performSegue(withIdentifier: "addPin", sender: nil)
	}
	@IBAction func refreshButtonTapped(_ sender: Any) {
	}

}
