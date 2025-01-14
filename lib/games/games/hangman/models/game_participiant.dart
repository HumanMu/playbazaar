class GameParticipantModel {
  final String uid;
  final String name;
  final String? image;
  final int numberOfWin;

  GameParticipantModel({
    required this.uid,
    required this.name,
    this.image,
    this.numberOfWin = 0,
  });

  factory GameParticipantModel.fromFirestore(Map<String, dynamic> map) {
    return GameParticipantModel(
      uid: map['uid']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      image: map['image']?.toString(),
      numberOfWin: (map['numberOfWin'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'image': image,
      'numberOfWin': numberOfWin,
    };
  }

  // Add a copy method for easy updates
  GameParticipantModel copyWith({
    String? uid,
    String? name,
    String? image,
    int? incurrectGuess,
    int? numberOfWin,
  }) {
    return GameParticipantModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      image: image ?? this.image,
      numberOfWin: numberOfWin ?? this.numberOfWin,
    );
  }
}