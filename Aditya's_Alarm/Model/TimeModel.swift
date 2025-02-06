//
//  TimeModel.swift
//  Aditya's_Alarm
//
//  Created by aditya sharma on 04/02/25.
//

class TimeModel {
    var hour: String
    var minute: String
    var amPm: String
    var isActive: Bool // Add isActive property to track the alarm's state
    
    init(hour: String, minute: String, amPm: String, isActive: Bool) {
        self.hour = hour
        self.minute = minute
        self.amPm = amPm
        self.isActive = isActive
    }
}
