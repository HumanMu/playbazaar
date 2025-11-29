import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:playbazaar/api/firestore/firestore_account.dart';
import '../../helper/sharedpreferences/sharedpreferences.dart';
import '../../global_widgets/show_custom_snackbar.dart';

class CountdownTimer extends StatefulWidget {
  const CountdownTimer({super.key});

  @override
  State<CountdownTimer> createState() => _CountdownState();
}

class _CountdownState extends State<CountdownTimer> {
  late Timer _timer;
  final Duration _countdownDuration = const Duration(minutes: 2);
  DateTime? _creationTime;
  DateTime? _endTime;
  User? _currentUser;
  late StreamSubscription<User?> _userSubscription;
  Duration? _remainingDuration;

  @override
  void initState() {
    super.initState();
    _listenToEmailVerification();
  }

  Future<void> _loadCreationTime() async {
    if (_currentUser == null) return;

    try {
      // Fetch the user's creation time from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data['timestamp'] != null) {
          final Timestamp timestamp = data['timestamp'];
          _creationTime = timestamp.toDate();

          // Set the end time to 24 hours after account creation
          _endTime = _creationTime!.add(_countdownDuration);

          _startTimer();
        }
      }
    } catch (e) {
      showCustomSnackbar('Failed to load account creation time.', false);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remainingDuration = _endTime!.difference(now);

      if (remainingDuration.isNegative) {
        _timer.cancel();
        _handleTimeUp();
      } else {
        setState(() {
          _remainingDuration = remainingDuration;
        });
      }
    });
  }

  Future<void> _handleTimeUp() async {
    await SharedPreferencesManager.setBool(SharedPreferencesKeys.userLoggedInKey, false);
    await FirestoreAccount().forceDeleteAccount();
    navigateToLogin();
  }
  void navigateToLogin() {
    context.go('/login');
  }


  void _listenToEmailVerification() {
    _userSubscription = FirebaseAuth.instance.userChanges().listen((User? user) async {
      if (user != null) {
        setState(() {
          _currentUser = user;
        });

        if (user.emailVerified) {
          _stopTimerOnEmailVerification();
        } else {
          await _loadCreationTime();
        }
      }
    });
  }

  Future<void> _stopTimerOnEmailVerification() async {
    if (_timer.isActive) {
      _timer.cancel();
    }
    showCustomSnackbar('Your email has been verified.', true);
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    _userSubscription.cancel();
    super.dispose();
  }


  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'verify_email_counter'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.amberAccent,
          ),
        ),
        Text(
          _remainingDuration != null ? _formatDuration(_remainingDuration!) : '00:00:00',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
