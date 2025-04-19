String normalizeAlphabet(String word, language) {
  String normalized = word.replaceAll(RegExp(r'\s+'), '').trim(); // First remove any extra spaces
  bool isRtlLanguage = language == "fa" || language == "ar";

  // For Arabic and Persian, also remove special RTL characters
  if (isRtlLanguage) {
    normalized = normalized
        .replaceAll('\u200C', '')
        .replaceAll(RegExp(r'[\u200B-\u200F\u061C\uFEFF\u200D]'), '')
        .replaceAll(RegExp(r'[\u202A-\u202E\u2066-\u2069]'), '');
  }
  return isRtlLanguage? normalized : normalized.toUpperCase();
}