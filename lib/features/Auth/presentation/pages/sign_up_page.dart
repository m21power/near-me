import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:near_me/features/Auth/presentation/bloc/auth_bloc.dart';
import '../../../../core/constants/route_constant.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isLoading = false;

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
                if (isLoading)
                  const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(),
                  ),
                Text(
                  "Sign up",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                SizedBox(height: height * 0.1),
                emailTile(context, "Enter your name", nameController),
                SizedBox(height: height * 0.03),
                emailTile(context, "Enter your email", emailController),
                SizedBox(height: height * 0.03),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.3),
                    ),
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextField(
                              controller: passwordController,
                              obscureText: obscureText,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Enter your password",
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            TextField(
                              controller: confirmPasswordController,
                              obscureText: obscureText,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: "Confirm your password",
                                suffixIcon: IconButton(
                                  icon: Icon(obscureText
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      obscureText = !obscureText;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthLoading) {
                      setState(() => isLoading = true);
                    } else {
                      setState(() => isLoading = false);
                    }

                    if (state is EmailValidationSuccessState) {
                      print("the state is $state");
                      context
                          .read<AuthBloc>()
                          .add(AuthRequestOtpEvent(emailController.text));

                      context.goNamed(
                        RouteConstant.verifyEmailPageRoute,
                        extra: {
                          'name': nameController.text,
                          'email': emailController.text,
                          'password': passwordController.text,
                        },
                      );
                    } else if (state is EmailValidationFailedState) {
                      print("the state is $state");

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  child: SizedBox(
                    width: width * 0.8,
                    child: ElevatedButton(
                      onPressed: () {
                        if (passwordController.text.isEmpty ||
                            emailController.text.isEmpty ||
                            confirmPasswordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Please fill all fields")),
                          );
                        } else if (passwordController.text ==
                            confirmPasswordController.text) {
                          context.read<AuthBloc>().add(
                                EmailValidationEvent(emailController.text,
                                    passwordController.text),
                              );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Passwords do not match")),
                          );
                        }
                      },
                      child: isLoading
                          ? CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.onPrimary,
                            )
                          : const Text("Sign up"),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                const Text("Already have an account? Login"),
                SizedBox(height: height * 0.02),
                SizedBox(
                  width: width * 0.8,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.goNamed(RouteConstant.loginPageRoute),
                    child: const Text("Login"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding passwordTile(
      BuildContext context, String label, TextEditingController controller) {
    bool obscureText = true;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return TextField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: label,
                suffixIcon: IconButton(
                  icon: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: label,
          ),
        ),
      ),
    );
  }
}
