import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/user_controller/auth_controller.dart';

class CustomLanguage extends StatelessWidget {
  CustomLanguage({super.key});

  final AuthController authController = Get.find<AuthController>();

  final List<Map<String, dynamic>> locale = [
    {'name': 'English', 'locale': const Locale('en', 'US')},
    {'name': 'Dansk', 'locale': const Locale('dk', 'DK')},
    {'name': 'فارسی/ دری', 'locale': const Locale('fa', 'AF')},
    {'name': 'العربية', 'locale': const Locale('ar', 'SA')},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() => ElevatedButton(
          onPressed: () => languageDialog(context),
          child: Text(
            'Change Language (${_getCurrentLanguageName()})',
          ),
        )),
      ),
    );
  }

  String _getCurrentLanguageName() {
    final currentLanguageCode = authController.language[0];
    final currentCountryCode = authController.language[1];

    final currentLocale = locale.firstWhere(
          (element) =>
      element['locale'].languageCode == currentLanguageCode &&
          element['locale'].countryCode == currentCountryCode,
      orElse: () => locale[0],
    );

    return currentLocale['name'];
  }

  Future<void> saveLanguage(Locale locale) async {
    final languageList = [locale.languageCode, locale.countryCode ?? ''];

    // Update both SharedPreferences and AuthController
    await authController.updateLanguage(languageList);
  }

  void updateLanguage(Locale locale) {
    saveLanguage(locale);
    Get.updateLocale(locale);
    Get.back();
  }

  void languageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text('choose_language'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.separated(
              itemCount: locale.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final currentLocale = locale[index]['locale'] as Locale;
                final isSelected =
                    currentLocale.languageCode == authController.language[0] &&
                        currentLocale.countryCode == authController.language[1];

                return GestureDetector(
                  onTap: () {
                    updateLanguage(currentLocale);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          locale[index]['name'],
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check, color: Colors.green)
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Colors.red,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
/*class CustomLanguage extends StatelessWidget {
  CustomLanguage({super.key});

  final List<Map<String, dynamic>> locale = [
    {'name': 'English', 'locale': const Locale('en', 'US')},
    {'name': 'Dansk', 'locale': const Locale('dk', 'DK')},
    {'name': 'فارسی', 'locale': const Locale('fa', 'AF')},
    {'name': 'العربية', 'locale': const Locale('ar', 'SA')},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Trigger the dialog when this button is pressed
            languageDialog(context);
          },
          child: const Text('Change Language'),
        ),
      ),
    );
  }

  Future<void> saveLanguage(Locale locale) async {
    await SharedPreferencesManager.setStringList(
        SharedPreferencesKeys.appLanguageKey,
        [locale.languageCode, locale.countryCode ?? '']
    );

  }

  void updateLanguage(Locale locale) {
    saveLanguage(locale);
    Get.updateLocale(locale);
    Get.back();
  }

  languageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('choose_language'.tr),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.separated(
              itemCount: locale.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    updateLanguage(locale[index]['locale']);
                  },
                  child: Text(locale[index]['name']),
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Colors.red,
                );
              },
            ),
          ),
        );
      },
    );
  }
}*/
