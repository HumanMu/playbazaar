
import 'package:get/get.dart';



class AccountSettingsController extends GetxController {
  var isInitialized = false.obs;


  @override
  void onInit() {
    super.onInit();
    loadPreferences();
  }

  Future<void> loadPreferences() async {

    isInitialized.value = true;
    update();
  }
}