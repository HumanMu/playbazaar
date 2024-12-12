import 'package:hive_flutter/hive_flutter.dart';
import '../puzzle/models/wall_blast_model.dart';

class WallHiveService {
  static const String _highScoreBox = 'highScoreBox';
  static const String _gameProgressBox = 'gameProgressBox';

  Future<void> initHive() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(WallBlastModelAdapter());
    Hive.registerAdapter(ColorAdapter());
  }

  Future<int> getHighScore() async {
    final box = await Hive.openBox(_highScoreBox);
    return box.get('highScore', defaultValue: 0);
  }

  Future<void> saveHighScore(int score) async {
    final box = await Hive.openBox(_highScoreBox);
    await box.put('highScore', score);
  }

  Future<void> saveGameProgress(List<WallBlastModel> blocks) async {
    final box = await Hive.openBox(_gameProgressBox);
    await box.put('gameBlocks', blocks);
  }

  Future<List<WallBlastModel>?> loadGameProgress() async {
    final box = await Hive.openBox(_gameProgressBox);
    return box.get('gameBlocks');
  }

  Future<void> clearGameProgress() async {
    final box = await Hive.openBox(_gameProgressBox);
    await box.delete('gameBlocks');
  }
}