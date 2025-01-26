import 'package:flutter/material.dart';
import 'package:termscope/views/widgets/button_icon.dart';
import 'package:termscope/views/widgets/ssh_connection_dialog.dart';

class TopMenuList extends StatelessWidget {
  const TopMenuList({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ButtonIcon(
          icon: Icons.add_circle_outline_rounded,
          iconColor: Colors.black,
          iconSize: 28.0,
          callback: () {
            showDialog(
              context: context,
              builder: (context) => const SSHConnectionDialog(),
            );
          },
        ),
        const SizedBox(width: 8),
        ButtonIcon(
          icon: Icons.settings,
          iconColor: Colors.black,
          iconSize: 28.0,
        ),
        const SizedBox(width: 8),
        ButtonIcon(
          icon: Icons.search,
          iconColor: Colors.black,
          iconSize: 28.0,
        ),
      ],
    );
  }
}
