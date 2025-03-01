import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:near_me/features/Auth/presentation/bloc/auth_bloc.dart';

import '../../../../core/constants/route_constant.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    bool isLoading = false;
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
                        context.goNamed(RouteConstant.forgotPasswordPageRoute);
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
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthLoginFailedState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                      ),
                    );
                  } else if (state is AuthLoginSuccessState) {
                    context.goNamed(RouteConstant.topBarPageRoute);
                  }
                },
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    bool isLoading = state is AuthLoading;

                    return Column(
                      children: [
                        SizedBox(
                          width: width * 0.8,
                          child: ElevatedButton(
                            onPressed: () {
                              if (passwordController.text.isNotEmpty &&
                                  emailController.text.isNotEmpty) {
                                context.read<AuthBloc>().add(LoginEvent(
                                    emailController.text,
                                    passwordController.text));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please fill all the fields"),
                                  ),
                                );
                              }
                            },
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  )
                                : const Text("Login"),
                          ),
                        ),
                      ],
                    );
                  },
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
          ),
        )),
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
