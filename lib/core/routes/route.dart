import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:near_me/core/constants/route_constant.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:near_me/features/Auth/presentation/pages/forgot_passowrd_page.dart';
import 'package:near_me/features/Auth/presentation/pages/sign_up_page.dart';
import 'package:near_me/features/Auth/presentation/pages/verify_email_page.dart';
import 'package:near_me/features/Auth/presentation/pages/welcome_page.dart';
import 'package:near_me/features/chat/presentation/bloc/conversation/bloc/conversation_bloc.dart';
import 'package:near_me/features/home/presentation/home.dart';
import 'package:near_me/features/home/presentation/pages/top_bar.dart';
import 'package:near_me/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:near_me/features/post/presentation/bloc/Post_bloc/bloc/home_post_bloc.dart';
import 'package:near_me/features/post/presentation/bloc/post_bloc.dart';
import 'package:near_me/splash_screen.dart';

import '../../features/Auth/presentation/pages/login_page.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: RouteConstant.welcomePageRoute,
      builder: (context, state) {
        return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
          if (state is AuthLoggedInSuccessState) {
            UserConstant().setUser();
            context.read<ChatBloc>().add(GetChatEvent());
            context.read<ConversationBloc>().add(GetConnectedUsersId());
            context.read<NotificationBloc>().add(GetNotificationEvent());
            context.read<HomePostBloc>().add(GetPostsEvent());
            context.read<HomePostBloc>().add(GetLikedPostsEvent());
            return TopBar();
          } else if (state is AuthLoggedInFailedState) {
            return WelcomePage();
          } else {
            return SplashScreen();
          }
        });
      },
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
    GoRoute(
      path: '/forgotPassword',
      name: RouteConstant.forgotPasswordPageRoute,
      builder: (context, state) => ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/topBar',
      name: RouteConstant.topBarPageRoute,
      builder: (context, state) => TopBar(),
    ),
  ],
);
