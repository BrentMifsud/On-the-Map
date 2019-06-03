//
//  LoginSessionResponse.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import Foundation

struct LoginSessionResponse: Codable {
	let account: Account
	let session: Session
}

struct Account: Codable {
	let registered: Bool
	let key: String
}

struct Session: Codable {
	let id: String
	let expiration: String
}
