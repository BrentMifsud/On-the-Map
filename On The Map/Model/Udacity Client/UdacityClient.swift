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

	private struct Auth {
		static var objectId = ""
		static var uniqueKey = ""
	}

	enum Endpoints {
		static let base = "https://onthemap-api.udacity.com/v1"

		case getStudentLocation
		case postStudentLocation

		var stringValue: String {
			switch self {
				case .getStudentLocation: return Endpoints.base + "/StudentLocation"
			case .postStudentLocation: return Endpoints.base + "StudentLocation"
			}
		}

		var url: URL {
			return URL(string: stringValue)!
		}

	}

	class func getStudentLocation(completion: @escaping ([StudentLocation]?, Error?) -> Void){
		taskForGetRequest(url: Endpoints.getStudentLocation.url, responseType: StudentLocationResponse.self) { (response, error) in
			if let response = response {
				completion(response.results, nil)
			} else {
				completion(nil, error)
			}
		}
	}

	class func postStudentLocation(firstName: String, lastName: String, mapString: String, mediaUrl: String, latitude: Float, longitude: Float, createdAt: String, updatedAt: String, completion: @escaping (Bool, Error?) -> Void) {

		let requestBody = StudentLocation(objectId: Auth.objectId, uniqueKey: Auth.uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaUrl: mediaUrl, latitude: latitude, longitude: longitude, createdAt: createdAt, updatedAt: updatedAt)

		taskForPostRequest(url: Endpoints.postStudentLocation.url, body: requestBody, responseType: PostStudentLocationResponse.self) { (response, error) in
			if let response = response {
				print(response)
				completion(true, nil)
			} else {
				completion(false, error)
			}
		}
	}
}

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

				print(String(data: data, encoding: .utf8))
				print(responseObject)

//				DispatchQueue.main.async {
//					completion(responseObject, nil)
//				}
			} catch {
				DispatchQueue.main.async {
					completion(nil, error)
				}
			}
		}
		task.resume()
		return task
	}

	class func taskForPostRequest<RequestType: Codable, ResponseType: Decodable>(url: URL, body: RequestType, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) {
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
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

				print(String(data: data, encoding: .utf8))
				print(responseObject)

//				DispatchQueue.main.async {
//					completion(responseObject, nil)
//				}
			} catch {
				DispatchQueue.main.async {
					completion(nil, error)
				}
			}
		}
		task.resume()
	}
}
