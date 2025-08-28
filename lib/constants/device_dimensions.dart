
import 'package:flutter/widgets.dart';

class DeviceDimensions {
  static double screenWidth = 0;
  static double screenHeight = 0;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
  }
}