import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../api/firestore/firestore_user.dart';
import '../../helper/sharedpreferences.dart';

class AuthController extends GetxController {
  var isSignedIn = false.obs;
  var isEmailVerified = false.obs;
  var language = ['fa', 'AF'].obs;
  var isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAndUpdateEmailVerificationStatus();
    initializeSettings();
  }

  Future<void> initializeSettings() async {
    await _checkAuthStatus();  // Checking auth status
    await getUserLoggedInState();
    await getAppLanguage();
    isInitialized.value = true;
    update();
  }

  Future<void> checkAndUpdateEmailVerificationStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload(); // Reload the user to get the latest status
      isEmailVerified.value = user.emailVerified;
      update();
    }
  }

  Future<void> _checkAuthStatus() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload(); // Reload to get the latest email verification status
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


  // logout
  Future logOutUser() async{
    try {
      await SharedPreferencesManager.setBool(SharedPreferencesKeys.userLoggedInKey, false);
      await SharedPreferencesManager.setString(SharedPreferencesKeys.userNameKey, "");
      await SharedPreferencesManager.setString(SharedPreferencesKeys.userLastNameKey, "");
      await SharedPreferencesManager.setString(SharedPreferencesKeys.userEmailKey, "");
      await SharedPreferencesManager.setString(SharedPreferencesKeys.userAboutMeKey, "");
      await SharedPreferencesManager.setString(SharedPreferencesKeys.userRoleKey,"");
      await FirebaseAuth.instance.signOut();
      isSignedIn.value = false;
      isEmailVerified.value = false;
    } catch (e) {
      return null;
    }
  }

}
