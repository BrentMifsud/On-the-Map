//
//  SessionRequest.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import Foundation

struct SessionRequest: Codable {
	let loginDetails: LoginCredentials

	enum CodingKeys: String, CodingKey {
		case loginDetails = "udacity"
	}
}

struct LoginCredentials: Codable {
	let username: String
	let password: String
}
