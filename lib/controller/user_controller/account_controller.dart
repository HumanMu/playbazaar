import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../api/services/firestore_services.dart';
import '../../helper/sharedpreferences.dart';
import '../../utils/show_custom_snackbar.dart';


class AccountController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  RxBool isLoading = false.obs;

  Future<void> registerUser(String firstname, String lastname, String email, String password) async {
    isLoading.value = true;
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user == null) {
        showCustomSnackbar('authentication_failed'.tr, false);
        return;
      }

      bool userCreated = await FirestoreServices().createUser(firstname, lastname, email, user.uid);
      if (!userCreated) {
        showCustomSnackbar('account_succed_but_info_failed'.tr, false);
        return;
      }

      await user.sendEmailVerification();
      showCustomSnackbar('verification_email_sent'.tr, true, timing: 7);

      await _storeUserLocally(firstname, lastname, email);
      Get.offAllNamed('/emailVerification');
      showCustomSnackbar("registration_succed".tr, true);

    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e);
    } catch (e) {
      showCustomSnackbar('unexpected_result'.tr, false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _storeUserLocally(String firstname, String lastname, String email) async {
    await SharedPreferencesManager.setBool(SharedPreferencesKeys.userLoggedInKey, true);
    await SharedPreferencesManager.setString(SharedPreferencesKeys.userNameKey, firstname);
    await SharedPreferencesManager.setString(SharedPreferencesKeys.userLastNameKey, lastname);
    await SharedPreferencesManager.setString(SharedPreferencesKeys.userEmailKey, email);
  }

  void _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        showCustomSnackbar('weak_password'.tr, false);
        break;
      case 'email-already-in-use':
        showCustomSnackbar('email_already_in_use'.tr, false);
        break;
      case 'invalid-email':
        showCustomSnackbar('invalid_email_format'.tr, false);
        break;
      default:
        showCustomSnackbar('unexpected_result'.tr, false);
    }
  }


  // login
  Future<bool> loginUserWithEmailAndPassword( String email, String password) async{
    try {
      (await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password)).user!;
      return true;

    }on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          showCustomSnackbar('user_not_found'.tr, false, timing: 5);
        case 'wrong-password':
          showCustomSnackbar('unexpected_result'.tr, false, timing: 5);
        case 'too-many-requests':
          showCustomSnackbar('too_many_requests'.tr, false, timing: 5);
        default:
          showCustomSnackbar('unexpected_result'.tr, false, timing: 5);
      }
    }
    return false;
  }
}
