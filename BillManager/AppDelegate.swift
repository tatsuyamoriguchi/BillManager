//
//  AppDelegate.swift
//  BillManager
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    private let remindActionID = "RemindAction"
    private let markAsPaidActionID = "MarkAsPaidAction"
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let center = UNUserNotificationCenter.current()
        let remindAction = UNNotificationAction(identifier: remindActionID, title: "Remind me later.", options: [])
        let markAsPaidAction = UNNotificationAction(identifier: markAsPaidActionID, title: "Mark as paid", options: [.authenticationRequired])
        let category = UNNotificationCategory(identifier: Bill.notificationCategoryID, actions: [remindAction, markAsPaidAction], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([category])
        center.delegate = self
        
        return true
    }
    
    // Reminds the user again in an hour.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Get the notificaiton identidier from the response object.
        let id = response.notification.request.identifier
        // Get the bill associated witht the notificaiton id.
        guard var bill = Database.shared.getBill(notificationID: id) else { completionHandler(); return }
        // Determine which action the user selected
        switch response.actionIdentifier {
            // if the user has chosen to be reminded later, schedule a reminder for an hour from now by calling the bill's method for scheduling remniders.
        case remindActionID:
            let newRemindDate = Date().addingTimeInterval(60 * 60)
            bill.scheduleRemninder(on: newRemindDate) { (updatedBill) in
                // Save the updated bill.
                Database.shared.updateAndSave(updatedBill)
            }
            // if the user has chosen to mark the bill as padi, set the paid date to now and save the new data.
        case markAsPaidActionID:
            bill.paidDate = Date()
            Database.shared.updateAndSave(bill)
        default:
            break
            
        }
        completionHandler()
    }
    
    // Show the notificaiotn even when the app is in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

