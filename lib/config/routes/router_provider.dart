
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../games/games/hangman/add_hangman_screen.dart';
import '../../games/games/hangman/hangman_play_screen.dart';
import '../../games/games/hangman/hangman_play_settings_screen.dart';
import '../../games/games/ludo/helper/enums.dart';
import '../../games/games/ludo/home_screen.dart';
import '../../games/games/ludo/play_screen.dart';
import '../../games/games/quiz/main_quiz_page.dart';
import '../../games/games/quiz/screens/add_question.dart';
import '../../games/games/quiz/screens/none_optionized_play_page.dart';
import '../../games/games/quiz/screens/optionized_play_page.dart';
import '../../games/games/quiz/screens/review_question_page.dart';
import '../../games/games/word_connector/add_words_screen.dart';
import '../../games/games/word_connector/connector_settings.dart';
import '../../games/games/word_connector/play_screen.dart';
import '../../games/main_screen_games.dart';
import '../../screens/main_screens/edit_page.dart';
import '../../screens/main_screens/group_chat_page.dart';
import '../../screens/main_screens/home_page.dart';
import '../../screens/main_screens/login_pages.dart';
import '../../screens/main_screens/private_chat_page.dart';
import '../../screens/main_screens/profile_page.dart';
import '../../screens/main_screens/register_page.dart';
import '../../screens/secondary_screens/chat_info.dart';
import '../../screens/secondary_screens/email_verification_page.dart';
import '../../screens/secondary_screens/friends_list.dart';
import '../../screens/secondary_screens/policy_page.dart';
import '../../screens/secondary_screens/reset_password_page.dart';
import '../../screens/secondary_screens/search_page.dart';
import '../../screens/secondary_screens/settings_page.dart';
import '../initializers/app_loader.dart';
import 'static_app_routes.dart';
import 'router_refresh_stream.dart';


// Global navigator key - the key to everything!
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final authServiceProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});


const authRequiredRoutes = [
  AppRoutes.profile,
  AppRoutes.home,
  AppRoutes.edit,
  AppRoutes.friendsList,
  AppRoutes.groupChat,
  AppRoutes.privateChat,
];


