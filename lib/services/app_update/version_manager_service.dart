import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class VersionManagerService {
  SharedPreferences? _prefs;
  PackageInfo? _packageInfo;
  bool _isInitialized = false;

  static const String _lastSeenVersionKey = 'last_seen_app_version';

  // Singleton pattern
  VersionManagerService._();
  static final VersionManagerService _instance = VersionManagerService._();
  factory VersionManagerService() => _instance;

  /// Initialize the service - safe to call multiple times
  Future<void> init() async {
    if (_isInitialized) {
      debugPrint('⚠️ VersionManager already initialized, skipping...');
      return;
    }

    debugPrint('🔧 Initializing VersionManager...');
    _prefs = await SharedPreferences.getInstance();
    _packageInfo = await PackageInfo.fromPlatform();

    _isInitialized = true;
    debugPrint('✅ VersionManager initialized');
    debugPrint('   Current version: ${_packageInfo!.version}');
    debugPrint('   Last seen: ${_prefs!.getString(_lastSeenVersionKey)}');
  }

  /// Ensure service is initialized before use
  void _ensureInitialized() {
    if (!_isInitialized || _prefs == null || _packageInfo == null) {
      throw StateError(
          'VersionManagerService not initialized. Call init() first in AppInitializer.'
      );
    }
  }

  /// Check if there's a new version that user hasn't seen
  bool hasNewVersion() {
    _ensureInitialized();

    final currentVersion = _packageInfo!.version;
    final lastSeenVersion = _prefs!.getString(_lastSeenVersionKey);

    // If no last seen version, this is first time - save and return false
    if (lastSeenVersion == null) {
      debugPrint('📱 First version tracking: $currentVersion');
      return false;
    }

    final hasNew = lastSeenVersion != currentVersion;

    debugPrint('📱 Version Check:');
    debugPrint('   Current: $currentVersion');
    debugPrint('   Last Seen: $lastSeenVersion');
    debugPrint('   Has New: $hasNew');

    return hasNew;
  }

  /// Get current app version
  String getCurrentVersion() {
    _ensureInitialized();
    return _packageInfo!.version;
  }

  /// Get last seen version (null if first time)
  String? getLastSeenVersion() {
    _ensureInitialized();
    return _prefs!.getString(_lastSeenVersionKey);
  }

  /// Mark current version as seen by user
  Future<void> markVersionAsSeen() async {
    _ensureInitialized();
    await _prefs!.setString(_lastSeenVersionKey, _packageInfo!.version);
    debugPrint('✅ Version ${_packageInfo!.version} marked as seen');
  }

  /// For testing: clear last seen version to simulate update
  Future<void> clearLastSeenVersion() async {
    _ensureInitialized();
    await _prefs!.remove(_lastSeenVersionKey);
    debugPrint('🧪 Test: Cleared last seen version');
  }

  /// For testing: get all debug info
  String getDebugInfo() {
    _ensureInitialized();
    return '''
      === VERSION MANAGER DEBUG ===
      Initialized: $_isInitialized
      Current Version: ${_packageInfo!.version}
      Last Seen Version: ${_prefs!.getString(_lastSeenVersionKey) ?? 'null'}
      Has New Version: ${hasNewVersion()}
      ============================
      ''';
  }
}