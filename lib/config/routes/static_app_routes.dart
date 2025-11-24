abstract class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const profile = '/profile';
  static const emailVerification = '/emailVerification';
  static const register = '/register';
  static const home = '/home';
  static const edit = '/edit';
  static const policy = '/policy';
  static const friendsList = '/friendsList';
  static const mainGames = '/mainGames';
  static const ludoHome = '/ludoHome';
  // LudoPlayScreen arguments are now query parameters
  static const ludoPlayScreen = '/ludoPlayScreen';
  static const mainQuiz = '/mainQuiz';
  static const hangman = '/hangman';
  static const hangmanPlaySettings = '/hangmanPlaySettings';
  static const hangmanAddWords = '/hangmanAddWords';
  static const questionReviewPage = '/questionReviewPage';
  static const addQuestion = '/addQuestion';
  // OptionizedPlayScreen arguments are now query parameters
  static const optionizedPlayScreen = '/optionizedPlayScreen';
  // NoneOptionizedPlayScreen arguments are now query parameters
  static const noneOptionizedPlayScreen = '/noneOptionizedPlayScreen';
  static const wordConnectorPlayScreen = '/wordConnectorPlayScreen';
  static const wordConnectorSettingScreen = '/wordConnectorSettingScreen';
  static const addWordConnectorScreen = '/addWordConnectorScreen';
  static const resetPassword = '/resetPassword';
  static const settings = '/settings';
  // SearchPage arguments are now a path parameter
  static const search = '/search/:searchId';
  // GroupChatPage arguments are now path/query parameters
  static const groupChat = '/group_chat/:chatId';
  // PrivateChatPage arguments are now path/query parameters
  static const privateChat = '/private_chat/:chatId';
  // ChatInfo arguments are now path/query parameters
  static const chatInfo = '/chatinfo/:chatId';
}
