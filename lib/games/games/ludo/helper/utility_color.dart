import 'package:flutter/material.dart';

class LudoColors {
  static const Color red = Color(0xFFE53935);
  static const Color green = Color(0xFF43A047);
  static const Color yellow = Color(0xFFFFB300);
  static const Color blue = Color(0xFF1E88E5);
  static const Color background = Color(0xFFF5F5F5);
  static const Color accent = Color(0xFF5C6BC0);
}

class Utility {
  static Color getColor(int row, int column) {
    //Green
    if ((row == 0 || row == 5) && column <= 5) {
      return Colors.lightGreenAccent;
    }
    if ((column == 0 || column == 5) && row <= 5) {
      return Colors.lightGreenAccent;
    }
    //Yellow
    if ((row == 0 || row == 5) && (column >= 9 && column <= 14)) {
      return Colors.yellowAccent;
    }
    if ((column == 9 || column == 14) && row <= 5) {
      return Colors.yellowAccent;
    }
    //Red
    if ((row == 9 || row == 14) && column <= 5) {
      return Colors.redAccent;
    }
    if ((column == 0 || column == 5) && (row >= 9 && row <= 14)) {
      return Colors.redAccent;
    }
    //Blue
    if ((column == 9 || column == 14) && (row >= 9 && row <= 14)) {
      return Colors.lightBlueAccent;
    }
    if ((row == 9 || row == 14) && (column >= 9 && column <= 14)) {
      return Colors.lightBlueAccent;
    }
    return Colors.transparent;
  }

  static Color getTestColor(int row, int column) {
    //Green
    if ((row == 0 || row == 5) && column <= 5) {
      return Colors.lightGreenAccent;
    }
    if ((column == 0 || column == 5) && row <= 5) {
      return Colors.lightGreenAccent;
    }
    //Yellow
    if ((row == 0 || row == 5) && (column >= 9 && column <= 14)) {
      return Colors.yellowAccent;
    }
    if ((column == 9 || column == 14) && row <= 5) {
      return Colors.yellowAccent;
    }
    //Red
    if ((row == 9 || row == 14) && column <= 5) {
      return Colors.redAccent;
    }
    if ((column == 0 || column == 5) && (row >= 9 && row <= 14)) {
      return Colors.redAccent;
    }
    //Blue
    if ((column == 9 || column == 14) && (row >= 9 && row <= 14)) {
      return Colors.lightBlueAccent;
    }
    if ((row == 9 || row == 14) && (column >= 9 && column <= 14)) {
      return Colors.lightBlueAccent;
    }
    return Colors.transparent;
  }

}
