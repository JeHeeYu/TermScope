import 'package:flutter/material.dart';

class ButtonIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double? iconSize;
  final VoidCallback callback;

  const ButtonIcon({
    Key? key,
    required this.icon,
    this.callback = _callback,
    this.iconColor = Colors.white,
    this.iconSize,
  }) : super(key: key);

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