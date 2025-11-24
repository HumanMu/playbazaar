/*import 'dart:ui';

/// Language model class
class LanguageModel {
  final String name;
  final String languageCode;
  final String countryCode;
  final Locale locale;

  const LanguageModel({
    required this.name,
    required this.languageCode,
    required this.countryCode,
    required this.locale,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LanguageModel &&
              runtimeType == other.runtimeType &&
              languageCode == other.languageCode &&
              countryCode == other.countryCode;

  @override
  int get hashCode => languageCode.hashCode ^ countryCode.hashCode;
}*/