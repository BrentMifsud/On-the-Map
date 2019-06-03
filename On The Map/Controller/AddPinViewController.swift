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

		locationTextField.attributedPlaceholder = NSAttributedString(string: "Enter your location here",
															   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
