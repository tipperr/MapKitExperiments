//
//  AppDelegate.swift
//  Maparron
//
//  Created by Ciaran Murphy on 5/29/24.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications


class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set the delegate for UNUserNotificationCenter
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification authorization
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { success, error in
            if let error = error {
                print("Failed to request authorization for notifications: \(error)")
            }
        }
        
        // Register for remote notifications
        application.registerForRemoteNotifications()
        
        // Configure Firebase
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        
        Messaging.messaging().token { token, error in
                if let error = error {
                    print("Error fetching FCM token: \(error)")
                    return
                }
                guard let token = token else {
                    print("FCM token is nil")
                    return
                }
                print("FCM token: \(token)")
            }
        
        return true
    }
    
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
            let token = tokenParts.joined()
            print("Device Token: \(token)")
        
        // Configure Firebase Messaging with APNs token
        Messaging.messaging().apnsToken = deviceToken
        
        Messaging.messaging().token { token, error in
                if let error = error {
                    print("Error fetching FCM token: \(error)")
                    return
                }
                guard let token = token else {
                    print("FCM token is nil")
                    return
                }
                print("FCM token: \(token)")
            }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, _ in
            guard let token = token else {
                print("No token")
                return
            }
            print("Token: \(token)")

        }
            if let fcm = Messaging.messaging().fcmToken {
                print("fcm", fcm)
            }
        }
}

//extension AppDelegate: MessagingDelegate {
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("Firebase registration token: \(String(describing: fcmToken))")
//        // Notify about received token.
//    }
//}
