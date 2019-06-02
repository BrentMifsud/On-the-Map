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

	enum Endpoints {
		static let base = "https://onthemap-api.udacity.com/v1"

		case getStudentLocation

		var stringValue: String {
			switch self {
				case .getStudentLocation: return Endpoints.base + "/StudentLocation"
			}
		}

		var url: URL {
			return URL(string: stringValue)!
		}

	}

	class func getStudentLocation(completion: (StudentLocation?, Error?) -> Void){

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
	}
}
