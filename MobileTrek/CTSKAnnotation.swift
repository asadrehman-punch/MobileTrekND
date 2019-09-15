//
//  CTSKAnnotation.swift
//  MobileTrek
//
//  Created by Steven Fisher on 4/24/17.
//  Copyright © 2017 RecoveryTrek. All rights reserved.
//

import UIKit

class CTSKAnnotation: NSObject, MKAnnotation {
	var coordinate: CLLocationCoordinate2D
	
	init(coordinate: CLLocationCoordinate2D) {
		self.coordinate = coordinate
	}
}
