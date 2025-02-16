import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constant.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  void fun() {}
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
                  "Sign in",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                SizedBox(
                  height: height * 0.1,
                ),
                emailTile(context),
                SizedBox(
                  height: height * 0.03,
                ),
                passwordTile(context, obscureText),
                SizedBox(
                  height: height * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          print("Forget password?");
                        },
                        child: Text(
                          "Forget password?",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: height * 0.1,
                ),
                Column(
                  children: [
                    SizedBox(
                      width: width * 0.8,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Login'),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Text("Don't have an account? Sign up"),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    SizedBox(
                      width: width * 0.8,
                      child: ElevatedButton(
                        onPressed: () {
                          context.goNamed(RouteConstant.signUpPageRoute);
                        },
                        child: const Text('Sign up'),
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

  Padding passwordTile(BuildContext context, bool obscureText) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return TextField(
              controller: passwordController,
              obscureText: obscureText,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Enter your password',
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

  Padding emailTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: TextField(
          controller: emailController,
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'Enter your email'),
        ),
      ),
    );
  }
}
