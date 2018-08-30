//
//  DataController.swift
//  appTest
//
//  Created by Valentin Camara on 20/07/2018.
//  Copyright © 2018 Valentin Camara. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    static func requestData() -> [Trip] {
        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
        var allData: [Trip] = []
        do {
            allData = try PersistenceService.context.fetch(fetchRequest)
        } catch {
            print("Error requestData")
        }
        return allData
    }
    
    
    
}
