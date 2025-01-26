import 'package:flutter/material.dart';
import 'package:termscope/controllers/side_navigation.dart';
import 'package:termscope/views/pages/edit_page.dart';
import 'package:termscope/views/pages/ssh_list_page.dart';
import 'package:termscope/views/top_menu_list.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SSHListPage(),
    const EditListPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final double menuHeight = MediaQuery.of(context).size.height * 0.05;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: menuHeight,
              child: const TopMenuList(),
            ),
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: Row(
                children: [
                  SideNavigation(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                    child: _pages[_selectedIndex],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
