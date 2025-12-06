import 'dart:ui';
import 'package:get/get.dart';
import '../../helper/sharedpreferences/sharedpreferences.dart';

class LanguageController extends GetxController {
  RxList<String> currentLanguage = ['en', 'US'].obs;
  RxBool hasNewUpdate = false.obs;

  final List<Map<String, dynamic>> supportedLanguages = [
    {'name': 'English', 'locale': const Locale('en', 'US')},
    {'name': 'Dansk', 'locale': const Locale('dk', 'DK')},
    {'name': 'فارسی/ دری', 'locale': const Locale('fa', 'IR')},
    {'name': 'العربية', 'locale': const Locale('ar', 'SA')},
  ];


  Future<void> loadLanguage() async {
    final languageList = await SharedPreferencesManager.getStringList(
        SharedPreferencesKeys.appLanguageKey);
    currentLanguage.value = languageList ?? ['en', 'US'];

    final locale = Locale(currentLanguage[0], currentLanguage[1]);
    Get.updateLocale(locale);
    update();
  }

  Future<void> changeLanguage(Locale locale) async {
    final languageList = [locale.languageCode, locale.countryCode ?? ''];

    await SharedPreferencesManager.setStringList(
        SharedPreferencesKeys.appLanguageKey,
        languageList
    );

    currentLanguage.value = languageList;
    Get.updateLocale(locale);
    update();
  }

  String getCurrentLanguageName() {
    final currentLocale = supportedLanguages.firstWhere(
          (element) =>
      element['locale'].languageCode == currentLanguage[0] &&
          element['locale'].countryCode == currentLanguage[1],
      orElse: () => supportedLanguages[0],
    );
    return currentLocale['name'];
  }

  Locale getCurrentLocale() {
    return Locale(currentLanguage[0], currentLanguage[1]);
  }
}