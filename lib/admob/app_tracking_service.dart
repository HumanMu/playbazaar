import 'package:permission_handler/permission_handler.dart';

class AppTrackingService {

  // Request App Tracking Transparency permission
  static Future<bool> requestTrackingPermission() async {
    final status = await Permission.appTrackingTransparency.request();
    return status == PermissionStatus.granted;
  }

  // Check current ATT status
  static Future<PermissionStatus> getTrackingStatus() async {
    return await Permission.appTrackingTransparency.status;
  }

  // Check if ATT is available (iOS 14.5+)
  static Future<bool> isTrackingAvailable() async {
    return await Permission.appTrackingTransparency.isRestricted == false;
  }
}