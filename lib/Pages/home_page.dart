import 'package:deli4route/Colors/app_colors.dart';
import 'package:deli4route/Pages/NavPages/addresses_page.dart';
import 'package:deli4route/Pages/NavPages/history_page.dart';
import 'package:deli4route/Pages/NavPages/profile_page.dart';
import 'package:deli4route/Pages/NavPages/route_page.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    AddressesPage(),
    HistoryPage(),
    ProfilePage(),
    RoutePage()
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
            icon: Icon(Icons.location_pin),
            title: Text('Route')
            ),
          FlashyTabBarItem(
            activeColor: AppColors.activeDefaultButton,
            inactiveColor: AppColors.inactiveButtonColor,
            icon: Icon(Icons.map),
            title: Text('Addresses')
            ),
          FlashyTabBarItem(
            activeColor: AppColors.activeDefaultButton,
            inactiveColor: AppColors.inactiveButtonColor,
            icon: Icon(Icons.history),
            title: Text('History'),
          ),
          FlashyTabBarItem(
            activeColor: AppColors.activeDefaultButton,
            inactiveColor: AppColors.inactiveButtonColor,
            icon: Icon(Icons.person),
            title: Text('Profile')
            ),
        ],
      ),
    );
  }
}
