// route_manager_controller.dart
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_controller/auth_controller.dart';

class RouteManagerController extends GetxController {
  final RxString initialRoute = '/splash'.obs;
  final RxBool isRouteInitialized = false.obs;
  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final notificationAppLaunch = await flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();

    String? pendingRoute;
    if (notificationAppLaunch != null && notificationAppLaunch.didNotificationLaunchApp) {
      final prefs = await SharedPreferences.getInstance();
      pendingRoute = prefs.getString('pending_notification_route');

      if (pendingRoute != null) {
        // A specific route from a notification is found, use it.
        initialRoute.value = pendingRoute;
        prefs.remove('pending_notification_route');
      }
    }

    // 2. Check Login Status (If no pending notification route was set)
    if (initialRoute.value == '/splash') {
      if (_authController.isSignedIn.value) {
        initialRoute.value = '/profile'; // Or your main app page
      } else {
        initialRoute.value = '/login';
      }
    }

    // 3. Signal that the route determination is complete
    isRouteInitialized.value = true;
  }
}