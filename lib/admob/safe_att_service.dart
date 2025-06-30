import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

// Remember: This file is just a safe way of running track transparency for admob to avoid app crash

class SafeATTService {
  static bool _initialized = false;

  /// Safe initialization that won't crash the app
  static Future<void> initializeForAdMob() async {
    if (_initialized) return;

    try {
      // Only run on iOS
      if (!Platform.isIOS) {
        _initialized = true;
        return;
      }

      // Add a small delay to ensure app is fully loaded
      await Future.delayed(const Duration(milliseconds: 500));

      // Check current status without requesting yet
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('ATT Status: $status');

      _initialized = true;
    } catch (e) {
      debugPrint('ATT initialization failed (safe to ignore): $e');
      _initialized = true; // Mark as initialized even if failed
    }
  }

  /// Request tracking permission when actually needed (e.g., before showing ads)
  static Future<bool> requestTrackingPermission() async {
    if (!Platform.isIOS) return true;

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;

      if (status == TrackingStatus.notDetermined) {
        final result = await AppTrackingTransparency.requestTrackingAuthorization();
        return result == TrackingStatus.authorized;
      }

      return status == TrackingStatus.authorized;
    } catch (e) {
      debugPrint('ATT request failed (continuing without tracking): $e');
      return false; // Continue without tracking - AdMob will work in limited ads mode
    }
  }

  /// Get current status safely
  static Future<bool> isTrackingAuthorized() async {
    if (!Platform.isIOS) return true;

    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      return status == TrackingStatus.authorized;
    } catch (e) {
      debugPrint('ATT status check failed: $e');
      return false;
    }
  }
}
