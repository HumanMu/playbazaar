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



class DeviceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  CollectionReference userCollection = FirebaseFirestore.instance.collection('users');


  Future<void> registerDevice() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    DeviceInfo? deviceInfo = await getDeviceInfo(); // Use package like device_info_plus


    PushNotificationModel device = PushNotificationModel(
        fcmToken: fcmToken,
        deviceId: deviceInfo.deviceId,
        fcmFriendRequest: true,
        fcmNewMessages: true,
        fcmPlayBazaar: true,
        lastUpdate: Timestamp.now(),
    );


    if (userId != null && fcmToken != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(deviceInfo.deviceId)
          .set(device.toFirestore());
    }
  }

  // Mark device as inactive on logout
  Future<bool> updateDeviceNotificationSetting(PushNotificationPermissionDto permissions) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    DeviceInfo? deviceInfo = await getDeviceInfo();
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    PushNotificationModel device = PushNotificationModel(
      fcmToken: fcmToken,
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




