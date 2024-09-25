import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../utils/show_custom_snackbar.dart';

class FirestoreAccount {
  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("users");

  Future<void> markUserAccessible(String userId) async {
    try {
      await userCollection.doc(userId).update({
        'isEmailVerified': true,
      });
    } catch (e) {
      showCustomSnackbar('Error marking user as inaccessible', false);
    }
  }

  Future<void> deleteUserAccount(String? userId) async {
    try {
      if (userId != null) {
        await userCollection.doc(userId).delete();
      }
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
      showCustomSnackbar('unexpected_result'.tr, false, timing: 5);
    }
  }

  Future<void> deleteInaccessibleAccounts() async {
    final DateTime now = DateTime.now();
    const Duration periodBeforeDeletion = Duration(seconds: 1);

    try {
      final querySnapshot = await userCollection
          .where('isEmailVerified', isEqualTo: false)
          .where('timestamp', isLessThanOrEqualTo: now.subtract(periodBeforeDeletion))
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      // Delete user authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final result = await user.delete();
      }

    } catch (e) {
      log("error deleting account: $e");

    }
  }


  Future<void> forceDeleteAccount() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('accountState', isEqualTo: 'inaccessible')
          .get();

      for (final doc in querySnapshot.docs) {
        final uid = doc.id; // Get the user's UID

        // Delete the document
        await doc.reference.delete();

        // Remove authentication
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.delete();
        }
      }
    } catch (e) {
      print('Error deleting forced accounts: $e');
    }
  }

  Future<void> cancelAccountDeletion(String userId) async {
    try {
      await userCollection.doc(userId).update({
        'accountState': 'accessible'
      });

    } catch (e) {
      rethrow;
    }
  }
}
