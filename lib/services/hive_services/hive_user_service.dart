import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../controller/user_controller/user_controller.dart';
import '../../models/DTO/recent_interacted_user_dto.dart';
import '../../models/hive_models/recent_interacted_user_model.dart';

class HiveUserService extends GetxService {
  static const String _boxName = 'recentUsers';
  static const int _typeId = 0; // Make type ID a constant

  Box<RecentUser>? _box;
  final _recentUsers = <RecentUser>[].obs;
  final _isInitialized = false.obs;

  bool get isInitialized => _isInitialized.value;
  RxList<RecentUser> get recentUsers => _recentUsers;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  @override
  void onClose() {
    _box?.close();
    super.onClose();
  }

  Future<void> init() async {
    if (_isInitialized.value) return;
    try {
      try {
        await Hive.initFlutter();
      } catch (e) {
        developer.log('Hive already initialized', error: e);
      }

      if (!Hive.isAdapterRegistered(_typeId)) {
        Hive.registerAdapter(RecentUserAdapter());
      }

      try {
        await Hive.box<RecentUser>(_boxName).close();
      } catch (e) {
        developer.log('Box was not open', error: e);
      }

      try {
        _box = await Hive.openBox<RecentUser>(_boxName);
      } catch (e) {
        developer.log('Error opening box, attempting to delete and recreate', error: e);
        await Hive.deleteBoxFromDisk(_boxName);
        _box = await Hive.openBox<RecentUser>(_boxName);
      }

      _updateRecentUsersList();
      _box?.listenable().addListener(_updateRecentUsersList);
      _isInitialized.value = true;
    } catch (e) {
      developer.log('Fatal error initializing Hive', error: e);
      rethrow;
    }
  }

  void _updateRecentUsersList() {
    if (_box == null) return;

    final users = _box!.values.toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    _recentUsers.value = users;
  }

  Future<void> addOrUpdateRecentUser(RecentInteractedUserDto dto) async {
    if (!_isInitialized.value) {
      await init();
    }

    if (_box == null) {
      throw Exception('Hive box not initialized');
    }

    final existingUser = _box!.get(dto.uid);
    final RecentUser recentUser;

    if (existingUser != null) {
      recentUser = existingUser.copyWith(
          lastMessage: dto.lastMessage,
          lastMessageTime: dto.timestamp.toDate(),
          avatarImage: dto.avatarImage,
          friendshipStatus: dto.friendshipStatus,
          chatId: dto.chatId
      );
    } else {
      recentUser = RecentUser.fromDto(dto);
    }

    await _box!.put(dto.uid, recentUser);

    // Maintaining a limit of recent users - last 50
    if (_box!.length > 50) {
      final sortedKeys = _box!.keys.toList()
        ..sort((a, b) {
          final userA = _box!.get(a);
          final userB = _box!.get(b);
          if (userA == null || userB == null) return 0;
          return (userB.lastMessageTime).compareTo(userA.lastMessageTime);
        });

      for (var i = 50; i < sortedKeys.length; i++) {
        await _box!.delete(sortedKeys[i]);
      }
    }
  }

  List<RecentInteractedUserDto> getRecentUsers() {
    if (!_isInitialized.value || _box == null) return [];
    return _recentUsers.map((user) => user.toDto()).toList();
  }

  RecentInteractedUserDto? getRecentUser(String uid) {
    if (!_isInitialized.value || _box == null) return null;
    final user = _box!.get(uid);
    return user?.toDto();
  }

  Future<void> deleteRecentUser(String uid) async {
    if (!_isInitialized.value || _box == null) return;
    await _box!.delete(uid);
  }

  Future<void> clearRecentUsers() async {
    if (!_isInitialized.value || _box == null) return;
    await _box!.clear();
  }
}