import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../utils/show_custom_snackbar.dart';
import '../firestore/firestore_user.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

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

  Future<Object?> createFirebaseAuthentication(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      return e;
    }
  }

  // register
  Future<User?> registerUserWithEmailAndPassword(
      String firstname, String lastname, String email, String password) async{
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      //return userCredential.user; // New method
      User? user = userCredential.user;

      if(user != null) {
        await  FirestoreUser(userId: user.uid ).createUser(firstname, lastname, email);
        user.sendEmailVerification().then((value) => showCustomSnackbar('verification_email_sent'.tr, true, timing: 7));
      }

    }on FirebaseAuthException catch(e) {
      if(e.code == 'weak-password'){
        showCustomSnackbar('too_weak_password'.tr, false, timing: 5);
      }
      else if(e.code == 'email-already-in-use') {
        showCustomSnackbar('email_exist'.tr, false, timing: 5);
      }
      else{
        showCustomSnackbar('unexpected_result'.tr, false, timing: 5);
      }
    }
    return null;

  }



  Future<void> sendVerificationEmail(User user) async {
    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }


}