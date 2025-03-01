import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:near_me/features/Auth/presentation/pages/enter_password_page.dart';

class VerifyOtpPassPage extends StatefulWidget {
  final String email;
  const VerifyOtpPassPage({super.key, required this.email});

  @override
  _VerifyOtpPassPageState createState() => _VerifyOtpPassPageState();
}

class _VerifyOtpPassPageState extends State<VerifyOtpPassPage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  bool isLoading = false; // Add this to manage the loading state

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return SafeArea(
        child: Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Please check your email and enter the OTP we sent you",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              SizedBox(height: height * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Center(
                      child: TextField(
                        style: Theme.of(context).textTheme.labelLarge,
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) => _onChanged(value, index),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height * 0.04),

              // BlocListener to trigger actions without rebuilding UI
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthLoading) {
                    setState(() {
                      isLoading = true;
                    });
                  } else {
                    setState(() {
                      isLoading = false;
                    });
                  }
                  print("State: $state");
                  if (state is AuthVerifyOtpSuccessState) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            EnterPasswordPage(email: widget.email),
                      ),
                    );
                  }
                  if (state is AuthVerifyOtpFailedState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                      ),
                    );
                  }
                },
                child: SizedBox(
                  width: width * 0.8,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null // Disable button when loading
                        : () {
                            String otp = _controllers.map((c) => c.text).join();
                            print("Entered OTP: $otp");
                            context
                                .read<AuthBloc>()
                                .add(AuthVerifyOtpEvent(widget.email, otp));
                          },
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        : const Text("Verify"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
