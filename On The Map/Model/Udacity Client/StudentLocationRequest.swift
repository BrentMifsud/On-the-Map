//
//  StudentLocationRequest.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import Foundation

struct StudentLocationPost: Codable {
	let objectId: String
	let uniqueKey: String
	let firstName: String
	let lastName: String
	let mapString: String
	let mediaURL: String
	let latitude: Float
	let longitude: Float
}
