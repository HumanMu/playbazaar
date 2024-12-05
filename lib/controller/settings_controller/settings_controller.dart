
import 'package:get/get.dart';
import 'package:playbazaar/models/DTO/push_notification_dto.dart';
import 'package:playbazaar/services/push_notification_service/device_service.dart';
import 'package:playbazaar/global_widgets/show_custom_snackbar.dart';
import '../../helper/sharedpreferences/sharedpreferences.dart';
final DeviceService _deviceTokenService = DeviceService();



class SettingsController extends GetxController {
  var isInitialized = false.obs;
  var isButtonSoundsEnabled = true.obs;
  var isFriendRequestNotificationEnabled = false.obs;
  var isMessageNotificationEnabled = false.obs;
  var isPlayBazaarNotificationEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    // Load all preferences
    final buttonSounds = await SharedPreferencesManager.getBool(SharedPreferencesKeys.buttonSounds);
    final friendRequests = await SharedPreferencesManager.getBool(SharedPreferencesKeys.friendRequestNotificationsKey);
    final messageNotifications = await SharedPreferencesManager.getBool(SharedPreferencesKeys.messageNotificationsKey);
    final playBazaarNotifications = await SharedPreferencesManager.getBool(SharedPreferencesKeys.playBazaarNotificationsKey);

    // Set values with fallback to true if null
    isButtonSoundsEnabled.value = buttonSounds ?? true;
    isFriendRequestNotificationEnabled.value = friendRequests ?? false;
    isMessageNotificationEnabled.value = messageNotifications ?? false;
    isPlayBazaarNotificationEnabled.value = playBazaarNotifications ?? false;

    isInitialized.value = true;
    update();
  }

  Future<void> toggleButtonSounds() async {
    isButtonSoundsEnabled.value = !isButtonSoundsEnabled.value;
    await SharedPreferencesManager.setBool(
        SharedPreferencesKeys.buttonSounds,
        isButtonSoundsEnabled.value
    );
    update();
  }

  Future<void> toggleFriendRequestNotifications() async {
    isFriendRequestNotificationEnabled.value = !isFriendRequestNotificationEnabled.value;
    update();
  }

  Future<void> toggleMessageNotifications() async {
    isMessageNotificationEnabled.value = !isMessageNotificationEnabled.value;
    update();
  }

  Future<void> saveNotificationSettings() async{
    if(isFriendRequestNotificationEnabled.value) {
      bool permissionResult = await _deviceTokenService.requestNotificationPermission();
      if(permissionResult) {
        PushNotificationPermissionDto permissions = PushNotificationPermissionDto(
            friendRequest: isFriendRequestNotificationEnabled.value,
            message: isMessageNotificationEnabled.value,
            playBazaar: isPlayBazaarNotificationEnabled.value,
        );
        bool savePermissions = await _deviceTokenService.updateDeviceNotificationSetting(permissions);
        if(savePermissions){
          saveSharedPreferences();
        }
      }

    }
  }

  Future<void> saveSharedPreferences() async {
    try{
      await SharedPreferencesManager.setBool(
          SharedPreferencesKeys.messageNotificationsKey,
          isMessageNotificationEnabled.value
      );
      await SharedPreferencesManager.setBool(
          SharedPreferencesKeys.friendRequestNotificationsKey,
          isFriendRequestNotificationEnabled.value
      );
      await SharedPreferencesManager.setBool(
          SharedPreferencesKeys.playBazaarNotificationsKey,
          isPlayBazaarNotificationEnabled.value
      );
    }catch(e){
      showCustomSnackbar("You may logout and login again before your changes work correct", false);
    }
  }
}

