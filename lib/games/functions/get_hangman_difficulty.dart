
List<String> difficultyNiveaAll = ['easy', 'medium', 'hard'];

List<String> difficultyLabelsFa = ['آسان', 'متوسط', 'سخت'];
List<String> difficultyLabelsAr = ['سهل', 'متوسط', 'صعب'];
List<String> difficultyLabelsEn = ['Easy', 'Medium', 'Hard'];
List<String> difficultyLabelsDa = ['Let', 'Mellem', 'Svær'];
String firestorePathEn = 'hangman_en';
String firestorePathDa = 'hangman_da';
String firestorePathFa = 'hangman_fa';
String firestorePathAr = 'hangman_ar';





Future<Map<String, dynamic>> getHangmanDifficulty(String language) async {

  //final auth = Get.find<AuthController>();
  List<String> difficultyNivea;
  List<String> difficultyLabels;
  String firestorePath;

  if (language != "") {
    switch (language) {
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
      case 'da':
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
