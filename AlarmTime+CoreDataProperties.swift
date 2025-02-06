//
//  AlarmTime+CoreDataProperties.swift
//  Aditya's_Alarm
//
//  Created by aditya sharma on 06/02/25.
//
//

import Foundation
import CoreData


extension AlarmTime {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AlarmTime> {
        return NSFetchRequest<AlarmTime>(entityName: "AlarmTime")
    }

    @NSManaged public var amPm: String?
    @NSManaged public var hour: String?
    @NSManaged public var minute: String?
    @NSManaged public var isActive: Bool

}

extension AlarmTime : Identifiable {

}
