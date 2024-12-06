import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class AccountServices extends GetxService {
  Future<void> deleteMyAccount() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        Get.snackbar('Error', 'No user logged in');
        return;
      }

      // Prompt user to re-enter credentials
      await _reauthenticateUser(currentUser);

      // If reauthentication successful, proceed with deletion
      await currentUser.delete();
      await FirebaseAuth.instance.signOut();
      Get.offAll('/login');

    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Authentication failed');
    }
  }

  Future<void> _reauthenticateUser(User user) async {
    // Get current user's email (assuming email/password login)
    String? email = user.email;

    // Prompt for password
    String? password = await Get.dialog<String>(
      AlertDialog(
        title: Text('Reauthentication Required'),
        content: TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Enter your password',
          ),
          onChanged: (value) {
            // Capture password
            Get.back(result: value);
          },
        ),
      ),
    );

    if (password != null && email != null) {
      // Create credentials
      AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: password
      );

      // Reauthenticate
      await user.reauthenticateWithCredential(credential);
    } else {
      throw FirebaseAuthException(
          code: 'reauthentication-failed',
          message: 'Reauthentication cancelled'
      );
    }
  }

}