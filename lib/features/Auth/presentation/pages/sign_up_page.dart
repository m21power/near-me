import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constant.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    bool obscureText = true;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Sign up",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                SizedBox(
                  height: height * 0.1,
                ),
                emailTile(context, "Enter your name", nameController),
                SizedBox(
                  height: height * 0.03,
                ),
                emailTile(context, "Enter your email", emailController),
                SizedBox(
                  height: height * 0.03,
                ),
                passordTile(context, obscureText, "Enter your password",
                    passwordController),
                SizedBox(
                  height: height * 0.02,
                ),
                passordTile(context, obscureText, "Confirm your password",
                    confirmPasswordController),
                SizedBox(
                  height: height * 0.02,
                ),
                Column(
                  children: [
                    SizedBox(
                      width: width * 0.8,
                      child: ElevatedButton(
                        onPressed: () {
                          context.goNamed(RouteConstant.verifyEmailPageRoute);
                          print(nameController.text);
                          print(emailController.text);
                          print(passwordController.text);
                          print(confirmPasswordController.text);
                        },
                        child: const Text('Sign up'),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Text("Already have an account? Login"),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    SizedBox(
                      width: width * 0.8,
                      child: ElevatedButton(
                        onPressed: () {
                          context.goNamed(RouteConstant.loginPageRoute);
                        },
                        child: const Text('Login'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding passordTile(BuildContext context, bool obscureText, String label,
      TextEditingController passwordController) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return TextField(
              controller: passwordController,
              obscureText: obscureText,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: label,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    print(obscureText);
                    setState(
                      () {
                        obscureText = !obscureText;
                      },
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Padding emailTile(
      BuildContext context, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: TextField(
          controller: controller,
          decoration:
              InputDecoration(border: OutlineInputBorder(), labelText: label),
        ),
      ),
    );
  }
}
