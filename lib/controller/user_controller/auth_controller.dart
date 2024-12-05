import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playbazaar/services/push_notification_service/device_service.dart';
import '../../api/firestore/firestore_user.dart';
import '../../helper/sharedpreferences/sharedpreferences.dart';
import '../../global_widgets/show_custom_snackbar.dart';



class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isSignedIn = false.obs;
  var isEmailVerified = false.obs;
  var language = ['en', 'US'].obs;
  var isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAndUpdateEmailVerificationStatus();
    initializeSettings();
  }

  Future<void> initializeSettings() async {
    await _checkAuthStatus();
    await getUserLoggedInState();
    await getAppLanguage();
    isInitialized.value = true;
    update();
  }

  Future<void> checkAndUpdateEmailVerificationStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload();
      isEmailVerified.value = user.emailVerified;
      update();
    }
  }

  Future<void> _checkAuthStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload();
      isSignedIn.value = true;
      isEmailVerified.value = user.emailVerified;
    } else {
      isSignedIn.value = false;
      isEmailVerified.value = false;
    }
  }

  Future<void> getUserLoggedInState() async {
    final isLoggedIn = await SharedPreferencesManager.getBool(
        SharedPreferencesKeys.userLoggedInKey);
    isSignedIn.value = isLoggedIn ?? false;
  }

  Future<void> getAppLanguage() async {
    final languageList = await SharedPreferencesManager.getStringList(
        SharedPreferencesKeys.appLanguageKey);
    language.value = languageList ?? ['fa', 'AF'];
  }

  Future<void> setOnlineState(String status) async {
    if (FirebaseAuth.instance.currentUser != null) {
      await FirestoreUser(userId: FirebaseAuth.instance.currentUser!.uid)
          .getOnlineState(status);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      showCustomSnackbar('reset_link_sent'.tr, true);
    } catch (e) {
      showCustomSnackbar('error_occurred'.tr, false);
    }
  }


  Future logOutUser() async{
    try {
      await DeviceService().handleDeviceNotificationOnLogout();
      await FirebaseAuth.instance.signOut();
      await SharedPreferencesManager.setBool(SharedPreferencesKeys.userLoggedInKey, false);

      isSignedIn.value = false;
      isEmailVerified.value = false;
    } catch (e) {
      return null;
    }
  }

}
