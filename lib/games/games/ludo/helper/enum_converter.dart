
import 'enums.dart';

TokenType string2TokenType(String s) {
  TokenType tokenType = TokenType.values.firstWhere(
        (enumValue) => enumValue.toString().split('.').last == s,
    orElse: () => throw ArgumentError('Invalid token type --> string to TokenType: $s'),
  );
  return tokenType;
}

TokenState string2TokenState(String s) {
  TokenState tokenState = TokenState.values.firstWhere(
        (enumValue) => enumValue.toString().split('.').last == s,
    orElse: () => throw ArgumentError('Invalid token type --> string to TokenState: $s'),
  );
  return tokenState;
}

GameMode string2GameMode(String s) {
  GameMode gameMode = GameMode.values.firstWhere(
        (enumValue) => enumValue.toString().split('.').last == s,
    orElse: () => throw ArgumentError('Invalid game mode --> string to TokenState: $s'),
  );
  return gameMode;
}



String tokenType2String(TokenType t) {
  return t.toString().split('.').last;
}

String tokenState2String(TokenState t) {
  return t.toString().split('.').last;
}

String gameMode2String(GameMode gm) {
  return gm.toString().split('.').last;
}
