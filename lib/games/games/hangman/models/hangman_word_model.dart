
class HangmanWordModel {
  final String difficulty;
  final String hint;
  final List<String> words;
  final double random;

  HangmanWordModel({
    required this.difficulty,
    required this.hint,
    required this.words,
    required this.random
  });

  factory HangmanWordModel.fromFirestore(Map<String, dynamic> map) {

    List<String> wordsList = List<String>.from(map['words']);

    return HangmanWordModel(
      difficulty: map['difficulty'] as String,
      hint: map['hint'] as String,
      words: wordsList,
      random: map['random'] as double,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'difficulty' : difficulty,
      'hint': hint,
      'words': words,
      'random' : random,
    };
  }

}