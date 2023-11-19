//
//  Bill+Extras.swift
//  BillManager
//

import Foundation
import UserNotifications
import UIKit

extension Bill {

    static let notificationCategoryID = "BillNotification"


    var hasReminder: Bool {
        return (remindDate != nil)
    }
    
    var isPaid: Bool {
        return (paidDate != nil)
    }
    
    var formattedDueDate: String {
        let dateString: String
        
        if let dueDate = self.dueDate {
            dateString = dueDate.formatted(date: .numeric, time: .omitted)
        } else {
            dateString = ""
        }
        
        return dateString
    }

//        static let snoozeActionID = "snooze"
//
//        private static let alarmURL: URL = {
//            guard let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//                fatalError("Can't get URL for documentDirectory")
//            }
//            return baseURL.appendingPathComponent("ScheduledAlarm")
//        }()
        
//        static var scheduled: Bill? {
//            get {
//                guard let data = try? Data(contentsOf: alarmURL) else {
//                    return nil
//                }
//                return try? JSONDecoder().decode(Bill.self, from: data)
//            }
//
//            set {
//                if let alarm = newValue {
//                    guard let data = try? JSONEncoder().encode(alarm) else {
//                        return
//                    }
//                    try? data.write(to: alarmURL)
//                } else {
//                    try? FileManager.default.removeItem(at: alarmURL)
//                }
//
//                NotificationCenter.default.post(name: .alarmUpdated, object: nil)
//
//            }
//        }
        
        
        
       
    // A method that removes reminders. This method doesn't need any parameters.
    //safely unwraps notificationID and removes any pending notifications with that identifier from the user notification center.
    // Set notificationID and remindDate to nil.
    mutating func removeReminder() {
        if let id = notificationID {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            notificationID = nil
            remindDate = nil
        }
    }
    
    // A mutating method that schedules reminders. It should take a parameter of type Date, representing the date on which the reminder is set,
    // and an escaping completion closure that passes an updated Bill instance.
    // Implement your method on Bill for scheduling reminders. Because an escaping closure can't be used in a mutating method if it refers to
    // self, you'll need to make a copy of self (e.g. var updatedBill = self), modify it as necessary, and always return the copy in the
    // completion closure.
    mutating func scheduleRemninder(on date: Date, completion: @escaping (Bill) -> ()) {
        var updatedBill = self

        // “The first thing this method should do is remove any previous notifications scheduled for that bill by calling your method to remove reminders. This ensures that users don't get reminders that they thought had been changed.
        updatedBill.removeReminder()

        // Call your method that checks for authorization. “In the body of the completion closure, check whether permission to create notifications has been granted.“Handle lack of permissions by calling the completion closure immediately, passing the copied instance.
        authorizeIfNeeded { (granted) in
            guard granted else {
                DispatchQueue.main.async {
                    completion(updatedBill)
                }
                return
            }

            // “Make the title “Bill Reminder.” The body should be a string that displays the amount due, the payee, and the bill's due date. The category identifier is the ID you used when you registered the category.
            let content = UNMutableNotificationContent()
            content.title = "Bill Reminder"
            // “an example body string: $12.00 due to Alexis Key on 4/10/2021
            content.body = String(format: "%@, due to %@ on %@", arguments: [(updatedBill.amount ?? 0).formatted(.currency(code: "usd")), (updatedBill.payee ?? ""), updatedBill.formattedDueDate])
            
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = Bill.notificationCategoryID

            //“Create a notification trigger with the date passed into the method as a parameter.
            let triggerDateComponents = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)

            // “Create a new notification identifier (UUID().uuidString) and assign it to notificationID.”
            let notificationID = UUID().uuidString
            // “Create a new notification request with the content, trigger, and identifier.”
            let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)

            //“Add the notification request to the user notification center. If authorization has been given, modify the copy of the bill by updating its notification ID and reminder date. Finish by calling the completion closure, passing the copied instance.”
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        updatedBill.notificationID = notificationID
                        updatedBill.remindDate = date
                    }
                    DispatchQueue.main.async {
                        completion(updatedBill)
                    }
                }
            })
        }
    }

    
    // A private method that checks whether the app has authorization to display notifications.
    // It should take an escaping completion closure that takes a Boolean parameter and has no return.
    // If the app hasn't yet requested authorization, request authorization in this method.
    // Call completion at the end of all possible code paths, passing in the appropriate Boolean value
    // to indicate whether the app has permission to schedule user notifications.
    private func authorizeIfNeeded(completion: @escaping (Bool) -> ()) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                completion(true)
                
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound], completionHandler: { (granted, _) in
                    completion(granted)
                })
                
            case .ephemeral:
                // only available to app clips
                completion(false)
                
            case .denied:
                completion(false)
                
            @unknown default:
                completion(false)
            }
        }
    }
    

    

    
}

