//
//  Trip+CoreDataProperties.swift
//  appTest
//
//  Created by Valentin Camara on 31/07/2018.
//  Copyright © 2018 Valentin Camara. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit


extension Trip {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trip> {
        return NSFetchRequest<Trip>(entityName: "Trip")
    }

    @NSManaged public var averageSpeed: Double
    @NSManaged public var distance: Double
    @NSManaged public var endingTime: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var startingTime: NSDate?
    @NSManaged public var location: [CLLocation]?

}
