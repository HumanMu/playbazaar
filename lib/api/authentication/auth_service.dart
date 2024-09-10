import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../helper/sharedpreferences.dart';
import '../../shared/show_custom_snackbar.dart';
import '../firestore/firestore_user.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // login
  Future loginUserWithEmailAndPassword( String email, String password) async{
    try {
      User user = (await firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password)).user!;
      return true;

    }on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          showCustomSnackbar('user_not_found'.tr, false, timing: 5);
        case 'wrong-password':
          showCustomSnackbar('not_expected_result'.tr, false, timing: 5);
        case 'too-many-requests':
          showCustomSnackbar('too_many_requests'.tr, false, timing: 5);
        default:
          showCustomSnackbar('not_expected_result'.tr, false, timing: 5);
      }
    }
  }


  // register
  Future registerUserWithEmailAndPassword(
    String firstname, String lastname, String email, String password,) async{
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if(user != null) {
        await FirestoreUser(userId: user.uid ).saveUserData(firstname, lastname, email);
        user.sendEmailVerification().then((value) => showCustomSnackbar('verification_email_sent'.tr, true, timing: 7));
      }

      return true;
    }on FirebaseAuthException catch(e) {
      if(e.code == 'weak-password'){
        showCustomSnackbar('too_weak_password'.tr, false, timing: 5);
      }
      else if(e.code == 'email-already-in-use') {
        showCustomSnackbar('email_exist'.tr, false, timing: 5);
      }
      else{
        showCustomSnackbar('not_expected_result'.tr, false, timing: 5);
      }
    }
  }


  // logout
  Future logOutUser() async{
    try {
      await SharedPreferencesManager.setBool(SharedPreferencesKeys.userLoggedInKey, false);
      await SharedPreferencesManager.setString(SharedPreferencesKeys.userNameKey, "");
      await SharedPreferencesManager.setString(SharedPreferencesKeys.userEmailKey, "");
      await SharedPreferencesManager.setString(SharedPreferencesKeys.userRoleKey,"");
      await firebaseAuth.signOut();
    } catch (e) {
      return null;
    }
  }

}