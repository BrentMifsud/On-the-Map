//
//  UdacityClient.swift
//  On the Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import Foundation
import UIKit

class UdacityClient {
	static let encoder = JSONEncoder()
	static let decoder = JSONDecoder()

	//MARK:- Endpoints
	enum Endpoints {
		static let base = "https://onthemap-api.udacity.com/v1"

		case getLoginSession
		case deleteLoginSession
		case getStudentLocation(startFromRecord: String)
		case getSingleStudentLocation(studentKey: String)
		case postStudentLocation
		case putStudentLocation

		var stringValue: String {
			switch self {
			case .getLoginSession, .deleteLoginSession: return Endpoints.base + "/session"
			case .getStudentLocation(let startFrom): return Endpoints.base + "/StudentLocation" + "?limit=100&skip=\(startFrom)&order=-updatedAt"
			case .getSingleStudentLocation(let uniqueKey): return Endpoints.base + "/StudentLocation?uniqueKey=\(uniqueKey)"
			case .postStudentLocation: return Endpoints.base + "/StudentLocation"
			case .putStudentLocation: return Endpoints.base + "/StudentLocation/\(getSessionId())"
			}
		}

		var url: URL {
			return URL(string: stringValue)!
		}

	}

	//MARK:- Udacity Client Functions

	class func getLoginSession(username: String, password: String, completion: @escaping (Bool, Error?) -> Void){
		let login = LoginCredentials(username: username, password: password)
		let headerFields: [String : String] = [
			"Accept" : "application/json",
			"Content-Type" : "application/json"
		]
		let body = SessionRequest(loginDetails: login)

		taskForPostRequest(url: Endpoints.getLoginSession.url, body: body, headerFields: headerFields, responseType: LoginSessionResponse.self) { (response, error) in
			if let response = response {
				setUserdefaults(sessionId: response.session.id, sessionExpiry: response.session.expiration, accountKey: response.account.key)
				completion(true, nil)
			} else {
				completion(false, error)
			}
		}

	}

	class func deleteLoginSession(completion: @escaping (Bool, Error?) -> Void){
		var url = Endpoints.deleteLoginSession.url

		var request = URLRequest(url: url)
		request.httpMethod = "DELETE"

		var xsrfCookie: HTTPCookie? = nil
		let sharedCookieStorage = HTTPCookieStorage.shared

		for cookie in sharedCookieStorage.cookies! {
			if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie}
		}

		if let xsrfCookie = xsrfCookie {
			request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
		}

		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard error == nil else {
				DispatchQueue.main.async {
					completion(false, error)
				}
				return
			}

			let cleanData = cleanResposneData(data: data!)
			DispatchQueue.main.async {
				completion(true, nil)
			}
		}
		task.resume()

	}

	class func getStudentLocation(startingRecord: Int = 0, allStudents: Bool, completion: @escaping ([StudentLocation], Error?) -> Void){
		let url: URL

		if allStudents {
			url = Endpoints.getStudentLocation(startFromRecord: "\(startingRecord)").url
		} else {
			guard getAccountId() != "" else {return}
			url = Endpoints.getSingleStudentLocation(studentKey: getAccountId()).url
		}

		taskForGetRequest(url: url, responseType: StudentLocationResponse.self) { (response, error) in
			if let response = response {
				completion(response.results, nil)
			} else {
				completion([], error)
			}
		}
	}

	class func postStudentLocation(studentLocation: StudentLocation, completion: @escaping (Bool, Error?) -> Void) {

		let requestBody = StudentLocationRequest(objectId: getSessionId(), uniqueKey: getAccountId(), firstName: studentLocation.firstName, lastName: studentLocation.lastName, mapString: studentLocation.mapString, mediaURL: studentLocation.mediaURL, latitude: studentLocation.latitude, longitude: studentLocation.longitude)

		let headerFields: [String : String] = [
			"Content-Type" : "application/json"
		]

		taskForPostRequest(url: Endpoints.postStudentLocation.url, body: requestBody, headerFields: headerFields, responseType: PostStudentLocationResponse.self) { (response, error) in

			if let response = response {
				print(response)
				completion(true, nil)
			} else {
				completion(false, error)
			}

		}
	}
}

//MARK:- HTTP request methods
extension UdacityClient {
	@discardableResult class func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard let data = data else {
				DispatchQueue.main.async {
					completion(nil, error)
				}
				return
			}

			do {
				let responseObject = try decoder.decode(ResponseType.self, from: data)

				DispatchQueue.main.async {
					completion(responseObject, nil)
				}
			} catch {
				DispatchQueue.main.async {
					completion(nil, error)
				}
			}
		}
		task.resume()
		return task
	}

	class func taskForPostRequest<RequestType: Codable, ResponseType: Decodable>(url: URL, body: RequestType, headerFields: [String: String], responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {

		var request = URLRequest(url: url)

		request.httpMethod = "POST"

		for (key, value) in headerFields {
			request.addValue(value, forHTTPHeaderField: key)
		}

		request.httpBody = try! encoder.encode(body)

		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let data = data else {
				DispatchQueue.main.async {
					completion(nil, error)
				}
				return
			}
			let cleanData = cleanResposneData(data: data)

			do {
				let responseObject = try decoder.decode(ResponseType.self, from: cleanData)
				DispatchQueue.main.async {
					completion(responseObject, nil)
				}
			} catch {
				do {
					let errorResponse = try decoder.decode(UdacityErrorResponse.self, from: cleanData)
					DispatchQueue.main.async {
						completion(nil, errorResponse)
					}
				} catch {
					DispatchQueue.main.async {
						completion(nil, error)
					}
				}
			}
		}
		task.resume()
	}

	class func taskForPutRequest<RequestType: Codable, ResponseType: Decodable>(url: URL, body: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {

		var request = URLRequest(url: url)
		request.httpMethod = "PUT"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try! encoder.encode(body)

		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let data = data else {
				DispatchQueue.main.async {
					completion(nil, error)
				}
				return
			}

			let cleanData = cleanResposneData(data: data)

			do {
				let responseObject = try decoder.decode(ResponseType.self, from: cleanData)

				DispatchQueue.main.async {
					completion(responseObject, nil)
				}

			} catch {
				do {
					let errorResponse = try decoder.decode(UdacityErrorResponse.self, from: cleanData)
					DispatchQueue.main.async {
						completion(nil, errorResponse)
					}
				} catch {
					DispatchQueue.main.async {
						completion(nil, error)
					}
				}
			}
		}
		task.resume()
	}

	fileprivate class func cleanResposneData(data: Data) -> Data{
		return data.subdata(in: 5..<data.count)
	}
}
