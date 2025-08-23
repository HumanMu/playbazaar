
import 'package:playbazaar/games/games/ludo/models/firestore_piece.dart';

class FieldPlayer{
  String name;
  String? avatarImg;
  List<FirestorePiece> pieces;

  FieldPlayer({
    required this.name,
    this.avatarImg = "",
    required this.pieces
  });

}