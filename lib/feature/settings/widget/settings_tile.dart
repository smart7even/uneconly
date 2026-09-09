import 'package:flutter/material.dart';

/// {@template settings_tile}
/// SettingsTile widget
/// {@endtemplate}
class SettingsTile extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onPressed;
  final Widget? trailing;
  final EdgeInsets padding;
  final TextStyle? titleStyle;

  /// {@macro settings_tile}
  const SettingsTile({
    super.key,
    required this.title,
    this.description,
    this.trailing,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.titleStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 18,
    ),
  });

  const SettingsTile.withoutPadding({
    super.key,
    required this.title,
    this.description,
    this.trailing,
    this.onPressed,
    this.padding = const EdgeInsets.all(0),
    this.titleStyle = const TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 18,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    final description = this.description;

    return SizedBox(
      width: double.infinity,
      child: InkWell(
        splashFactory: InkRipple.splashFactory,
        onTap: onPressed,
        child: Padding(
          padding: padding,
          child: Ink(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(title, style: titleStyle),
                      if (description != null)
                        Text(
                          description,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
} // SettingsTile
