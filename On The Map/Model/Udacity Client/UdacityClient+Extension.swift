//
//  UdacityClient+Extension.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import Foundation

extension UdacityClient {
	static let sessionKey = "sessionId"
	static let expiryKey = "sessionExpiry"
	static let uniqueIdKey = "accountKey"


	static var sessionId: String = {
		return UserDefaults.standard.string(forKey: sessionKey) ?? ""
	}()
	static var sessionExpiry: String = {
		return UserDefaults.standard.string(forKey: expiryKey) ?? ""
	}()
	static var uniqueKey: String = {
		return UserDefaults.standard.string(forKey: uniqueIdKey) ?? ""
	}()


	class func setUserdefaults(sessionId: String, sessionExpiry: String, accountKey: String) {
		UserDefaults.standard.set(sessionId, forKey: sessionKey)
		UserDefaults.standard.set(sessionExpiry, forKey: expiryKey)
		UserDefaults.standard.set(accountKey, forKey: uniqueIdKey)
	}

	class func clearUserdefaults(){
		UserDefaults.standard.set(nil, forKey: sessionKey)
		UserDefaults.standard.set(nil, forKey: expiryKey)
		UserDefaults.standard.set(nil, forKey: uniqueIdKey)
	}

	class func firstTimeLogin() -> Bool {
		let firstTimeLogin = sessionId.isEmpty && sessionExpiry.isEmpty && uniqueKey.isEmpty ? true : false
		return firstTimeLogin
	}

}
