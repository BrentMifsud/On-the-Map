//
//  StudentLocations.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import Foundation

class StudentLocations {
	static var locations = [StudentLocation]()

	class func refreshStudentLocations(completion: @escaping (Error?) -> Void) {
		UdacityClient.getStudentLocation(startingRecord: 0) { (studentLocations, error) in
			guard error == nil else {
				completion(error)
				return
			}

			StudentLocations.locations = studentLocations

			completion(nil)
		}
	}

	class func getMoreStudentLocations(startingRecord: Int, completion: @escaping (Error?) -> Void) {
		guard StudentLocations.locations.count > 0 else { return }
		guard StudentLocations.locations.count % 100 == 0 else { return }

		UdacityClient.getStudentLocation(startingRecord: startingRecord) { (studentLocations, error) in
			guard error == nil else {
				completion(error)
				return
			}

			StudentLocations.locations.append(contentsOf: studentLocations)

			completion(nil)
		}
	}
}
