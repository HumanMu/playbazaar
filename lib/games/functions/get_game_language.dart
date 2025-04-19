import 'package:get/get.dart';
import '../../controller/user_controller/auth_controller.dart';


// English
//List<String> gamePagesPath = ['Quiz', 'Hangman'];
List<String> gamePagesPath = ['quiz', 'ludo_missions', 'hangman', 'wordconnector', 'brain_teaser',];
List<String> gamePagesEn = ['quiz', 'hangman', 'wordconnector'];
List<String> gameNamesFarsi = ['مسابقات آزمونی', 'لودو', 'بازی جلاد', 'پیوند حروف', 'چیستان',];
List<String> gameNamesArabic = ['قائمة الألعاب', 'لودو', 'لعبة الجلاد', 'ربط الحروف'];
List<String> gameNamesDanish = ['Quiz', 'Ludo', 'Galgespil', 'Word Connector'];

List<String> ludoTypes = ['Online', 'Robots'];


Future<Map<String, dynamic>> getGameLanguage() async {

  final authController = Get.find<AuthController>();
  //List<String>? value = await SharedPreferencesManager.getStringList(SharedPreferencesKeys.appLanguageKey);
  List<String> gamePath;
  List<String> gameNames;

    switch (authController.language[0]) {
      case 'fa':
        gamePath = gamePagesPath;
        gameNames = gameNamesFarsi;
        break;
      case 'en':
        gamePath = gamePagesPath;
        gameNames = gamePagesEn;
        break;
      case 'ar':
        gamePath = gamePagesPath;
        gameNames = gameNamesArabic;
        break;
      case 'dk':
        gamePath = gamePagesPath;
        gameNames = gameNamesDanish;
        break;
      default:
        gamePath = gamePagesPath;
        gameNames = gamePagesEn;
    }


  return {
    'gamePath': gamePath,
    'gameNames': gameNames,
  };
}