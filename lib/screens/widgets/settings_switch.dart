import 'package:flutter/material.dart';


class SettingsSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final Function() onToggle;

  const SettingsSwitch({
    super.key,
    required this.title,
    required this.value,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Switch(
          value: value,
          onChanged: (_) => onToggle(),
          activeColor: Colors.green,
          inactiveThumbColor: Colors.red,
          inactiveTrackColor: Colors.red[200],
          trackOutlineWidth: const WidgetStatePropertyAll(0),
        ),
      ],
    );
  }
}