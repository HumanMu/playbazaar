
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:playbazaar/controller/settings_controller/settings_controller.dart';
import 'package:playbazaar/controller/user_controller/user_controller.dart';
import 'package:playbazaar/games/games/quiz/screens/add_question.dart';
import 'package:playbazaar/games/games/quiz/screens/quiz_play_page.dart';
import 'package:playbazaar/screens/main_screens/group_chat_page.dart';
import 'package:playbazaar/screens/main_screens/edit_page.dart';
import 'package:playbazaar/screens/main_screens/home_page.dart';
import 'package:playbazaar/screens/main_screens/login_pages.dart';
import 'package:playbazaar/screens/main_screens/private_chat_page.dart';
import 'package:playbazaar/screens/main_screens/profile_page.dart';
import 'package:playbazaar/screens/main_screens/register_page.dart';
import 'package:playbazaar/screens/secondary_screens/chat_info.dart';
import 'package:playbazaar/screens/secondary_screens/email_verification_page.dart';
import 'package:playbazaar/screens/secondary_screens/policy_page.dart';
import 'package:playbazaar/screens/secondary_screens/friends_list.dart';
import 'package:playbazaar/screens/secondary_screens/reset_password_page.dart';
import 'package:playbazaar/screens/secondary_screens/search_page.dart';
import 'package:playbazaar/screens/secondary_screens/settings_page.dart';
import 'package:playbazaar/services/hive_services/hive_user_service.dart';
import 'package:playbazaar/services/user_services.dart';
import 'package:provider/provider.dart';
import 'admob/ad_manager_services.dart';
import 'api/firestore/firestore_user.dart';
import 'controller/message_controller/private_message_controller.dart';
import 'controller/user_controller/auth_controller.dart';
import 'games/games/quiz/main_quiz_page.dart';
import 'games/games/quiz/screens/review_question_page.dart';
import 'helper/encryption/secure_key_storage.dart';
import 'languages/local_strings.dart';
import 'middleware/auth_guard.dart';
import 'package:playbazaar/services/push_notification_service/push_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AdManagerService().initialize();

  final notificationService = NotificationService();
  await notificationService.init();

  await dotenv.load(fileName: "assets/config/.env");
  SecureKeyStorage secureStorage = SecureKeyStorage();
  String key = dotenv.env['AES_KEY'] ?? '';
  String iv = dotenv.env['AES_IV'] ?? '';
  await secureStorage.storeKeys(key, iv);


  await Hive.initFlutter();
  Get.put(HiveUserService());
  Get.put(AuthController(), permanent: true);
  Get.put(SettingsController(), permanent: true);
  Get.put(UserServices(), permanent: true);
  Get.put(PrivateMessageController(), permanent: true);
  Get.put(UserController(), permanent: true);

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
  State<PlayBazaar> createState() => _PlayBazaarState();
}

class _PlayBazaarState extends State<PlayBazaar> {
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    _checkNotificationLaunch();
  }

  Future<void> _checkNotificationLaunch() async {
    // First check if app was launched from notification
    final notificationAppLaunch = await FlutterLocalNotificationsPlugin()
        .getNotificationAppLaunchDetails();

    // Only proceed if app was launched from notification
    if (notificationAppLaunch != null &&
        notificationAppLaunch.didNotificationLaunchApp) {
      final prefs = await SharedPreferences.getInstance();
      final pendingRoute = prefs.getString('pending_notification_route');
      if (pendingRoute != null) {
        setState(() {
          _initialRoute = pendingRoute;
        });
        await prefs.remove('pending_notification_route');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final settingsController = Get.find<SettingsController>();
    final userController = Get.find<UserController>();

    return GetBuilder<AuthController>(
        init: authController,
        builder: (controller) {
          if (!controller.isInitialized.value ||
              controller.language.isEmpty ||
              !userController.isInitialized.value) {
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
                    controller.language[0],
                    controller.language[1]
                );
                return GetMaterialApp(
                  debugShowCheckedModeBanner: false,
                  translations: LocalStrings(),
                  locale: locale,
                  initialRoute: _initialRoute ?? '/profile',

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
                        name: '/friendsList',
                        page: () => const FriendsList()
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
                      name: '/quizPlayPlage',
                      page: () {
                        final args = Get.arguments as Map<String, dynamic>;
                        return QuizPlayScreen(
                          selectedQuiz: args['selectedPath'],
                          quizTitle: args['quizTitle'],
                          withOption: args['withOption'],
                        );
                      },
                    ),
                    GetPage(
                        name: '/resetPassword',
                        page: () => ResetPasswordPage()
                    ),
                    GetPage(
                        name: '/settings',
                        page: () => SettingsPage()
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
                      name: '/group_chat',
                      page: () {
                        final args = Get.arguments as Map<String, dynamic>;
                        return GroupChatPage(
                          chatId: args['chatId'],
                          chatName: args['chatName'],
                          userName: args['userName'],
                        );
                      },
                    ),
                    GetPage(
                      name: '/private_chat',
                      page: () {
                        final args = Get.arguments as Map<String, dynamic>;
                        return PrivateChatPage(
                          chatId: args['chatId'],
                          chatName: args['chatName'],
                          userName: args['userName'],
                          recieverId: args['receiverId'],
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
                          isPublic: args['isPublic'],
                        );
                      },
                    ),
                  ],
                  navigatorKey: Get.key,
                  onReady: () {
                    // Clear any stored routes to prevent unwanted navigation like notification navigation
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.remove('pending_notification_route');
                    });
                  },
                );
              }
          );
        });
  }
}

