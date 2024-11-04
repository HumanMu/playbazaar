import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helper/sharedpreferences/sharedpreferences.dart';

class CustomLanguage extends StatelessWidget {
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
}
