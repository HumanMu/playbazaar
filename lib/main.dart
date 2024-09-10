import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playbazaar/screens/main_screens/login_pages.dart';
import 'package:playbazaar/screens/main_screens/profile_page.dart';
import 'package:provider/provider.dart';
import 'api/firestore/firestore_user.dart';
import 'helper/sharedpreferences.dart';
import 'languages/local_strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // If user is from a phone
  runApp(
    ChangeNotifierProvider(
      create: (_) => FirestoreUser()..listenToVerification(),
      child: const PlayBazaar(),
    ),
  );
}

class PlayBazaar extends StatefulWidget {
  const PlayBazaar({super.key});

  @override
  State<PlayBazaar> createState() => _PlayBazaar();
}

class _PlayBazaar extends State<PlayBazaar> with WidgetsBindingObserver {
  bool _isSignedIn = false;
  String email = "";
  List<String>? language;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeSettings();
  }

  Future<void> initializeSettings() async {
    await getUserLoggedInState();
    await getAppLanguage();
  }

  Future<void> getUserLoggedInState() async {
    final isLoggedIn = await SharedPreferencesManager.getBool(
        SharedPreferencesKeys.userLoggedInKey);
    setState(() {
      _isSignedIn = isLoggedIn ?? false;
    });
  }

  Future<void> getAppLanguage() async {
    final languageList = await SharedPreferencesManager.getStringList(SharedPreferencesKeys.appLanguageKey);
    setState(() {
      language = languageList ?? ['fa', 'AF'];
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setOnlineState('Online');
    } else {
      setOnlineState('Offline');
    }
  }

  Future<void> setOnlineState(String status) async {
    await FirestoreUser(userId: FirebaseAuth.instance.currentUser!.uid)
        .getOnlineState(status);
  }

  @override
  Widget build(BuildContext context) {
    if (language == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    Locale initialLocale = language!.isNotEmpty
        ? Locale(language![0], language![1])
        : const Locale('fa', 'AF');

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: LocalStrings(),
      locale: initialLocale,
      home: _isSignedIn ? const ProfilePage() : const LoginPage(),
    );
  }
}
