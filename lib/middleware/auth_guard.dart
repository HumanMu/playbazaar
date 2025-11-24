import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

/// This is using GetX which is not being used for navigation so this is should be removed when navigation with provider works
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

    return null;
  }
}
