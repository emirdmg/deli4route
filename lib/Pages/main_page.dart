import 'package:deli4route/Colors/app_colors.dart';
import 'package:deli4route/Pages/NavPages/history_page.dart';
import 'package:deli4route/Pages/NavPages/home_page.dart';
import 'package:deli4route/Pages/NavPages/profile_page.dart';
import 'package:deli4route/Pages/NavPages/route_page.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
