
class SingleOnlinePlayer {
  final String playerId;
  final String name;
  final int? teamId;
  final int finishedTokensLength;
  final bool isConnected;
  final String color;


  SingleOnlinePlayer({
    required this.playerId,
    required this.name,
    required this.isConnected,
    required this.finishedTokensLength,
    required this.color,
    this.teamId,
  });

  factory SingleOnlinePlayer.fromMap(Map<String, dynamic> data) {
    return SingleOnlinePlayer(
      playerId: data['playerId'],
      name: data['name'] ?? 'player',
      teamId: data['teamId'],
      finishedTokensLength: data['finishedTokensLength'],
      isConnected: data['isConnected'] ?? true,
      color: data['color'] ?? 'red',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "playerId": playerId,
      "name": name,
      "teamId": teamId,
      "finishedTokensLength": finishedTokensLength,
      "isConnected": isConnected,
      "color": color,
    };
  }

  // Keep these helpers but calculate from external token map
  bool hasWon(Map<String, int> allTokens, int playerIndex) {
    for (int i = 0; i < 4; i++) {
      final tokenKey = 'p${playerIndex}_t$i';
      if (allTokens[tokenKey] != 57) return false;
    }
    return true;
  }

  bool hasAnyOnBoard(Map<String, int> allTokens, int playerIndex) {
    for (int i = 0; i < 4; i++) {
      final tokenKey = 'p${playerIndex}_t$i';
      final pos = allTokens[tokenKey] ?? -1;
      if (pos >= 0 && pos < 57) return true;
    }
    return false;
  }
}