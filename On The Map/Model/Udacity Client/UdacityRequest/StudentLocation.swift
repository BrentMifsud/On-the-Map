//
//  StudentLocation.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import Foundation
import MapKit

struct StudentLocation: Codable {
	let objectId: String
	let uniqueKey: String
	let firstName: String
	let lastName: String
	let mapString: String
	let mediaURL: String
	let latitude: Float
	let longitude: Float
	let createdAt: String
	let updatedAt: String

	func getMapAnnotation() -> MKPointAnnotation {
		let mapAnnotation = MKPointAnnotation()
		mapAnnotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
		mapAnnotation.title = "\(firstName) \(lastName)"
		mapAnnotation.subtitle = "\(mediaURL)"

		return mapAnnotation
	}
}
