import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/custom_button.dart';
import '../../features/auth/services/auth_service.dart';
import '../../features/home/ui/screen/home_screen.dart';
import 'splash1_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    // Check for persistent login immediately on startup
    if (AuthService.tryAutoLogin()) {
      // Use microtask to navigate after the build phase
      Future.microtask(() {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/splash2.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Welcome to Med AI",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Elevate your daily care",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _dot(isActive: true),
                    const SizedBox(width: 12),
                    _dot(isActive: false),
                  ],
                ),
                const SizedBox(height: 60),
                CustomButton(
                  text: "Continue",
                  onTap: () {
                    // Check for persistent login
                    if (AuthService.tryAutoLogin()) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Splash1Screen(),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 95),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 12 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isActive ? 1 : 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
