import 'package:deli4route/core/colors/app_colors.dart';
import 'package:deli4route/features/home/pages/create_route_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => CreateRoutePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(250, 70),
                backgroundColor: AppColors.activeDefaultButton,
              ),
              child: Text(
                'Create Route',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
