
import '../helper/enums.dart';

class LudoPlayer {
  final String? avatarImg;
  final String? name;
  final TokenType tokenType;
  final int reachedHome;
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
    this.reachedHome = 0,
    this.hasFinished = false,
    this.endedPosition,
    this.isRobot = false,
    this.teamId,
    this.isConnected,
    this.playerId,
  });


  LudoPlayer copyWith({
    String? avatarImg,
    String? name,
    TokenType? tokenType,
    int? reachedHome,
    bool? hasFinished,
    int? endedPosition,
    bool? isRobot,
    int? teamId,
    String? playerId,
    bool? isConnected,

  }) {
    return LudoPlayer(
      avatarImg: avatarImg?? this.avatarImg,
      name: name ?? this.name,
      tokenType: tokenType ?? this.tokenType,
      reachedHome: reachedHome ?? this.reachedHome,
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
