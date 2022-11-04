//
//  Notifications.swift
//  Guess the Flag
//
//  Created by Nikita Novikov on 04.11.2022.
//

import UserNotifications


final class Notifications {
    static func registerNotifications(_ addNotificationRequest: Bool = false) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound], completionHandler: { granted, _ in
            if addNotificationRequest {
                addNotification()
            }
        })
    }
    
    static func addNotification() {
        let center = UNUserNotificationCenter.current()
        
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Come back and play again!"
        content.sound = .default
        
        let date = Date.now
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        
        if dateComponents.hour! > 22 {
            dateComponents.hour! = 22
            dateComponents.minute! = 0
        } else if dateComponents.hour! < 8 {
            dateComponents.hour! = 8
            dateComponents.minute! = 0
        }
        
        for weekday in 1...7 {
            let dc = DateComponents(calendar: .current, hour: dateComponents.hour!, minute: dateComponents.minute!, weekday: weekday)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            let request = UNNotificationRequest(identifier: "playAgain \(weekday)", content: content, trigger: trigger)
            center.add(request)
        }
    }
}
