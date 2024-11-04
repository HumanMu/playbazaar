
import '../../../../helper/sharedpreferences/sharedpreferences.dart';
import '../../../constants/constants.dart';

Future<Map<String, dynamic>> getQuizLanguage() async {
  List<String>? value = await SharedPreferencesManager.getStringList(SharedPreferencesKeys.appLanguageKey);
  List<String> quizPath;
  int quizLength;
  List<String> quizNames;

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



