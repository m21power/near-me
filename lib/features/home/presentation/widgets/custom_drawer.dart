import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/util/cache_manager.dart';
import 'package:near_me/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:near_me/features/home/presentation/bloc/Home/home_bloc.dart';
import 'package:near_me/features/post/presentation/bloc/Post_bloc/bloc/home_post_bloc.dart';
import 'package:near_me/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:near_me/features/profile/presentation/pages/about_page.dart';
import 'package:near_me/features/profile/presentation/pages/my_profile_page.dart';
import 'package:path/path.dart';

import '../bloc/ThemeBloc/theme_bloc.dart';

Drawer customDrawer(BuildContext context) {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  var user = UserConstant().getUser();
  return Drawer(
    width: 270,
    child: Column(
      children: [
        // Profile Header
        BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            print("state: $state");
            user = UserConstant().getUser();
            print(user!.toJson());
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MyProfilePage();
                }));
              },
              child: DrawerHeader(
                // Key based on user photo URL
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: user != null
                          ? (user!.backgroundUrl != null &&
                                  user!.backgroundUrl != "")
                              ? CachedNetworkImageProvider(user!.backgroundUrl!,
                                  cacheManager: MyCacheManager())
                              : const AssetImage("assets/background-image.png")
                                  as ImageProvider
                          : const AssetImage("assets/background-image.png")
                              as ImageProvider),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: user == null
                            ? const AssetImage("assets/logo.png")
                            : user!.gender == 'male'
                                ? const AssetImage('assets/male.png')
                                : const AssetImage('assets/woman.png'),
                        foregroundImage:
                            (user?.photoUrl != null && user?.photoUrl != '')
                                ? CachedNetworkImageProvider(
                                    cacheManager: MyCacheManager(),
                                    user!.photoUrl!)
                                : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.name ?? "Guest User",
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Drawer Items
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerItem(
                icon: Icons.person,
                text: "My Profile",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return MyProfilePage();
                  }));
                },
              ),
              _buildDrawerItem(
                icon: Icons.people,
                text: "Connections",
                onTap: () {
                  context.read<HomeBloc>().add(GetMyConnectionsEvent());
                },
              ),
              _buildDrawerItem(
                icon: Icons.info,
                text: "About",
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AboutPage()));
                },
              ),
            ],
          ),
        ),

        // Theme Switch & Logout
        Column(
          children: [
            Divider(),
            ListTile(
              leading: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                  key: ValueKey<bool>(isDarkMode),
                  color: isDarkMode ? Colors.amber : Colors.orange,
                ),
              ),
              title: const Text("Toggle Theme"),
              onTap: () {
                BlocProvider.of<ThemeBloc>(context).toggleTheme();
              },
            ),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return _buildDrawerItem(
                  icon: Icons.logout,
                  text: "Logout",
                  onTap: () {
                    context.read<AuthBloc>().add(LogOutEvent());
                  },
                  color: Colors.redAccent,
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ],
    ),
  );
}

// Reusable Drawer Item Widget
Widget _buildDrawerItem({
  required IconData icon,
  required String text,
  required VoidCallback onTap,
  Color? color,
}) {
  return ListTile(
    leading: Icon(icon, color: color ?? Colors.blueGrey),
    title: Text(text, style: TextStyle(fontSize: 16)),
    onTap: onTap,
  );
}
