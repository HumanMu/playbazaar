
import 'package:flutter/material.dart';
import '../helper/enums.dart';

class PlayerProfile {
  final String name;
  final String? avatarUrl;
  final TokenType tokenType;
  final bool isRobot;
  final Color color;
  final int? endedPosition;

  PlayerProfile({
    required this.name,
    this.avatarUrl,
    required this.tokenType,
    this.isRobot = false,
    required this.color,
    this.endedPosition
  });
}
