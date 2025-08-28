
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playbazaar/games/games/ludo/helper/enum_converter.dart';
import '../helper/enums.dart';

class LudoPlayer {
  final String? avatarImg;
  final String? name;
  final TokenType tokenType;
  final int numberOfreachedHome;
  final bool hasFinished;
  final int? endedPosition;
  final bool? isRobot;
  final int? teamId;
  final String? playerId;
  final bool? isConnected;


  LudoPlayer({
    this.avatarImg,
    this.name = "Guest",
    required this.tokenType,
    this.numberOfreachedHome = 0,
    this.hasFinished = false,
    this.endedPosition,
    this.isRobot = false,
    this.teamId,
    this.isConnected = true,
    this.playerId,
  });


  Map<String, dynamic> toMap() {
    return {
      'avatarImg': avatarImg,
      'name': name,
      'tokenType': tokenType2String(tokenType),
      'numberOfreachedHome': numberOfreachedHome,
      'hasFinished': hasFinished,
      'endedPosition': endedPosition,
      'isRobot': isRobot,
      'teamId': teamId,
      'playerId': playerId,
      'isConnected': isConnected,
    };
  }

  /// Create model from Firestore document
  factory LudoPlayer.fromMap(Map<String, dynamic> map) {
    return LudoPlayer(
      avatarImg: (map['avatarImg'] != null && (map['avatarImg'] as String).isNotEmpty)
          ? map['avatarImg']
          : null,
      name: map['name'] ?? 'Guest',
      tokenType: string2TokenType(map['tokenType']),
      numberOfreachedHome: map['numberOfreachedHome'] ?? 0,
      hasFinished: map['hasFinished'] ?? false,
      endedPosition: map['endedPosition'],
      isRobot: map['isRobot'] ?? false,
      teamId: map['teamId'],
      playerId: map['playerId'],
      isConnected: map['isConnected'] ?? true,
    );
  }


  LudoPlayer copyWith({
    String? avatarImg,
    String? name,
    TokenType? tokenType,
    int? numberOfreachedHome,
    bool? hasFinished,
    int? endedPosition,
    bool? isRobot,
    int? teamId,
    String? playerId,
    bool? isConnected,
    Timestamp? joinedAt

  }) {
    return LudoPlayer(
      avatarImg: avatarImg?? this.avatarImg,
      name: name ?? this.name,
      tokenType: tokenType ?? this.tokenType,
      numberOfreachedHome: numberOfreachedHome ?? this.numberOfreachedHome,
      hasFinished: hasFinished ?? this.hasFinished,
      endedPosition: endedPosition ?? this.endedPosition,
      isRobot: isRobot ?? this.isRobot,
      teamId: teamId ?? this.teamId,
      playerId: playerId ?? this.playerId,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  // Helper to check if another player is a teammate
  bool isTeammate(LudoPlayer? otherPlayer) {
    if (otherPlayer == null || teamId == null || otherPlayer.teamId == null) {
      return false;
    }
    return teamId == otherPlayer.teamId && tokenType != otherPlayer.tokenType;
  }
}
