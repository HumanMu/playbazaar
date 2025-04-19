import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playbazaar/services/push_notification_service/device_service.dart';
import '../../api/services/firestore_services.dart';
import '../../helper/sharedpreferences/sharedpreferences.dart';
import '../../global_widgets/show_custom_snackbar.dart';
import '../../models/DTO/user_profile_dto.dart';



class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  var isSignedIn = false.obs;
  var isEmailVerified = false.obs;
  var isInitialized = false.obs;
  RxList<String> language = ['en', 'US'].obs;



  @override
  void onInit() {
    super.onInit();
    checkAndUpdateEmailVerificationStatus();
    initializeSettings();
  }

  Future<void> initializeSettings() async {
    await checkAuthStatus();
    await getUserLoggedInState();
    await getAppLanguage();
    isInitialized.value = true;
    update();
  }

  Future<void> getAppLanguage() async {
    final languageList = await SharedPreferencesManager.getStringList(
        SharedPreferencesKeys.appLanguageKey);
    language.value = languageList ?? ['en', 'US'];
    update();
  }

  Future<void> updateLanguage(List<String> newLanguage) async {
    await SharedPreferencesManager.setStringList(
        SharedPreferencesKeys.appLanguageKey,
        newLanguage
    );
    language.value = newLanguage;
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


  Future<void> checkAuthStatus() async {
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

  Future<void> setOnlineState(String status) async {
    if (FirebaseAuth.instance.currentUser != null) {
      return await _db.collection('users').doc(_auth.currentUser!.uid).update({
        'availabilityState': status
      });
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

  Future<bool> createUser(String fullname, String email) async {
    return await FirestoreServices().createUser(
        fullname,
        email,
        _auth.currentUser!.uid
    );
  }

  Future<bool> editUserAuthentication(UserProfileModel data) async{
    return await FirestoreServices().editUserData(
        data,
        FirebaseAuth.instance.currentUser!.uid
    );
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

