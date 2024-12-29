import 'package:get/get.dart';
import '../../controller/user_controller/auth_controller.dart';


List<String> difficultyNiveaAll = ['easy', 'medium', 'hard'];

List<String> difficultyLabelsFa = ['آسان', 'متوسط', 'سخت'];
List<String> difficultyLabelsAr = ['سهل', 'متوسط', 'صعب'];
List<String> difficultyLabelsEn = ['Easy', 'Medium', 'Hard'];
List<String> difficultyLabelsDa = ['Let', 'Mellem', 'Svær'];
String firestorePathEn = 'hangman_en';
String firestorePathDa = 'hangman_da';
String firestorePathFa = 'hangman_fa';
String firestorePathAr = 'hangman_ar';





Future<Map<String, dynamic>> getHangmanDifficulty() async {

  final auth = Get.find<AuthController>();
  List<String> difficultyNivea;
  List<String> difficultyLabels;
  String firestorePath;

  if (auth.language.isNotEmpty) {
    switch (auth.language[0]) {
      case 'fa':
        difficultyNivea = difficultyNiveaAll;
        difficultyLabels = difficultyLabelsFa;
        firestorePath = firestorePathFa;
        break;
      case 'en':
        difficultyNivea = difficultyNiveaAll;
        difficultyLabels = difficultyLabelsEn;
        firestorePath = firestorePathEn;
        break;
      case 'ar':
        difficultyNivea = difficultyNiveaAll;
        difficultyLabels = difficultyLabelsAr;
        firestorePath = firestorePathAr;
        break;
      case 'dk':
        difficultyNivea = difficultyNiveaAll;
        difficultyLabels = difficultyLabelsDa;
        firestorePath = firestorePathDa;
        break;
      default:
        difficultyNivea = difficultyNiveaAll;
        difficultyLabels = difficultyLabelsEn;
        firestorePath = firestorePathEn;

    }
  } else {
    difficultyNivea = difficultyNiveaAll;
    difficultyLabels = difficultyLabelsEn;
    firestorePath = firestorePathEn;
  }


  return {
    'difficultyNivea': difficultyNivea,
    'difficultyLabels': difficultyLabels,
    'firestorePath': firestorePath,
  };
}