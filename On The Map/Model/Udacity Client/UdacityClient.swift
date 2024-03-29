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
		case getSingleStudentLocation(uniqueKey: String)
		case postStudentLocation
		case putStudentLocation(objectId: String)
		case getUserData(uniqueKey: String)

		var stringValue: String {
			switch self {
			case .getLoginSession, .deleteLoginSession: return Endpoints.base + "/session"
			case .getStudentLocation(let startFrom): return Endpoints.base + "/StudentLocation" + "?limit=100&skip=\(startFrom)&order=-updatedAt"
			case .getSingleStudentLocation(let uniqueKey): return Endpoints.base + "/StudentLocation?uniqueKey=\(uniqueKey)"
			case .postStudentLocation: return Endpoints.base + "/StudentLocation"
			case .putStudentLocation(let objectId): return Endpoints.base + "/StudentLocation/\(objectId)"
			case .getUserData(let uniqueKey): return Endpoints.base + "/users/\(uniqueKey)"
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

		taskForPostRequest(url: Endpoints.getLoginSession.url, body: body, headerFields: headerFields, cleanData: true, responseType: LoginSessionResponse.self) { (response, error) in
			if let response = response {
				setUserdefaults(sessionId: response.session.id, sessionExpiry: response.session.expiration, accountKey: response.account.key)
				completion(true, nil)
			} else {
				completion(false, error)
			}
		}

	}

	class func getUserData(completion: @escaping (UserDataResponse?, Error?) -> Void){
		taskForGetRequest(url: Endpoints.getUserData(uniqueKey: uniqueKey).url, responseType: UserDataResponse.self, cleanData: true) { (userDataResponse, error) in
			guard let userDataResponse = userDataResponse else {
				completion(nil, error)
				return
			}

			print("UserData First Name: \(userDataResponse.user.firstName)")
			print("UserData Last Name: \(userDataResponse.user.lastName)")

			completion(userDataResponse, nil)
		}
	}


	class func getStudentLocation(startingRecord: Int = 0, allStudents: Bool, completion: @escaping ([StudentLocation], Error?) -> Void){
		let url: URL

		if allStudents {
			url = Endpoints.getStudentLocation(startFromRecord: "\(startingRecord)").url
		} else {
			guard uniqueKey != "" else {return}
			url = Endpoints.getSingleStudentLocation(uniqueKey: uniqueKey).url
		}

		taskForGetRequest(url: url, responseType: StudentLocationResponse.self, cleanData: false) { (response, error) in
			if let response = response {
				completion(response.results, nil)
			} else {
				completion([], error)
			}
		}
	}


	class func postStudentLocation(studentLocationRequest: StudentLocationRequest, completion: @escaping (Bool, Error?) -> Void) {

		let requestBody = studentLocationRequest

		let headerFields: [String : String] = [
			"Content-Type" : "application/json"
		]

		taskForPostRequest(url: Endpoints.postStudentLocation.url, body: requestBody, headerFields: headerFields, cleanData: false, responseType: PostStudentLocationResponse.self) { (response, error) in

			response != nil ? completion(true, nil) : completion(false, error)
		}
	}


	class func deleteLoginSession(completion: @escaping (Bool, Error?) -> Void){
		let url = Endpoints.deleteLoginSession.url

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

			DispatchQueue.main.async {
				completion(true, nil)
			}
		}
		task.resume()

	}


	class func putStudentLocation(studentLocationRequest: StudentLocationRequest, objectId: String, completion: @escaping (Bool, Error?) -> Void) {
		var request = URLRequest(url: Endpoints.putStudentLocation(objectId: objectId).url)
		let body = studentLocationRequest

		request.httpMethod = "PUT"
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = try! encoder.encode(body)

		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let data = data else {
				DispatchQueue.main.async {
					completion(false, error)
				}
				return
			}

			do {
				_ = try decoder.decode(PutStudentLocationResponse.self, from: data)

				DispatchQueue.main.async {
					completion(true, nil)
				}
			} catch {
				do {
					let errorResponse = try decoder.decode(UdacityPutErrorResponse.self, from: data)

					DispatchQueue.main.async {
						completion(false, errorResponse)
					}
				} catch {
					DispatchQueue.main.async {
						completion(false, error)
					}
				}
			}
		}
		task.resume()
	}
}



//MARK:- HTTP request methods
extension UdacityClient {
	@discardableResult class func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, cleanData: Bool, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
		let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard let data = data else {
				DispatchQueue.main.async {
					completion(nil, error)
				}
				return
			}

			do {
				let responseObject = cleanData ? try decoder.decode(ResponseType.self, from: cleanResposneData(data: data)) : try decoder.decode(ResponseType.self, from: data)

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

	class func taskForPostRequest<RequestType: Codable, ResponseType: Decodable>(url: URL, body: RequestType, headerFields: [String: String], cleanData: Bool, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {

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
			do {
				let responseObject = cleanData ? try decoder.decode(ResponseType.self, from: cleanResposneData(data: data)) : try decoder.decode(ResponseType.self, from: data)

				DispatchQueue.main.async {
					completion(responseObject, nil)
				}
			} catch {
				do {
					let errorResponse = cleanData ? try decoder.decode(UdacityErrorResponse.self, from: cleanResposneData(data: data)) : try decoder.decode(UdacityErrorResponse.self, from: data)

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

			do {
				let responseObject = try decoder.decode(ResponseType.self, from: data)

				DispatchQueue.main.async {
					completion(responseObject, nil)
				}

			} catch {
				do {
					let errorResponse = try decoder.decode(UdacityErrorResponse.self, from: data)
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
