import 'package:deli4route/core/colors/app_colors.dart';
import 'package:deli4route/features/auth/pages/auth_landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            titleWidget: Text(
              "Create Delivery List",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            bodyWidget: Text(
              "Define your delivery points.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            image: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Image.asset(
                'assets/icons/list_items.png',
                width: 96,
                height: 96,
              ),
            ),
          ),
          PageViewModel(
            titleWidget: Text(
              "Upload the List",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            bodyWidget: Text(
              "Wait while the list is converted into a route.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            image: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Image.asset(
                'assets/icons/location.png',
                width: 96,
                height: 96,
              ),
            ),
          ),
          PageViewModel(
            titleWidget: Text(
              "Hit the Road!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            bodyWidget: Text(
              "Use the optimized route. Save time.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            image: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SvgPicture.asset(
                'assets/lets_go.svg',
                width: 96,
                height: 96,
              ),
            ),
          ),
        ],
        dotsDecorator: DotsDecorator(
          color: Colors.orange,
          activeColor: AppColors.inactiveButtonColor,
        ),
        done: Text('Start', style: TextStyle(color: AppColors.activeDefaultButton)),
        showSkipButton: true,
        skip: const Text(
          "Skip",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        next: const Icon(
          Icons.arrow_forward_rounded,
          size: 28,
          color: AppColors.activeDefaultButton
        ),
        onDone: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (builder) => AuthLandingPage()),
          );
        },
        onSkip: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (builder) => AuthLandingPage()),
          );
        },
      ),
    );
  }
}