final routerProvider = Provider<GoRouter>((ref) {

  String? redirect(BuildContext context, GoRouterState state) {
    final path = state.uri.path;
    User? user = FirebaseAuth.instance.currentUser;

    // Check if this navigation is from a notification
    final isFromNotification = state.extra is Map &&
        (state.extra as Map)['fromNotification'] == true;

    final isAuthRequired = authRequiredRoutes.any((route) {
      // Handle routes with path parameters
      if (route.contains(':')) {
        final routePattern = route.replaceAll(RegExp(r':[^/]+'), '[^/]+');
        return RegExp('^$routePattern\$').hasMatch(path);
      }
      return path == route;
    });

    // If no user and trying to access protected route -> redirect to login
    if (user == null && isAuthRequired) {  // ✅ Use isAuthRequired here
      return AppRoutes.login;
    }

    // If user exists but email not verified -> redirect to email verification
    if (user != null && !user.emailVerified && path != AppRoutes.emailVerification) {
      return AppRoutes.emailVerification;
    }

    // If logged in with verified email and trying to access login/splash -> redirect to home
    if (user != null && user.emailVerified && (path == AppRoutes.login || path == AppRoutes.splash)) {
      if(isFromNotification) {
        return null;
      }
      return AppRoutes.splash;
    }

    return null;
  }

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: redirect,
    navigatorKey: rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const AppLoader(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.emailVerification,
        builder: (context, state) => const EmailVerificationPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.edit,
        builder: (context, state) => const EditPage(),
      ),
      GoRoute(
        path: AppRoutes.policy,
        builder: (context, state) => const PolicyPage(),
      ),
      GoRoute(
        path: AppRoutes.friendsList,
        builder: (context, state) => const FriendsList(),
      ),
      GoRoute(
        path: AppRoutes.mainGames,
        builder: (context, state) => const MainScreenGames(),
      ),
      GoRoute(
        path: AppRoutes.ludoHome,
        builder: (context, state) => LudoHomeScreen(),
      ),
      // --- Route with Query Parameters
      GoRoute(
        path: AppRoutes.ludoPlayScreen,
        builder: (context, state) {
          //final gameMode = state.uri.queryParameters['gameMode'] ?? '';
          final gameMode = GameMode.values.firstWhere(
                (e) => e.name == state.uri.queryParameters['gameMode'],
            orElse: () => GameMode.offline,
          );
          final isHost = state.uri.queryParameters['isHost'] == 'true';
          final gameCode = state.uri.queryParameters['gameCode'] ?? '';
          final numberOfPlayer = int.tryParse(state.uri.queryParameters['numberOfPlayer'] ?? '0');
          final enabledRobots = state.uri.queryParameters['enabledRobots'] == 'true';
          final teamPlay = state.uri.queryParameters['teamPlay'] == 'true';

          return LudoPlayScreen(
            gameMode: gameMode,
            isHost: isHost,
            gameCode: gameCode,
            numberOfPlayer: numberOfPlayer ?? 4,
            enabledRobots: enabledRobots,
            teamPlay: teamPlay,
          );
        },
      ),
      // --- Other Routes with Query Parameters/Path Parameters ---
      GoRoute(
        path: AppRoutes.mainQuiz,
        builder: (context, state) => const QuizMainPage(),
      ),
      GoRoute(
        path: AppRoutes.hangman,
        builder: (context, state) => HangmanPlayScreen(),
      ),
      GoRoute(
        path: AppRoutes.hangmanPlaySettings,
        builder: (context, state) => HangmanPlaySettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.hangmanAddWords,
        builder: (context, state) => AddHangmanWords(),
      ),
      GoRoute(
        path: AppRoutes.questionReviewPage,
        builder: (context, state) => const ReviewQuestionsPage(),
      ),
      GoRoute(
        path: AppRoutes.addQuestion,
        builder: (context, state) => const AddQuestion(),
      ),
      GoRoute(
        path: AppRoutes.optionizedPlayScreen,
        builder: (context, state) {
          final selectedQuiz = state.uri.queryParameters['selectedPath'] ?? '';
          final quizTitle = state.uri.queryParameters['quizTitle'] ?? '';
          return OptionizedPlayScreen(
            selectedQuiz: selectedQuiz,
            quizTitle: quizTitle,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.noneOptionizedPlayScreen,
        builder: (context, state) {
          final selectedQuiz = state.uri.queryParameters['selectedPath'] ?? '';
          final quizTitle = state.uri.queryParameters['quizTitle'] ?? '';
          return NoneOptionizedPlayScreen(
            selectedQuiz: selectedQuiz,
            quizTitle: quizTitle,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.wordConnectorPlayScreen,
        builder: (context, state) => WordConnectorPlayScreen(),
      ),
      GoRoute(
        path: AppRoutes.wordConnectorSettingScreen,
        builder: (context, state) => WordConnectorSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addWordConnectorScreen,
        builder: (context, state) => AddWordConnectorScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => ResetPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => SettingsPage(),
        // Note: GetX Bindings are handled differently in Riverpod/GoRouter.
        // Logic for dependency injection should use Riverpod providers, not bindings.
      ),
      // Route with a Path Parameter
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) {
          // Argument is a path parameter: /search/123
          final searchId = state.pathParameters['searchId'] ?? '';
          return SearchPage(
            searchId: searchId,
          );
        },
      ),
      // Route with Path Parameter and Query Parameters
      GoRoute(
        path: AppRoutes.groupChat,
        builder: (context, state) {
          final chatId = state.pathParameters['chatId'] ?? '';
          final chatName = state.uri.queryParameters['chatName'] ?? '';
          final userName = state.uri.queryParameters['userName'] ?? '';
          final isPublic = state.uri.queryParameters['isPublic'] == 'true';

          return GroupChatPage(
            chatId: chatId,
            chatName: chatName,
            userName: userName,
            isPublic: isPublic,
          );
        },
      ),
      // ... (The pattern repeats for PrivateChatPage and ChatInfo)
      GoRoute(
        path: AppRoutes.privateChat,
        builder: (context, state) {
          final chatId = state.pathParameters['chatId'] ?? '';
          final chatName = state.uri.queryParameters['chatName'] ?? '';
          final userName = state.uri.queryParameters['userName'] ?? '';
          final recieverId = state.uri.queryParameters['receiverId'] ?? '';
          return PrivateChatPage(
            chatId: chatId,
            chatName: chatName,
            userName: userName,
            recieverId: recieverId,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.chatInfo,
        builder: (context, state) {
          final chatId = state.pathParameters['chatId'] ?? '';
          final chatName = state.uri.queryParameters['chatName'] ?? '';
          final adminName = state.uri.queryParameters['adminName'] ?? '';
          final isPublic = state.uri.queryParameters['isPublic'] == 'true';
          return ChatInfo(
            chatId: chatId,
            chatName: chatName,
            adminName: adminName,
            isPublic: isPublic,
          );
        },
      ),
    ],
    // Handle errors (e.g., 404 page)
    errorBuilder: (context, state) => const Text('404 - Page Not Found'),
  );
});