import 'package:flutter/material.dart';
import 'package:termscope/views/widgets/button_icon.dart';

class SideNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const SideNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRailTheme(
      data: const NavigationRailThemeData(
        indicatorColor: Colors.transparent,
        useIndicator: false,
      ),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        labelType: NavigationRailLabelType.none,
        backgroundColor: const Color.fromARGB(255, 38, 38, 38), 
        destinations: [
          _buildCustomDestination(
            index: 0,
            icon: Icons.home,
            selectedIndex: selectedIndex,
          ),
          _buildCustomDestination(
            index: 1,
            icon: Icons.settings,
            selectedIndex: selectedIndex,
          ),
        ],
      ),
    );
  }

  NavigationRailDestination _buildCustomDestination({
    required int index,
    required IconData icon,
    required int selectedIndex,
  }) {
    final isSelected = selectedIndex == index;

    return NavigationRailDestination(
      icon: Container(
        width: 36.0,
        height: 36.0,
        color: isSelected
            ? const Color.fromARGB(255, 59, 59, 59)
            : Colors.transparent,
        child: ButtonIcon(
          icon: icon,
          iconColor: Colors.white,
          iconSize: 24.0,
          callback: () {
            onDestinationSelected(index);
          },
        ),
      ),
      selectedIcon: Container(
        width: 36.0,
        height: 36.0,
        color: const Color.fromARGB(255, 59, 59, 59),
        child: ButtonIcon(
          icon: icon,
          iconColor: Colors.white,
          iconSize: 24.0,
          callback: () {
            onDestinationSelected(index);
          },
        ),
      ),
      label: const Text(''),
    );
  }
}
