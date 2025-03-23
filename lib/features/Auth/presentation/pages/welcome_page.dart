import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constant.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: Image.asset("assets/logo.png"),
              ),
              Text(
                "Welcome to Near Me",
                style: Theme.of(context).textTheme.displayMedium,
              ),
              SizedBox(height: height * 0.1),
              SizedBox(
                width: width * 0.7,
                child: ElevatedButton(
                  onPressed: () {
                    context.goNamed(RouteConstant.loginPageRoute);
                  },
                  child: Text("Login"),
                ),
              ),
              SizedBox(height: height * 0.02),
              TextButton(
                onPressed: () {
                  context.goNamed(RouteConstant.signUpPageRoute);
                },
                child: Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
