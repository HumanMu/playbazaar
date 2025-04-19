import 'package:get/get.dart';
import '../helper/enums.dart';
import 'position.dart';


class Token {
  final int id;
  final TokenType type;
  final Rx<Position> _tokenPosition;
  final Rx<TokenState> _tokenState;
  final RxInt _positionInPath;

  Token(
      this.type,
      Position tokenPosition,
      TokenState tokenState,
      this.id, {
        int positionInPath = 0,
      }) :
        _tokenPosition = Rx<Position>(tokenPosition),
        _tokenState = Rx<TokenState>(tokenState),
        _positionInPath = RxInt(positionInPath);

  Position get tokenPosition => _tokenPosition.value;
  set tokenPosition(Position position) => _tokenPosition.value = position;

  TokenState get tokenState => _tokenState.value;
  set tokenState(TokenState state) => _tokenState.value = state;

  int get positionInPath => _positionInPath.value;
  set positionInPath(int position) => _positionInPath.value = position;

  Token copyWith({
    TokenType? type,
    Position? tokenPosition,
    TokenState? tokenState,
    int? id,
    int? positionInPath,
  }) {
    return Token(
      type ?? this.type,
      tokenPosition ?? this.tokenPosition,
      tokenState ?? this.tokenState,
      id ?? this.id,
      positionInPath: positionInPath ?? this.positionInPath,
    );
  }
}

