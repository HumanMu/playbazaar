class GameConfig {
  final int playerCount;
  bool teamPlay;
  bool enabledRobots;
  bool requiresConfirmation;
  bool needsUpdate;

  GameConfig({
    required this.playerCount,
    required this.teamPlay,
    required this.enabledRobots,
    this.requiresConfirmation = false,
    this.needsUpdate = false,
  });

  GameConfig copyWith({
    int? playerCount,
    bool? teamPlay,
    bool? enabledRobots,
    bool? requiresConfirmation,
    bool? needsUpdate,
  }) {
    return GameConfig(
      playerCount: playerCount ?? this.playerCount,
      teamPlay: teamPlay ?? this.teamPlay,
      enabledRobots: enabledRobots ?? this.enabledRobots,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      needsUpdate: needsUpdate ?? this.needsUpdate,
    );
  }
}
