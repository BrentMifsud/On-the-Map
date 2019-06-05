//
//  UdacityClient+Extension.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import Foundation

extension UdacityClient {
	static let sessionIdKey = "sessionId"
	static let sessionExpiryKey = "sessionExpiry"
	static let uniqueKey = "accountKey"

	class func setUserdefaults(sessionId: String, sessionExpiry: String, accountKey: String) {
		UserDefaults.standard.set(sessionId, forKey: sessionIdKey)
		UserDefaults.standard.set(sessionExpiry, forKey: sessionExpiryKey)
		UserDefaults.standard.set(accountKey, forKey: uniqueKey)
	}

	class func clearUserdefaults(){
		UserDefaults.standard.set("", forKey: sessionIdKey)
		UserDefaults.standard.set("", forKey: sessionExpiryKey)
		UserDefaults.standard.set("", forKey: uniqueKey)
	}

	class func getSessionId() -> String {
		return UserDefaults.standard.string(forKey: sessionIdKey) ?? ""
	}

	class func getSessionExpiry() -> String {
		return UserDefaults.standard.string(forKey: sessionExpiryKey) ?? ""
	}

	class func getAccountId() -> String {
		return UserDefaults.standard.string(forKey: uniqueKey) ?? ""
	}

}
