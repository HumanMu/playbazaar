import '../../helper/sharedpreferences/sharedpreferences.dart';


// English
List<String> gamePagesPath = ['Quiz', 'Hangman',];
List<String> gameNamesFarsi = ['مسابقات آزمونی', 'بازی جلاد'];
List<String> gameNamesArabic = ['قائمة الألعاب', 'لعبة الجلاد'];
List<String> gameNamesDanish = ['Quiz', 'Galgespil'];

List<String> ludoTypes = ['Online', 'Robots'];


Future<Map<String, dynamic>> getGameLanguage() async {

  //final auth = Get.find<AuthController>();
  List<String>? value = await SharedPreferencesManager.getStringList(SharedPreferencesKeys.appLanguageKey);
  List<String> gamePath;
  List<String> gameNames;

  if (value != null && value.isNotEmpty) {
    switch (value[0]) {
      case 'fa':
        gamePath = gamePagesPath;
        gameNames = gameNamesFarsi;
        break;
      case 'en':
        gamePath = gamePagesPath;
        gameNames = gamePagesPath;
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
        gameNames = gamePagesPath;
    }
  } else {
    gamePath = gamePagesPath;
    gameNames = gamePagesPath;
  }


  return {
    'gamePath': gamePath,
    'gameNames': gameNames,
  };
}