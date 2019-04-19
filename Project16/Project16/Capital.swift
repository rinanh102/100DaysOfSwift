//
//  Capital.swift
//  Project16
//
//  Created by henry on 11/04/2019.
//  Copyright © 2019 HenryNguyen. All rights reserved.
//

import UIKit
import MapKit


class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String

    init(title: String, coordinate: CLLocationCoordinate2D, info: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
    }
}
