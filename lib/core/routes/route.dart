import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:near_me/core/constants/route_constant.dart';
import 'package:near_me/features/Auth/presentation/pages/sign_up_page.dart';
import 'package:near_me/features/Auth/presentation/pages/verify_email_page.dart';
import 'package:near_me/features/Auth/presentation/pages/welcome_page.dart';
import 'package:near_me/features/home/presentation/home.dart';

import '../../features/Auth/presentation/pages/login_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: RouteConstant.welcomePageRoute,
      builder: (context, state) => WelcomePage(),
    ),
    GoRoute(
      path: '/login',
      name: RouteConstant.loginPageRoute,
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/signUp',
      name: RouteConstant.signUpPageRoute,
      builder: (context, state) => SignUpPage(),
    ),
    GoRoute(
      path: '/verifyEmail',
      name: RouteConstant.verifyEmailPageRoute,
      builder: (context, state) => VerifyEmailPage(),
    ),
    GoRoute(
      path: '/home',
      name: RouteConstant.homePageRoute,
      builder: (context, state) => HomePage(),
    ),
  ],
);
