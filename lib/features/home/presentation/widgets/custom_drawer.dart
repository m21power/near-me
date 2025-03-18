import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/util/cache_manager.dart';
import 'package:near_me/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:near_me/features/post/presentation/bloc/post_bloc.dart';
import 'package:near_me/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:near_me/features/profile/presentation/pages/my_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/constant.dart';
import '../../../../dependency_injection.dart';
import '../../../Auth/domain/entities/user_entities.dart';
import '../bloc/ThemeBloc/theme_bloc.dart';

Drawer customDrawer(BuildContext context) {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return Drawer(
    width: 250,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MyProfilePage(
                            userPosts: [],
                          );
                        }));
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                UserConstant().getUser()!.gender == 'male'
                                    ? Image.asset('assets/male.png').image
                                    : Image.asset('assets/woman.png').image,
                            foregroundImage:
                                (UserConstant().getUser()!.photoUrl != null &&
                                        UserConstant().getUser()!.photoUrl !=
                                            '')
                                    ? CachedNetworkImageProvider(
                                        cacheManager: MyCacheManager(),
                                        UserConstant().getUser()!.photoUrl!)
                                    : null,
                          ),
                          Text(
                            UserConstant().getUser()!.name,
                            style: Theme.of(context).textTheme.headlineMedium,
                          )
                        ],
                      ),
                    ),
                    IconButton(
                      icon: isDarkMode
                          ? const Icon(
                              Icons.nightlight_round,
                            )
                          : const Icon(
                              Icons.sunny,
                              color: Colors.amber,
                            ),
                      onPressed: () async {
                        BlocProvider.of<ThemeBloc>(context).toggleTheme();
                      },
                    )
                  ],
                );
              },
            )),
        ListTile(
          title: const Text('My Profile'),
          onTap: () async {
            context.read<PostBloc>().add(GetMyPostEvent());
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return MyProfilePage(
                userPosts: [],
              );
            }));
          },
        ),
        ListTile(
          title: const Text('Connections'),
          onTap: () {},
        ),
        ListTile(
          title: const Text('About'),
          onTap: () {},
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is LogOutSuccessState) {
              context.read<AuthBloc>().add(AuthLoggedInEvent());
            }
            return ListTile(
              title: const Text("Logout"),
              onTap: () {
                context.read<AuthBloc>().add(LogOutEvent());
              },
            );
          },
        )
      ],
    ),
  );
}
