import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRouteService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<String?> getInitialNotificationRoute() async {
    final notificationAppLaunch = await _notificationsPlugin
        .getNotificationAppLaunchDetails();

    // Only proceed if app was launched from notification
    if (notificationAppLaunch != null &&
        notificationAppLaunch.didNotificationLaunchApp) {
      final prefs = await SharedPreferences.getInstance();
      final pendingRoute = prefs.getString('pending_notification_route');

      if (pendingRoute != null) {
        // Clear the pending route
        await prefs.remove('pending_notification_route');
        return pendingRoute;
      }
    }

    return null;
  }

  Future<void> savePendingRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_notification_route', route);
  }
}