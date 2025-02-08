
class AddWordModel {
  final List<String> words;
  final List<String> letters;
  final int level;
  int? count;

  AddWordModel({
    required this.words,
    required this.letters,
    required this.level,
    this.count
  });


  factory AddWordModel.fromFirestore(Map<String, dynamic> map) {
    return AddWordModel(
      words: map['words'] as List<String>,
      letters: map['letters'] as List<String>,
      level: map['level'] as int,
      count: map['count'] as int

    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'words': words,
      'letters': letters,
      'level': level,
      'count': count
    };
  }

}