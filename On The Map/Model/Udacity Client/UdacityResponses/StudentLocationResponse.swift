//
//  StudentLocationResponse.swift
//  On The Map
//
//  Created by Brent Mifsud on 2019-06-02.
//  Copyright © 2019 Brent Mifsud. All rights reserved.
//

import Foundation

struct StudentLocationResponse: Codable {
	let results: [StudentLocation]
}
