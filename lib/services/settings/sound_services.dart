import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../controller/settings_controller/notification_settings_controller.dart';

class SoundService extends GetxService {
  final NotificationSettingsController settingsController = Get.find<NotificationSettingsController>();
  late final AudioPlayer _player;

  @override
  void onInit() {
    super.onInit();
    _player = AudioPlayer();
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }

  Future<void> playSound(String path) async {
    if (!settingsController.isButtonSoundsEnabled.value) return;

    try {
      await _player.setAsset(path);
      await _player.play();
    } catch (e) {
      if (kDebugMode) print("Error playing button sound: $e");
    }
  }
}
