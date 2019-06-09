//
//  UdacityErrorResponse.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import Foundation

struct UdacityErrorResponse: Codable {
	let statusCode: Int
	let errorMessage: String

	enum CodingKeys: String, CodingKey {
		case statusCode = "status"
		case errorMessage = "error"
	}
}

extension UdacityErrorResponse: LocalizedError {
	var errorDescription: String? {
		return self.errorMessage
	}
}

struct UdacityPutErrorResponse: Codable {
	let code: Int
	let error: String
}

extension UdacityPutErrorResponse: LocalizedError {
	var errorDescription: String? {
		return self.error
	}
}
