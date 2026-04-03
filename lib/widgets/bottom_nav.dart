import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/log/log_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/settings/settings_screen.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});
  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _index = 0;
  final _screens = const [HomeScreen(), LogScreen(), HistoryScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF222222), width: 1))),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          backgroundColor: const Color(0xFF1A1A1A),
          selectedItemColor: const Color(0xFFE8E8E8),
          unselectedItemColor: const Color(0xFF333333),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          selectedLabelStyle: const TextStyle(fontSize: 8, letterSpacing: 1),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart, size: 20), label: 'HOME'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 20), label: 'LOG'),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart, size: 20), label: 'HISTORY'),
            BottomNavigationBarItem(icon: Icon(Icons.tune, size: 20), label: 'SETTINGS'),
          ],
        ),
      ),
    );
  }
}
