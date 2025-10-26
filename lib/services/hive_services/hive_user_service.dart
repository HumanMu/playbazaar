
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'dart:developer' as developer;
import '../../models/DTO/recent_interacted_user_dto.dart';
import '../../models/hive_models/recent_interacted_user_model.dart';

class HiveUserService extends GetxService {
  static const String _boxName = 'recentUsers';
  static bool _adaptersRegistered = false;


  Box<RecentUser>? _box;
  final _recentUsers = <RecentUser>[].obs;
  final _isInitialized = false.obs;

  bool get isInitialized => _isInitialized.value;
  RxList<RecentUser> get recentUsers => _recentUsers;

  /*@override
  void onInit() {
    super.onInit();
    init();
  }*/
  @override
  void onInit() {
    super.onInit();
    _registerAdapters();
  }

  Future<void> _openBox() async {
    try {
      _box = await Hive.openBox<RecentUser>(_boxName);
      _isInitialized.value = true;
    } catch (e) {
      debugPrint('Error opening Hive box: $e');
      _isInitialized.value = false;
    }
  }

  @override
  void onClose() {
    _box?.close();
    super.onClose();
  }

  Future<void> init() async {
    try {

      await _openBox();

      _updateRecentUsersList();
      _box?.listenable().addListener(_updateRecentUsersList);
    } catch (e) {
      developer.log('Fatal error initializing Hive', error: e);
      rethrow;
    }
  }

  Future<void> _registerAdapters() async {
    if (!_adaptersRegistered) {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(RecentUserAdapter());
      }
      _adaptersRegistered = true;
    }

    _isInitialized.value = true;
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
