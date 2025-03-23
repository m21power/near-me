import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/util/cache_manager.dart';
import 'package:near_me/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:near_me/features/post/presentation/bloc/Post_bloc/bloc/home_post_bloc.dart';
import 'package:near_me/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:near_me/features/profile/presentation/pages/about_page.dart';
import 'package:near_me/features/profile/presentation/pages/my_profile_page.dart';

import '../bloc/ThemeBloc/theme_bloc.dart';

Drawer customDrawer(BuildContext context) {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  var user = UserConstant().getUser();
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
                        context
                            .read<HomePostBloc>()
                            .add(GetUserPostEvent(UserConstant().getUserId()!));
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return MyProfilePage();
                        }));
                      },
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: user == null
                                ? Image.asset("assets/meme.png").image
                                : user!.gender == 'male'
                                    ? Image.asset('assets/male.png').image
                                    : Image.asset('assets/woman.png').image,
                            foregroundImage:
                                (user!.photoUrl != null && user!.photoUrl != '')
                                    ? CachedNetworkImageProvider(
                                        cacheManager: MyCacheManager(),
                                        user!.photoUrl!)
                                    : null,
                          ),
                          Text(
                            user!.name,
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
            context
                .read<HomePostBloc>()
                .add(GetUserPostEvent(UserConstant().getUserId()!));
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return MyProfilePage();
            }));
          },
        ),
        ListTile(
          title: const Text('Connections'),
          onTap: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text("Coming soon ...")));
          },
        ),
        ListTile(
          title: const Text('About'),
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AboutPage()));
          },
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
