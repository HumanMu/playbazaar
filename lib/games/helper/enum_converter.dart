import 'package:playbazaar/games/helper/enum.dart';

GameProgress string2GameProgress(String s) {
  GameProgress gameProgress = GameProgress.values.firstWhere(
        (enumValue) => enumValue.toString().split('.').last == s,
    orElse: () => throw ArgumentError('Invalid game progress --> string to GameProgress: $s'),
  );
  return gameProgress;
}


String gameProgress2String(GameProgress p) {
  return p.toString().split('.').last;
}