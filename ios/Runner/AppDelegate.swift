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
      GeneratedPluginRegistrant.register(with: self)

      UNUserNotificationCenter.current().delegate = self
      Messaging.messaging().delegate = self

      // 4. Request notification authorization from the user (Simplified for iOS 13+)
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, error in
          if let error = error {
            print("Error requesting notification authorization: \(error.localizedDescription)")
          }
        }
      )

      application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error.localizedDescription)")
  }

  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
      // Handle background data messages
      completionHandler(.newData)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)

  }

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

