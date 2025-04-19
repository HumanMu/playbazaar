import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:playbazaar/games/games/hangman/hangman_play_screen.dart';
import 'package:playbazaar/games/games/hangman/hangman_play_settings_screen.dart';
import 'package:playbazaar/games/games/ludo/play_screen.dart';
import 'package:playbazaar/games/games/quiz/screens/add_question.dart';
import 'package:playbazaar/games/games/quiz/screens/optionized_play_page.dart';
import 'package:playbazaar/games/games/word_connector/play_screen.dart';
import 'package:playbazaar/games/main_screen_games.dart';
import 'package:playbazaar/screens/main_screens/group_chat_page.dart';
import 'package:playbazaar/screens/main_screens/edit_page.dart';
import 'package:playbazaar/screens/main_screens/home_page.dart';
import 'package:playbazaar/screens/main_screens/login_pages.dart';
import 'package:playbazaar/screens/main_screens/private_chat_page.dart';
import 'package:playbazaar/screens/main_screens/profile_page.dart';
import 'package:playbazaar/screens/main_screens/register_page.dart';
import 'package:playbazaar/screens/secondary_screens/chat_info.dart';
import 'package:playbazaar/screens/secondary_screens/email_verification_page.dart';
import 'package:playbazaar/config/orientation_manager.dart';
import 'package:playbazaar/screens/secondary_screens/policy_page.dart';
import 'package:playbazaar/screens/secondary_screens/friends_list.dart';
import 'package:playbazaar/screens/secondary_screens/reset_password_page.dart';
import 'package:playbazaar/screens/secondary_screens/search_page.dart';
import 'package:playbazaar/screens/secondary_screens/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controller/settings_controller/notification_settings_controller.dart';
import '../../controller/user_controller/auth_controller.dart';
import '../../controller/user_controller/user_controller.dart';
import '../../games/games/hangman/add_hangman_screen.dart';
import '../../games/games/ludo/home_screen.dart';
import '../../games/games/quiz/main_quiz_page.dart';
import '../../games/games/quiz/screens/none_optionized_play_page.dart';
import '../../games/games/quiz/screens/review_question_page.dart';
import '../../games/games/word_connector/add_words_screen.dart';
import '../../games/games/word_connector/connector_settings.dart';
import '../../languages/local_strings.dart';
import '../../middleware/auth_guard.dart';

class AppRoutes extends StatefulWidget {
  const AppRoutes({super.key});

  @override
  State<AppRoutes> createState() => _PlayBazaarState();
}

class _PlayBazaarState extends State<AppRoutes> {
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
    final userController = Get.find<UserController>();
    OrientationManager.setPreferredOrientations(context);

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


          final settingsController = Get.put(NotificationSettingsController(), permanent: true);
          return GetBuilder<NotificationSettingsController>(
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
                        name: '/mainGames',
                        page: () => const MainScreenGames()
                    ),
                    GetPage(
                        name: '/ludoLobby',
                        page: () => LudoHomeScreen()
                    ),
                    GetPage(name: '/ludoPlayScreen',
                      page: () {
                        final args = Get.arguments as Map<String, dynamic>;
                        return LudoPlayScreen(
                          numberOfPlayer: args['numberOfPlayer'],
                          enabledRobots: args['enabledRobots'],
                          teamPlay: args['teamPlay']
                        );
                      },
                        //page: ()=> LudoPlayScreen(),
                    ),
                    GetPage(
                        name: '/mainQuiz',
                        page: () => const QuizMainPage()
                    ),
                    GetPage(
                        name: '/hangman',
                        page: () => HangmanPlayScreen()
                    ),
                    GetPage(
                        name: '/hangmanPlaySettings',
                        page: () => HangmanPlaySettingsScreen(),
                    ),
                    GetPage(
                      name: '/hangmanAddWords',
                      page: () => AddHangmanWords(),
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
                      name: '/optionizedPlayScreen',
                      page: () {
                        final args = Get.arguments as Map<String, dynamic>;
                        return OptionizedPlayScreen(
                          selectedQuiz: args['selectedPath'],
                          quizTitle: args['quizTitle'],
                          //withOption: args['withOption'],
                        );
                      },
                    ),
                    GetPage(
                      name: '/noneOptionizedPlayScreen',
                      page: () {
                        final args = Get.arguments as Map<String, dynamic>;
                        return NoneOptionizedPlayScreen(
                          selectedQuiz: args['selectedPath'],
                          quizTitle: args['quizTitle'],
                        );
                      },
                    ),
                    GetPage(
                        name: '/wordConnectorPlayScreen',
                        page: () => WordConnectorPlayScreen()
                    ),
                    GetPage(
                        name: '/wordConnectorSettingScreen',
                        page: () => WordConnectorSettingsScreen()
                    ),
                    GetPage(
                        name: '/addWordConnectorScreen',
                        page: () => AddWordConnectorScreen()
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
                          isPublic: args['isPublic'],
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

