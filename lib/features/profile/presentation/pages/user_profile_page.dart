import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../Auth/domain/entities/user_entities.dart';

class UserProfilePage extends StatefulWidget {
  final UserModel user;
  final List<String> userPosts;

  const UserProfilePage(
      {super.key, required this.user, required this.userPosts});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

bool isConnected = true;
bool SendConnection = true;

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (isConnected)
              IconButton(
                onPressed: () {},
                icon: FaIcon(FontAwesomeIcons.rocketchat,
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
            if (!isConnected && SendConnection)
              IconButton(
                onPressed: () {},
                icon: FaIcon(FontAwesomeIcons.userCheck,
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
            if (!isConnected && !SendConnection)
              IconButton(
                onPressed: () {},
                icon: FaIcon(FontAwesomeIcons.userPlus,
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
          ],
        ),
        body: Column(
          children: [
            // Top Section (Background + Profile Image)
            Stack(
              alignment: Alignment.topCenter,
              children: [
                // Background Image
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/background-image.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Profile Image Section
                const Positioned(
                  top: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage("assets/male.png"),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    // User Info
                    Text(widget.user.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(widget.user.university,
                        style: const TextStyle(fontSize: 16)),
                    Text(widget.user.major,
                        style: const TextStyle(fontSize: 16)),

                    const SizedBox(height: 10),

                    // Bio
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        widget.user.bio ?? "No bio available",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // User Posts Section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Posts",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Display user posts in a grid format
                    widget.userPosts.isNotEmpty
                        ? GridView.builder(
                            physics:
                                const NeverScrollableScrollPhysics(), // Disables inner scroll
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // 3 columns
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              childAspectRatio: 1, // Makes images square
                            ),
                            itemCount: widget.userPosts.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(widget.userPosts[index],
                                    fit: BoxFit.cover),
                              );
                            },
                          )
                        : const Center(child: Text("No posts available")),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
