import 'dart:async';
import 'package:advertising_id/advertising_id.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:playbazaar/controller/language_controller/language_controller.dart';
import 'config/firebase_options.dart';
import 'config/routes/router_provider.dart';
import 'core/dialog/dialog_listner.dart';
import 'languages/local_strings.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  unawaited(MobileAds.instance.initialize());
  final language = Get.put(LanguageController(), permanent: true);
  await language.loadLanguage();


  runApp(
    ProviderScope(
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          translations: LocalStrings(),
          locale: Get.find<LanguageController>().getCurrentLocale(),
          home: const PlayBazaar(),
        ),
    ),
  );
}

class PlayBazaar extends ConsumerWidget {
  const PlayBazaar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      locale: Get.find<LanguageController>().getCurrentLocale(),
      supportedLocales: const [
        Locale('en'),
        Locale('fa'),
        Locale('ar'),
        Locale('da'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return DialogListener(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}




