
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:playbazaar/controller/settings_controller/settings_controller.dart';
import 'package:playbazaar/games/games/quiz/screens/add_question.dart';
import 'package:playbazaar/screens/main_screens/chat_page.dart';
import 'package:playbazaar/screens/main_screens/edit_page.dart';
import 'package:playbazaar/screens/main_screens/home_page.dart';
import 'package:playbazaar/screens/main_screens/login_pages.dart';
import 'package:playbazaar/screens/main_screens/profile_page.dart';
import 'package:playbazaar/screens/main_screens/register_page.dart';
import 'package:playbazaar/screens/secondary_screens/chat_info.dart';
import 'package:playbazaar/screens/secondary_screens/email_verification_page.dart';
import 'package:playbazaar/screens/secondary_screens/policy_page.dart';
import 'package:playbazaar/screens/secondary_screens/recieved_requests.dart';
import 'package:playbazaar/screens/secondary_screens/reset_password_page.dart';
import 'package:playbazaar/screens/secondary_screens/search_page.dart';
import 'package:playbazaar/screens/secondary_screens/settings.dart';
import 'package:provider/provider.dart';
import 'api/firestore/firestore_user.dart';
import 'controller/user_controller/auth_controller.dart';
import 'games/games/quiz/main_quiz_page.dart';
import 'games/games/quiz/screens/review_question_page.dart';
import 'languages/local_strings.dart';
import 'middleware/auth_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(AuthController());
  Get.put(SettingsController());

  runApp(
    ChangeNotifierProvider(
      create: (_) => FirestoreUser()..listenToVerification(),
      child: const PlayBazaar(),
    ),
  );
}

class PlayBazaar extends StatelessWidget {
  const PlayBazaar({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());
    final settingsController = Get.put(SettingsController());

    return GetBuilder<AuthController>(
        init: authController,
        builder: (controller) {
          if (!controller.isInitialized.value || controller.language.isEmpty) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          return GetBuilder<SettingsController>(
              init: settingsController,
              builder: (settingsController) {
                if (!settingsController.isInitialized.value) {
                  return const MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                final locale = Locale(
                    controller.language[0], controller.language[1]);

                return GetMaterialApp(
                  debugShowCheckedModeBanner: false,
                  translations: LocalStrings(),
                  locale: locale,
                  initialRoute: '/profile',
                  getPages: [
                    GetPage(
                        name: '/login',
                        page: () => const LoginPage()
                    ),
                    GetPage(
                      name: '/profile',
                      page: () => const ProfilePage(),
                      middlewares: [AuthGuard()],
                    ),
                    GetPage(
                      name: '/emailVerification',
                      page: () => const EmailVerificationPage(),
                    ),
                    GetPage(
                      name: '/register',
                      page: () => const RegisterPage(),
                    ),
                    GetPage(
                      name: '/home',
                      page: () => const HomePage(),
                    ),
                    GetPage(
                      name: '/edit',
                      page: () => const EditPage(),
                    ),
                    GetPage(
                      name: '/policy',
                      page: () => const PolicyPage(),
                    ),
                    GetPage(
                        name: '/reciviedRequests',
                        page: () => const RecievedRequests()
                    ),
                    GetPage(
                        name: '/questionReviewPage',
                        page: () => const ReviewQuestionsPage()
                    ),
                    GetPage(
                        name: '/addQuestion',
                        page: () => const AddQuestion()
                    ),
                    GetPage(
                        name: '/mainQuiz',
                        page: () => const QuizMainPage()
                    ),
                    GetPage(
                        name: '/resetPassword',
                        page: () => ResetPasswordPage()
                    ),
                    GetPage(
                        name: '/settings',
                        page: () => Settings()
                    ),
                    GetPage(
                      name: '/search',
                      page: () {
                        final args = Get.arguments as Map<String, dynamic>;
                        return SearchPage(
                          searchId: args['searchId'],
                        );
                      },
                    ),
                    GetPage(
                      name: '/chat',
                      page: () {
                        final args = Get.arguments as Map<String, dynamic>;
                        return ChatPage(
                          chatId: args['chatId'],
                          chatName: args['chatName'],
                          userName: args['userName'],
                          recieverId: args['recieverId'],
                        );
                      },
                    ),
                    GetPage(
                      name: '/chatinfo',
                      page: () {
                        final args = Get.arguments as Map<String, dynamic>;
                        return ChatInfo(
                          chatId: args['chatId'],
                          chatName: args['chatName'],
                          adminName: args['adminName'],
                        );
                      },
                    ),
                  ],
                );
              }
          );
        });
  }
}
