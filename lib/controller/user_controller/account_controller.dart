import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playbazaar/services/collection_services.dart';
import 'package:playbazaar/services/hive_services/hive_user_service.dart';
import 'package:playbazaar/services/push_notification_service/device_service.dart';
import '../../api/services/firestore_services.dart';
import '../../global_widgets/show_custom_snackbar.dart';
import '../../global_widgets/string_return_dialog.dart';
import '../../helper/sharedpreferences/sharedpreferences.dart';


class AccountController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final collectionServices = CollectionServices();
  final hiveService = HiveUserService();

  RxBool isLoading = false.obs;



  Future<bool> registerUser(String fullname, String email, String password) async {
    isLoading.value = true;
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.toLowerCase(),
          password: password
      );
      User? user = userCredential.user;

      if (user == null) {
        showCustomSnackbar('authentication_failed'.tr, false);
        return false;
      }

      await userCredential.user!.updateProfile(
        displayName: fullname.toLowerCase(),
        photoURL: "",
      );

      bool userCreated = await FirestoreServices().createUser(fullname, email, user.uid);
      if (!userCreated) {
        showCustomSnackbar('account_succed_but_info_failed'.tr, false);
        return true;
      }

      await user.sendEmailVerification();
      showCustomSnackbar('verification_email_sent'.tr, true, timing: 7);
      Get.offAllNamed('/emailVerification');
      showCustomSnackbar("registration_succed".tr, true);
      return true;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e);
      return false;
    } catch (e) {
      showCustomSnackbar('unexpected_result'.tr, false);
      return false;
    } finally {
      isLoading.value = false;
    }
  }



  Future<void> loginUserWithEmailAndPassword( String email, String password) async{
    isLoading.value = true;
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );

      if (userCredential.user != null) {
        //bool permissionResult = await _deviceTokenService.requestLocationPermission();
        await SharedPreferencesManager.setBool(SharedPreferencesKeys.userLoggedInKey, true);
        await DeviceService().handleDeviceNotificationOnLogin();
        Get.offNamed('/profile');
      }

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
    finally{
      isLoading.value = false;
    }
  }

  Future<void> deleteMyAccount(BuildContext context) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        Get.snackbar('Error', 'No user logged in');
        return;
      }

      String? password = await showDialog<String?>(
        context: context,
        builder: (_) =>
        StringReturnDialog(
          title: "password".tr,
          description: "delete_account_reauth_description".tr,
          hintText: 'enter_your_password'.tr,
          btnApproveColor: Colors.red,
        ),
      );

      // If user cancels
      if (password == null || password.trim().isEmpty) {
        return;
      }

      // Reauthenticate with current credentials
      AuthCredential credential = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: password
      );

      await HiveUserService().clearRecentUsers();

      // Reauthenticate
      await currentUser.reauthenticateWithCredential(credential);

      // 1. Remove this user from friends' friend lists
      CollectionReference userCollection = firestore.collection("user");
      await collectionServices.deleteCollection(userCollection, 'friends', firebaseAuth.currentUser!.uid);
      await collectionServices.deleteCollection(userCollection, 'devices', firebaseAuth.currentUser!.uid);

      // 3. Delete user's main document
      await firestore.collection('users').doc(currentUser.uid).delete();

      // 4. Delete Firebase Authentication user
      await currentUser.delete();

      await FirebaseAuth.instance.signOut();
      Get.offAll('/login');
      showCustomSnackbar("account_deletion_succed".tr, true);

    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e);
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e');
    }
  }

  void _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong_password':
        showCustomSnackbar('wrong_password'.tr, false);
      case 'weak-password':
        showCustomSnackbar('weak_password'.tr, false);
        break;
      case 'email-already-in-use':
        showCustomSnackbar('email_exist'.tr, false, timing: 5);
        break;
      case 'invalid-email':
        showCustomSnackbar('invalid_email_format'.tr, false);
        break;
      default:
        showCustomSnackbar('unexpected_result'.tr, false);
    }
  }
}
