import 'package:flutter/material.dart';

class ButtonIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double? iconSize;
  final VoidCallback callback;

  const ButtonIcon({
    super.key,
    required this.icon,
    this.callback = _callback,
    this.iconColor = Colors.white,
    this.iconSize,
  });

  static void _callback() {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Icon(
        icon,
        color: iconColor,
        size: iconSize,
      ),
    );
  }
}