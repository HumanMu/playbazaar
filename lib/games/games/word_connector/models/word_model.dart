class WordConnectorModel {
  final String text;
  bool isFound;

  WordConnectorModel({
    required this.text,
    this.isFound = false,
  });

  // Used for creating from Firestore data
  factory WordConnectorModel.fromMap(Map<String, dynamic> map) {
    return WordConnectorModel(
      text: map['text'],
      isFound: false,
    );
  }

  WordConnectorModel copyWith({
    String? text,
    bool? isFound,
  }) {
    return WordConnectorModel(
      text: text ?? this.text,
      isFound: isFound ?? this.isFound,
    );
  }
}

class WordConnectorDto {
  final List<WordConnectorModel> words;
  final List<String> letters;
  final int level;

  WordConnectorDto({
    required this.words,
    required this.letters,
    required this.level

  });
}
