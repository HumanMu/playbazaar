import Flutter
import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()

      UNUserNotificationCenter.current().delegate = self

      Messaging.messaging().delegate = self
      
      application.registerForRemoteNotifications()

      GeneratedPluginRegistrant.register(with: self) // only this existed inside the Bool before cloud messaging

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  // None of the below existed before cloud messaging


   // Handle incoming push notifications when app is in foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Show the notification alert, sound, and badge even when app is in the foreground
    completionHandler([.alert, .sound, .badge])
  }

  // Handle what happens when a user taps on the notification when the app is in the background or terminated
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    // Here you can handle how you want to navigate or handle data when user taps on the notification
    completionHandler()
  }

  // Firebase Messaging Delegate method to handle FCM token refresh
 func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(String(describing: fcmToken))")

    // You can send the FCM token to your server or store it in Firestore
    if let token = fcmToken {
      // Save token to Firestore or update backend
      saveDeviceToken(token)
    }
  }

  // Function to save the FCM token (example implementation, replace with actual saving logic)
  func saveDeviceToken(_ token: String) {
    // Save the token in Firestore or send it to your backend server
    print("Device token saved: \(token)")
  }

}
