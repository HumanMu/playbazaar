
import '../../helper/sharedpreferences/sharedpreferences.dart';

// English
List<String> quizListConstantsRoutesEn = ['geography_en', 'english_en', 'general_knowledge_en'];
List<String> quizListConstantsEn = ['Geography', 'English', 'General Knowledge'];

// Dansk
List<String> quizListConstantsRoutesDk = ['geography_dk', 'english_dk', 'general_knowledge_dk'];
List<String> quizListConstantsDk = ['Geografi', 'Engelsk', 'Almindelig viden'];

// Farsi
List<String> quizListConstantsRoutesAf = ['geography_fa', 'hazaragi_af', 'herati_af', 'english_fa','pashto_af', 'general_nowledge_fa'];
List<String> quizListConstantsFa = ['جغرافیا', 'هزارگی', 'هراتی', 'انگلیسی', 'پشتو','اطلاعات عمومی'];

// Arabic
List<String> quizListConstantsRoutesAr = ['geography_ar', 'syrien_ar', 'morroccan_ar', 'english_ar','iraqi_ar', 'general_nowledge_ar'];
List<String> quizListConstantsAr = ['جغرافیا', 'سوري', 'مغربي', 'إنجليزي','عراقي','معلومات عامة'];


Future<Map<String, dynamic>> getQuizLanguage() async {
  List<String> quizPath;
  int quizLength;
  List<String> quizNames;
  List<String>? value = await SharedPreferencesManager.getStringList(SharedPreferencesKeys.appLanguageKey);
  //final authController = Get.find<AuthController>();

  if (value != null && value.isNotEmpty) {
    switch (value[0]) {
      case 'fa':
        quizPath = quizListConstantsRoutesAf;
        quizLength = quizListConstantsRoutesAf.length;
        quizNames = quizListConstantsFa;
        break;
      case 'en':
        quizPath = quizListConstantsRoutesEn;
        quizLength = quizListConstantsRoutesEn.length;
        quizNames = quizListConstantsEn;
        break;
      case 'ar':
        quizPath = quizListConstantsRoutesAr;
        quizLength = quizListConstantsRoutesAr.length;
        quizNames = quizListConstantsAr;
        break;
      case 'dk':
        quizPath = quizListConstantsRoutesEn;
        quizLength = quizListConstantsRoutesEn.length;
        quizNames = quizListConstantsEn;
        /*quizPath = quizListConstantsRoutesDk;
        quizLength = quizListConstantsRoutesDk.length;
        quizNames = quizListConstantsDk;*/
        break;
      default:
        quizPath = quizListConstantsRoutesAf;
        quizLength = quizListConstantsRoutesAf.length;
        quizNames = quizListConstantsFa;
    }
  } else {
    quizPath = quizListConstantsRoutesAf;
    quizLength = quizListConstantsRoutesAf.length;
    quizNames = quizListConstantsFa;
  }

  return {
    'quizPath': quizPath,
    'quizLength': quizLength,
    'quizNames': quizNames,
  };
}



