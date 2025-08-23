// core/models/piece.dart
import '../helper/enums.dart';

class Piece {
  final String id;
  final PlayerColor color;
  final Position position;
  final bool isHome;
  final bool isSafe;

  Piece({
    required this.id,
    required this.color,
    required this.position,
    this.isHome = true,
    this.isSafe = false,
  });

  // Helper method to create a copy with updated values
  Piece copyWith({
    Position? position,
    bool? isHome,
    bool? isSafe,
  }) {
    return Piece(
      id: id,
      color: color,
      position: position ?? this.position,
      isHome: isHome ?? this.isHome,
      isSafe: isSafe ?? this.isSafe,
    );
  }

  static Piece nullPiece() {
    return Piece(
      id: '',
      color: PlayerColor.red, // Default color, won't be used
      position: Position(-1, -1), // Invalid position
      isHome: true,
      isSafe: false,
    );
  }
}

class Position {
  final double x;
  final double y;

  Position(this.x, this.y);
}
