import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../shared/show_custom_snackbar.dart';

class FirestoreAccount {
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("users");

  Future<void> markUserAsInaccessible(String userId) async {
    try {
      await userCollection.doc(userId).update({
        'accountState': 'inaccessible',
        'inaccessibilityDate': DateTime.now(),
      });
    } catch (e) {
      showCustomSnackbar('Error marking user as inaccessible', false);
    }
  }

  Future<void> deleteUserAccount(String? userId) async {
    try {
      // Delete user data from Firestore
      if (userId != null) {
        await userCollection.doc(userId).delete();
      }

      // Delete user authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
        showCustomSnackbar('account_removed_permanantly'.tr, false, timing: 7);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        await deleteInaccessibleAccounts();
      }
      rethrow;
    } catch (e) {
      showCustomSnackbar('not_expected_result'.tr, false, timing: 5);
    }
  }

  Future<void> deleteInaccessibleAccounts() async {
    final DateTime now = DateTime.now();
    const Duration periodBeforeDeletion = Duration(days: 1);

    try {
      final querySnapshot = await userCollection
          .where('accountState', isEqualTo: 'inaccessible')
          .where('timestamp', isLessThanOrEqualTo: now.subtract(periodBeforeDeletion))
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      // Delete user authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.delete();
      }

    } catch (e) {
      if(kDebugMode) {
        log("error deleting account");
      }
    }
  }

  Future<void> cancelAccountDeletion(String userId) async {
    try {
      // Update the Firestore document to mark the account as active again
      await userCollection.doc(userId).update({
        'accountState': 'accessible'
      });

      showCustomSnackbar('Your account has been reactivated as the email has been verified.', true);
    } catch (e) {
      showCustomSnackbar('Error reactivating account', false);
    }
  }
}
