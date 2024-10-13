
import 'package:get/get.dart';
import '../../helper/sharedpreferences/sharedpreferences.dart';

class SettingsController extends GetxController {
  var isInitialized = false.obs;
  var isButtonSoundsEnabled = true.obs;


  @override
  void onInit() {
    super.onInit();
    _loadButtonSoundPreference();
  }

  Future<void> _loadButtonSoundPreference() async {
    final prefs = await SharedPreferencesManager.getBool(SharedPreferencesKeys.buttonSounds);
    isButtonSoundsEnabled.value = prefs ?? true;
    isInitialized.value = true;
    update();
  }

  Future<void> toggleButtonSounds() async {
    isButtonSoundsEnabled.value = !isButtonSoundsEnabled.value;

    await SharedPreferencesManager.setBool(SharedPreferencesKeys.buttonSounds, isButtonSoundsEnabled.value);
    update();

  }

}