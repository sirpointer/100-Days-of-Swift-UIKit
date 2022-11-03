//
//  ViewController.swift
//  Project 21 Local Notifications
//
//  Created by Nikita Novikov on 02.11.2022.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    var launchOptions: [String: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        
        if let option = launchOptions.first {
            let ac = UIAlertController(title: option.key, message: option.value, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Yay!")
            } else {
                print("D'oh!")
            }
        }
    }
    
    func scheduleLocalNotification(remindLater: Bool) {
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = .default
        
        let trigger: UNTimeIntervalNotificationTrigger
        
        if remindLater {
            let interval: Double = 60 * 60 * 24
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        } else {
            var dateComponents = DateComponents()
            dateComponents.hour = 10
            dateComponents.minute = 30
            // let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    @objc func scheduleLocal() {
        scheduleLocalNotification(remindLater: false)
    }

    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
        let remindLater = UNNotificationAction(identifier: "remindLater", title: "Remind me later")
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, remindLater], intentIdentifiers: [])
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            
            let title: String?
            
            switch response.actionIdentifier {
                case UNNotificationDefaultActionIdentifier:
                    title = "Default identifier"
                    // user swiped to unlock
                    print("Default identifier")
                case "show":
                    title = "Show more information"
                    print("Show more information")
                case "remindLater":
                    title = nil
                    scheduleLocalNotification(remindLater: true)
                default:
                    title = nil
                    break
            }
            
            if let title = title {
                let ac = UIAlertController(title: title, message: "App was opened from notification", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default))
                present(ac, animated: true)
            }
        }
        
        completionHandler()
    }
}
