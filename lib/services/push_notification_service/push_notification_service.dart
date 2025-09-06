import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:playbazaar/helper/pushnotification/push_notification_helper.dart';
import 'package:playbazaar/helper/sharedpreferences/sharedpreferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:playbazaar/languages/early_stage_strings.dart';
import 'package:get/get.dart';


String? initialNotificationRoute;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  final notificationHelper = PushNotificationHelper();
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  String? _activeChatUserId; // To prevent notification if chatting with the same user

  Future<void> init() async {
    await _initializeLocalNotifications();
    await _setupFirebaseMessaging();
    await Future.wait([
      _checkInitialNotification(),
      _checkNotificationLaunch(),
    ]);
  }

  Future<void> _initializeLocalNotifications() async {
    const DarwinInitializationSettings iOSInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: iOSInitSettings,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _checkNotificationLaunch() async {
    final launchDetails = await _localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      final String? payload = launchDetails.notificationResponse?.payload;
      if (payload != null) {
        // Store the route and attempt navigation after delay
        await _storeNotificationRoute(payload);
        await _attemptDeferredNavigation();
      }
    }
  }

  Future<void> _attemptDeferredNavigation() async {
    // Wait for the app to initialize
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final pendingRoute = prefs.getString('pending_notification_route');

    if (pendingRoute != null) {
      await prefs.remove('pending_notification_route');
      if (Get.context != null) {
        Get.toNamed(pendingRoute);
      } else {
        // If context still not ready, store as initial route
        initialNotificationRoute = pendingRoute;
      }
    }
  }

  Future<void> _setupFirebaseMessaging() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      final String? route = initialMessage.data['route'];
      if (route != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_notification_route', route);
      }
      _handleMessage(initialMessage);
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // Handle when app is in background and user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final String? route = message.data['route'];
      if (route != null) {
        Get.toNamed(route);
      }
    });
  }

  void _handleMessage(RemoteMessage message) {
    final String channelId = message.data['channelId'] ?? '';
    final String body = message.data['body'] ?? '';
    final String? route = message.data['route'];
    final String senderId = message.data['senderId'] ?? '';
    final String senderName = message.data['senderName'] ?? '';

    if (_activeChatUserId == senderId) {
      return; // Don't show the notification
    }

    showNotification(
      channelId: channelId,
      body: body,
      senderName: senderName,
      route: route,
    );
  }

  void _onNotificationTapped(NotificationResponse response) async {
    if (response.payload != null) {
      Get.toNamed(response.payload!);
    }
  }


  Future<void> _storeNotificationRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_notification_route', route);
  }

  Future<void> _checkInitialNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingRoute = prefs.getString('pending_notification_route');

    if (pendingRoute != null) {
      await prefs.remove('pending_notification_route');

      // Navigate if the context is ready
      if (Get.context != null) {
        Get.toNamed(pendingRoute);
      } else {
        initialNotificationRoute = pendingRoute;
      }
    }
  }

  Future<void> showNotification({
    required String channelId,
    required String body,
    required String senderName,
    String? route,
    String? title,
  }) async {

    // iOS notification details
    final DarwinNotificationDetails iOSDetails =  const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails platformDetails;
    List<String>? languageData = await SharedPreferencesManager.getStringList(
        SharedPreferencesKeys.appLanguageKey);
    final String languageCode = languageData?.first ?? 'en';

    switch (channelId) {
      case 'friend_request':
        platformDetails = NotificationDetails(
            android: PushNotificationHelper.friendRequestDetails,
            iOS: iOSDetails,
        );
        title = EarlyStageStrings.getTranslation('received_friend_request_title', languageCode);
        body = '${EarlyStageStrings.getTranslation('received_friend_request_body', languageCode)} $body';
        break;
      case 'new_message':
        platformDetails = NotificationDetails(
            android: PushNotificationHelper.messageDetails,
            iOS: iOSDetails
        );
        title ??= EarlyStageStrings.getTranslation('received_new_message_title', languageCode);
        body = '$senderName: $body';
        break;
      default:
        platformDetails = NotificationDetails(
            android: PushNotificationHelper.friendRequestDetails,
            iOS: iOSDetails
        );
        title ??= EarlyStageStrings.getTranslation('notification', languageCode);
    }

    await _localNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformDetails,
      payload: route,
    );
  }

  void activeChatWithUser(String userId) {
    _activeChatUserId = userId;
  }

  void endChat() {
    _activeChatUserId = null;
  }

}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final String? route = message.data['route'];
  if (route != null) {
    // Only store the route if the notification was interacted with
    final prefs = await SharedPreferences.getInstance();
    if (message.data['notification_clicked'] == 'true') {
      await prefs.setString('pending_notification_route', route);
    }
  }

  await NotificationService().showNotification(
    channelId: message.data['channelId'] ?? '',
    body: message.data['body'] ?? '',
    senderName: message.data['senderName'] ?? '',
    route: route,
  );
}
