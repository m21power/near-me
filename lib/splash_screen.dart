import 'package:flutter/material.dart';
import 'package:near_me/features/Auth/presentation/pages/sign_up_page.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the main screen after 3 seconds
    Timer(Duration(seconds: 3), () {});
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SignUpPage()));
        },
        child: Center(
          child: Shimmer.fromColors(
            baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Your App Logo
                Image.asset(
                  'assets/logo.png', // Replace with your logo
                  width: 120,
                  height: 120,
                ),
                SizedBox(height: 10),

                // App Name (Optional)
                Text(
                  "Near Me",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dummy Home Screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(child: Text("Welcome to Near Me!")),
    );
  }
}
