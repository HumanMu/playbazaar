import 'package:flutter/material.dart';
import 'enums.dart';

class LudoHelper {

  static List<List<GlobalKey>> getGlobalKeys() {
    List<List<GlobalKey>> keysMain = [];
    for (int i = 0; i < 15; i++) {
      List<GlobalKey> keys = [];
      for (int j = 0; j < 15; j++) {
        keys.add(GlobalKey());
      }
      keysMain.add(keys);
    }
    return keysMain;
  }

  static Color getTokenColor(TokenType type) {
    switch (type) {
      case TokenType.green:
        return Colors.green;
      case TokenType.yellow:
        return Colors.yellow;
      case TokenType.blue:
        return Colors.blue;
      case TokenType.red:
        return Colors.red;
    }
  }


}
