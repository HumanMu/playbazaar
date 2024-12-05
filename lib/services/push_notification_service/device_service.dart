import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playbazaar/models/DTO/push_notification_dto.dart';
import 'package:playbazaar/models/push_notification_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:playbazaar/models/DTO/device_info_dto.dart';
import 'dart:io';
import '../../helper/encryption/encrypt_string.dart';



class DeviceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> registerDevice() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      String? fcmToken = await _firebaseMessaging.getToken();
      DeviceInfo deviceInfo = await getDeviceInfo();
      String? encryptedFcm = await EncryptionHelper.encryptPassword(fcmToken?? '');

      if (userId == null) {
        if(kDebugMode) {
          print('Unable to register device: missing userId or fcmToken');
        }
        return;
      }

      PushNotificationModel device = PushNotificationModel(
        fcmToken: encryptedFcm,
        deviceId: deviceInfo.deviceId,
        fcmFriendRequest: true,
        fcmNewMessages: true,
        fcmPlayBazaar: true,
        isActive: true,  // Add this field
        lastUpdate: Timestamp.now(),
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(deviceInfo.deviceId)
          .set(device.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      if(kDebugMode){
        print('Error in registerDevice - device service');
      }
    }
  }

  // Call this method after successful login
  Future<void> handleDeviceNotificationOnLogin() async {
    try {
      // 1. Request notification permission
      bool hasPermission = await requestNotificationPermission();
      if (!hasPermission) {
        return;
      }

      // 2. Register the device
      await registerDevice();

      // 3. Set up FCM token refresh listener
      _setupTokenRefreshListener();
    } catch (e) {
      if(kDebugMode){
        print('Error in handleLogin: $e');
      }
    }
  }

  // Call this method during logout
  Future<void> handleDeviceNotificationOnLogout() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      DeviceInfo deviceInfo = await getDeviceInfo();

      if (userId != null) {
        // Mark the device as inactive and clear FCM token
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('devices')
            .doc(deviceInfo.deviceId)
            .update({
          'fcmToken': null,
          'isActive': false,
          'lastUpdate': Timestamp.now(),
        });
      }

      // Delete the FCM token from Firebase Messaging
      await _firebaseMessaging.deleteToken();
    } catch (e) {
      if(kDebugMode){
        print('Error in handleLogout: $e');
      }
    }
  }


  // Mark device as inactive on logout
  Future<bool> updateDeviceNotificationSetting(PushNotificationPermissionDto permissions) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    DeviceInfo? deviceInfo = await getDeviceInfo();
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    PushNotificationModel device = PushNotificationModel(
      fcmToken: fcmToken,
      isActive: true,
      deviceId: deviceInfo.deviceId,
      fcmFriendRequest: permissions.friendRequest,
      fcmNewMessages: permissions.message,
      fcmPlayBazaar: permissions.playBazaar,
      lastUpdate: Timestamp.now(),
    );

    if (userId != null) {
      try {
        DocumentReference deviceDoc = _firestore
            .collection('users')
            .doc(userId)
            .collection('devices')
            .doc(deviceInfo.deviceId);

        var docSnapshot = await deviceDoc.get();
        if(docSnapshot.exists) {
          await userCollection.doc(userId).collection('devices')
          .doc(deviceInfo.deviceId).update(device.toFirestore());
        }
        else{
          await userCollection.doc(userId).collection('devices')
              .doc(deviceInfo.deviceId).set(device.toFirestore());
        }
        return true;
      }catch(e){
        return false;
      }
    }
    return false;
  }

  // Set up token refresh listener
  void _setupTokenRefreshListener() {
    _firebaseMessaging.onTokenRefresh.listen((String token) async {
      try {
        String? userId = FirebaseAuth.instance.currentUser?.uid;
        DeviceInfo deviceInfo = await getDeviceInfo();

        if (userId != null) {
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('devices')
              .doc(deviceInfo.deviceId)
              .update({
            'fcmToken': token,
            'lastUpdate': Timestamp.now(),
          });
        }
      } catch (e) {
        if(kDebugMode){
          print('Error in refresh listner: $e');
        }
      }
    });
  }


  Future<DeviceInfo> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return DeviceInfo(
          deviceId: androidInfo.id,
          deviceModel: androidInfo.model,
        );
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return DeviceInfo(
          deviceId: iosInfo.identifierForVendor ?? 'unknown_ios_id',
          deviceModel: iosInfo.model,
        );
      } else {
        return DeviceInfo(
          deviceId: 'unknown_platform_id',
          deviceModel: 'unknown_platform_model',
        );
      }
    } catch (e) {
      return DeviceInfo(
        deviceId: 'error_device_id',
        deviceModel: 'error_device_model',
      );
    }
  }

  Future<bool> requestNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      var status = await Permission.notification.status;
      if (status.isDenied) {
        status = await Permission.notification.request();
        return status.isGranted;
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
        status = await Permission.notification.status;
        return status.isGranted;
      }
      return status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        status = await Permission.notification.request();
      }
      // If denied, notify user to go to settings manually
      if (status.isPermanentlyDenied || status.isDenied) {
        await openAppSettings(); // Direct to settings if permanently denied
        status = await Permission.notification.status;
      }
      return status.isGranted;
    }
    return false;
  }



  void dispose() {
    return;
  }

}




