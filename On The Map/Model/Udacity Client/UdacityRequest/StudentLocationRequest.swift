//
//  StudentLocationRequest.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import Foundation

struct StudentLocationRequest: Codable {
	let uniqueKey: String
	let firstName: String
	let lastName: String
	let mapString: String
	let mediaURL: String
	let latitude: Float
	let longitude: Float
}
