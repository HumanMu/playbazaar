
class LudoCreationParamsModel {
  final bool teamPlay;
  final bool enableRobots;
  final String? gameCode;
  final int numberOfPlayers;
  final bool isHost;

  LudoCreationParamsModel({
    this.gameCode,
    required this.teamPlay,
    required this.enableRobots,
    required this.numberOfPlayers,
    required this.isHost,
  });

}