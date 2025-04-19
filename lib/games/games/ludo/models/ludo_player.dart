
import '../helper/enums.dart';

class LudoPlayer {
  final String? avatarImg;
  final String? name;
  final TokenType tokenType;
  final int reachedHome;
  final bool hasFinished;
  final int? endedPosition;
  final bool? isRobot;

  LudoPlayer({
    this.avatarImg,
    this.name = "Guest",
    required this.tokenType,
    this.reachedHome = 0,
    this.hasFinished = false,
    this.endedPosition,
    this.isRobot = false,
  });


  LudoPlayer copyWith({
    String? avatarImg,
    String? name,
    TokenType? tokenType,
    int? reachedHome,
    bool? hasFinished,
    int? endedPosition,
    bool? isRobot,
  }) {
    return LudoPlayer(
      avatarImg: avatarImg?? this.avatarImg,
      name: name ?? this.name,
      tokenType: tokenType ?? this.tokenType,
      reachedHome: reachedHome ?? this.reachedHome,
      hasFinished: hasFinished ?? this.hasFinished,
      endedPosition: endedPosition ?? this.endedPosition,
      isRobot: isRobot ?? this.isRobot
    );
  }
}