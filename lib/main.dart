import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me/core/service/email_service.dart';
import 'package:near_me/features/Auth/presentation/pages/login_page.dart';
import 'package:near_me/firebase_options.dart';
import 'package:http/http.dart' as http;

import 'core/constants/api_key.dart';
import 'core/core.dart';
import 'core/routes/route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SampleBloc(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        title: 'Near Me',
        routerConfig: router,
      ),
    );
  }
}

class SampleBloc extends Cubit<int> {
  SampleBloc() : super(0);

  void increment() => emit(state + 1);
}
