import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/language_controller/language_controller.dart';

class LanguageDialog {
  static void show(BuildContext context) {
    final languageController = Get.find<LanguageController>();

    showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              'choose_language'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.separated(
              itemCount: languageController.supportedLanguages.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final langData = languageController.supportedLanguages[index];
                final locale = langData['locale'] as Locale;

                // Wrap only the part that needs to observe changes
                return Obx(() {
                  final isSelected = locale.languageCode == languageController.currentLanguage[0] &&
                      locale.countryCode == languageController.currentLanguage[1];

                  return InkWell(
                    onTap: () {
                      languageController.changeLanguage(locale);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            langData['name'],
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
                });
              },
              separatorBuilder: (context, index) => const Divider(color: Colors.red),
            ),
          ),
        );
      },
    );
  }
}