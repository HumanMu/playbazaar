import 'dart:ui';

class SingleOnlinePlayer {
  final String playerId;        // Firestore document key (userId)
  final String name;      // Display name
  final List<int> tokens; // [-1, 0..56, 57]
  final String? teamId;

  // Not stored in Firestore, only local
  Color? color;

  int get tokensAtHome => tokens.where((t) => t == -1).length;
  int get tokensFinished => tokens.where((t) => t == 57).length;
  int get tokensOnBoard => tokens.where((t) => t >= 0 && t <= 56).length;


  SingleOnlinePlayer({
    required this.playerId,
    required this.name,
    required this.tokens,
    this.teamId,
    this.color,
  });

  // Factory to create from Firestore map
  factory SingleOnlinePlayer.fromMap(Map<String, dynamic> data) {
    return SingleOnlinePlayer(
      playerId: data['playerId'],
      name: data['name'] ?? 'player',
      tokens: List<int>.from(data['tokens'] ?? [-1, -1, -1, -1]),
      teamId: data['teamId'],
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      "playerId": playerId,
      "name": name,
      "tokens": tokens,
      "teamId": teamId,
    };
  }

  // Helpers
  bool get hasWon => tokens.every((pos) => pos == 57);
  bool get hasAnyOnBoard => tokens.any((pos) => pos >= 0 && pos < 57);
}