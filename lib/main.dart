import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:near_me/dependency_injection.dart';
import 'package:near_me/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:near_me/features/home/presentation/bloc/ThemeBloc/theme_bloc.dart';
import 'package:near_me/features/location/presentation/bloc/location_bloc.dart';
import 'package:near_me/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/core.dart';
import 'core/routes/route.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await init();
  await dotenv.load(fileName: ".env");
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
        BlocProvider(
            create: (context) => sl<AuthBloc>()..add(AuthLoggedInEvent())),
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(
          create: (context) => sl<LocationBloc>(),
        ),
        BlocProvider(create: (context) => sl<ProfileBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: sl<SharedPreferences>().getBool('isDarkMode') == true
                ? ThemeMode.dark
                : ThemeMode.light,
            title: 'Near Me',
            routerConfig: router,
          );
        },
      ),
    );
  }
}

class SampleBloc extends Cubit<int> {
  SampleBloc() : super(0);

  void increment() => emit(state + 1);
}
