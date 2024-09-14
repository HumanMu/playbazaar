import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';


class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const RouteSettings(name: '/login');
    }

    if (!user.emailVerified) {
      return const RouteSettings(name: '/emailVerification');
    }

    // Allow access if signed in and email is verified
    return null;
  }
}
