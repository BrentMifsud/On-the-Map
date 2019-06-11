//
//  UserDataResponse.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-10.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import Foundation

// MARK: - UserDataResponse
struct UserDataResponse: Codable {
	let user: User
}

// MARK: - User
struct User: Codable {
	let lastName: String
	let firstName: String

	enum CodingKeys: String, CodingKey {
		case lastName = "last_name"
		case firstName = "first_name"
	}
}
