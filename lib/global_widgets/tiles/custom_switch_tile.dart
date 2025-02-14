import 'package:flutter/material.dart';

class CustomSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  final bool showAdditionalInfo;
  final String? additionalInfoTitle;
  final String? additionalInfo;
  final IconData? additionalActionIcon;
  final Color? additionalIconColor;
  final VoidCallback? onAdditionalActionPressed;
  final Color? inactiveThumbColor;
  final Color? activColor;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final TextStyle? additionalInfoStyle;

  const CustomSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showAdditionalInfo = false,
    this.additionalInfoTitle,
    this.additionalInfo,
    this.additionalActionIcon,
    this.additionalIconColor,
    this.onAdditionalActionPressed,
    this.inactiveThumbColor = Colors.black,
    this.activColor = Colors.green,
    this.titleStyle,
    this.subtitleStyle,
    this.additionalInfoStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(
                title,
                style: titleStyle ?? const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: subtitleStyle,
              ),
              value: value,
              onChanged: onChanged,
              inactiveThumbColor: inactiveThumbColor,
              activeColor: activColor,
            ),
            if (showAdditionalInfo && additionalInfo != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              if (additionalInfoTitle != null)
                Text(
                  additionalInfoTitle!,
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      additionalInfo!,
                      style: additionalInfoStyle ?? const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  if (additionalActionIcon != null)
                    IconButton(
                      icon: Icon(additionalActionIcon),
                      color: additionalIconColor?? Colors.black,
                      onPressed: onAdditionalActionPressed,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}