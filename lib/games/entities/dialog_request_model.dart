import 'package:flutter/material.dart';

class DialogRequestModel {
  final String id;
  final Widget dialog;
  final bool barrierDismissible;
  final Color? barrierColor;
  final bool useSafeArea;
  final RouteSettings? routeSettings;

  DialogRequestModel({
    required this.dialog,
    this.barrierDismissible = true,
    this.barrierColor,
    this.useSafeArea = true,
    this.routeSettings,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  DialogRequestModel copyWith({
    String? id,
    Widget? dialog,
    bool? barrierDismissible,
    Color? barrierColor,
    bool? useSafeArea,
    RouteSettings? routeSettings,
  }) {
    return DialogRequestModel(
      dialog: dialog ?? this.dialog,
      barrierDismissible: barrierDismissible ?? this.barrierDismissible,
      barrierColor: barrierColor ?? this.barrierColor,
      useSafeArea: useSafeArea ?? this.useSafeArea,
      routeSettings: routeSettings ?? this.routeSettings,
    );
  }
}