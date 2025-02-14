class GameParticipantModel {
  final String uid;
  final String name;
  final String? image;
  final int numberOfWin;
  final String gameState;

  GameParticipantModel({
    required this.uid,
    required this.name,
    required this.gameState,
    this.image,
    this.numberOfWin = 0,
  });

  factory GameParticipantModel.fromFirestore(Map<String, dynamic> map) {
    return GameParticipantModel(
      uid: map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      image: map['image']?.toString(),
      numberOfWin: (map['numberOfWin'] as num?)?.toInt() ?? 0,
      gameState: map['gameState']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'image': image,
      'numberOfWin': numberOfWin,
      'gameState': gameState
    };
  }

  // Add a copy method for easy updates
  GameParticipantModel copyWith({
    String? uid,
    String? name,
    String? image,
    int? incurrectGuess,
    int? numberOfWin,
    String? gameState,
  }) {
    return GameParticipantModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      image: image ?? this.image,
      numberOfWin: numberOfWin ?? this.numberOfWin,
      gameState: gameState?? this.gameState
    );
  }
}