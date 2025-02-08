import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguagePicker extends StatefulWidget {
  final String? initialLanguage;
  final Function(String)? onLanguageChanged;

  const LanguagePicker({
    super.key,
    this.initialLanguage,
    this.onLanguageChanged,
  });

  @override
  State<LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<LanguagePicker> {
  String? selectedLanguage;

  final Map<String, String> languageMap = {
    'Select Language': '',  // Default option
    'English': 'en',
    'Danish': 'da',
    'فارسی': 'fa',
    'العربیه': 'ar',
    'هزارگی' : 'hzr'
  };

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.initialLanguage;
  }

  String get currentDisplayLanguage {
    if (selectedLanguage == null || selectedLanguage!.isEmpty) {
      return 'Select Language';
    }
    return languageMap.keys.firstWhere(
            (key) => languageMap[key] == selectedLanguage,
        orElse: () => 'Select Language'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: DropdownButton<String>(
        dropdownColor: Colors.grey.shade100,
        value: currentDisplayLanguage,
        underline: Container(),
        isDense: true,
        hint: Text('select_language'.tr),  // Added hint text
        style: TextStyle(color: Colors.blueGrey.shade800),
        onChanged: (String? newValue) {
          if (newValue != null) {
            final newLanguage = languageMap[newValue] ?? '';
            setState(() {
              selectedLanguage = newLanguage.isEmpty ? null : newLanguage;
            });
            if (newLanguage.isNotEmpty) {
              widget.onLanguageChanged?.call(newLanguage);
            }
          }
        },
        items: languageMap.keys
            .map<DropdownMenuItem<String>>((String displayName) {
          return DropdownMenuItem<String>(
            value: displayName,
            child: Text(displayName),
          );
        }).toList(),
      ),
    );
  }
}