import 'package:get/get.dart';
import '../../controller/user_controller/auth_controller.dart';


// English
List<String> gameListPath = ['Quiz', 'Hangman',];
List<String> gameNamesFarsi = ['مسابقات آزمونی', 'بازی جلاد'];
List<String> gameNamesArabic = ['قائمة الألعاب', 'لعبة الجلاد'];
List<String> gameNamesDanish = ['Quiz', 'Galgespil'];

List<String> ludoTypes = ['Online', 'Robots'];


Future<Map<String, dynamic>> getGameLanguage() async {

  final auth = Get.find<AuthController>();
  List<String> gamePath;
  List<String> gameNames;

  if (auth.language.isNotEmpty) {
    switch (auth.language[0]) {
      case 'fa':
        gamePath = gameListPath;
        gameNames = gameNamesFarsi;
        break;
      case 'en':
        gamePath = gameListPath;
        gameNames = gameListPath;
        break;
      case 'ar':
        gamePath = gameListPath;
        gameNames = gameNamesArabic;
        break;
      case 'dk':
        gamePath = gameListPath;
        gameNames = gameNamesDanish;
        break;
      default:
        gamePath = gameListPath;
        gameNames = gameListPath;
    }
  } else {
    gamePath = gameListPath;
    gameNames = gameListPath;
  }


  return {
    'gamePath': gamePath,
    'gameNames': gameNames,
  };
}