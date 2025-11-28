import 'package:deli4route/core/colors/app_colors.dart';
import 'package:deli4route/features/navigation/pages/history_page.dart';
import 'package:deli4route/features/home/pages/home_page.dart';
import 'package:deli4route/features/navigation/pages/profile_page.dart';
import 'package:deli4route/features/navigation/pages/route_page.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    HomePage(),
    RoutePage(),
    HistoryPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: FlashyTabBar(
        backgroundColor: Colors.grey.shade100,
        selectedIndex: _selectedIndex,
        showElevation: true,
        onItemSelected: (index) => setState(() {
          _selectedIndex = index;
        }),
        items: [
          FlashyTabBarItem(
            activeColor: AppColors.activeDefaultButton,
            inactiveColor: AppColors.inactiveButtonColor,
            icon: Icon(Icons.home, size: 28),
            title: Text('Home'),
          ),
          
          FlashyTabBarItem(
            activeColor: AppColors.activeDefaultButton,
            inactiveColor: AppColors.inactiveButtonColor,
            icon: Icon(Icons.map, size: 28),
            title: Text('Route'),
          ),
          FlashyTabBarItem(
            activeColor: AppColors.activeDefaultButton,
            inactiveColor: AppColors.inactiveButtonColor,
            icon: Icon(Icons.history, size: 28),
            title: Text('History'),
          ),
          FlashyTabBarItem(
            activeColor: AppColors.activeDefaultButton,
            inactiveColor: AppColors.inactiveButtonColor,
            icon: Icon(Icons.person, size: 28),
            title: Text('Profile'),
          ),
        ],
      ),
    );
  }
}
