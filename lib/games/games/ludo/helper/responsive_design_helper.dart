import 'dart:math';
import 'package:flutter/material.dart';

class ResponsiveLayout {
  static double getTokenSize(BuildContext context) {
    // Adjust token size based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return 30.0;
    if (screenWidth < 480) return 35.0;
    return 40.0;
  }

  static double getBoardSize(BuildContext context) {
    // Calculate optimal board size based on screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableSize = min(screenWidth, screenHeight * 0.8);

    // Ensure board fits within a reasonable range
    return min(max(availableSize, 300.0), 600.0);
  }
}
