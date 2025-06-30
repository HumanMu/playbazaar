
class GameStateChangeModel {
  String gameId;
  String wordHint;
  String word;

  GameStateChangeModel({
    required this.gameId,
    required this.wordHint,
    required this.word,
  });

  factory GameStateChangeModel.fromFirestore(Map<String, dynamic> map) {

    return GameStateChangeModel(
      gameId: map['gameId'] as String,
      wordHint: map['wordHint'] as String,
      word: map['word'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gameId' : gameId,
      'wordHint': wordHint,
      'words': word
    };
  }


}
