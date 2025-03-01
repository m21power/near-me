import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_me/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:near_me/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:near_me/features/profile/presentation/pages/my_profile_page.dart';
import 'package:near_me/features/profile/presentation/pages/user_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/constant.dart';
import '../../../../dependency_injection.dart';
import '../../../Auth/domain/entities/user_entities.dart';
import '../bloc/ThemeBloc/theme_bloc.dart';

Drawer customDrawer(BuildContext context) {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  bool isMale = jsonDecode(sl<SharedPreferences>()
          .getString(Constant.userPreferenceKey)!)['gender'] ==
      'male';
  var user = UserModel.fromMap(jsonDecode(
      sl<SharedPreferences>().getString(Constant.userPreferenceKey)!));
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
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: isMale
                              ? Image.asset('assets/male.png').image
                              : Image.asset('assets/woman.png').image,
                          foregroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                        ),
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.headlineMedium,
                        )
                      ],
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
            var userId = await sl<FlutterSecureStorage>()
                .read(key: Constant.userIdSecureStorageKey);
            context.read<ProfileBloc>().add(GetUserByIdEvent(userId!));
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
        ListTile(
          title: const Text("Logout"),
          onTap: () {
            context.read<AuthBloc>().add(LogOutEvent());
            context.read<AuthBloc>().add(AuthLoggedInEvent());
          },
        )
      ],
    ),
  );
}

UserModel user = UserModel(
    id: "1234",
    email: "mesaylema21@gmail.com",
    university: "Addis Ababa University",
    major: "Computer Science",
    name: "Mesay",
    photoUrl: "",
    backgroundUrl:
        "https://res.cloudinary.com/dl6vahv6t/image/upload/v1738148949/lm96hcfto9t2rgjqidgp.avif",
    isEmailVerified: true,
    password: "12344321",
    bio:
        "Computer science student, who loves coding that is my bio i want to be a great developer",
    gender: "male");
