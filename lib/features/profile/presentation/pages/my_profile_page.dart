import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me/core/constants/constant.dart';
import 'package:near_me/core/image_picker/image_picker.dart';
import 'package:near_me/core/util/cache_manager.dart';
import 'package:near_me/dependency_injection.dart';
import 'package:near_me/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:near_me/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyProfilePage extends StatefulWidget {
  final List<String> userPosts;

  const MyProfilePage({super.key, required this.userPosts});

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  String? newProfileImage;
  String? newBackgroundImage;
  bool isImageChanged = false; // Track if user changed an image

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            return;
          },
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is UpdateProfileSuccessState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profile updated successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is UpdateProfileFailedState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              var user =
                  sl<SharedPreferences>().getString(Constant.userPreferenceKey);
              var userModel = jsonDecode(user!);
              if (state is UpdatingState) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  // Top Section (Background + Profile Image)
                  profileImageAndBack(userModel),
                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          // User Info
                          Text(userModel['name'] ?? "anonymous",
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text(
                              userModel['university'] == ''
                                  ? "Add University/college"
                                  : userModel['university'],
                              style: Theme.of(context).textTheme.bodyLarge),
                          Text(
                              userModel['major'] == ''
                                  ? "Add Major"
                                  : userModel['major'],
                              style: Theme.of(context).textTheme.bodyLarge),

                          const SizedBox(height: 10),

                          // // Bio
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              userModel['bio'] == ""
                                  ? "No bio available"
                                  : userModel['bio'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Edit Profile Button
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EditProfilePage(user: userModel)));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 12),
                            ),
                            child: const Text("Edit My Profile",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                          ),

                          const SizedBox(height: 20),

                          // User Posts Section
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("My Posts",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Center(child: Text("No posts available")),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Save Button (Only appears if an image is changed)
                  if (isImageChanged)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                        onPressed: () {
                          isImageChanged = false;
                          context.read<ProfileBloc>().add(
                                UpdateProfileEvent(
                                  profileImage:
                                      newProfileImage ?? userModel['photoUrl'],
                                  backgroundImage: newBackgroundImage ??
                                      userModel['backgroundUrl'],
                                  fullName: userModel['name'],
                                  bio: userModel['bio'],
                                  university: userModel['University'],
                                  major: userModel['Major'],
                                ),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Save Changes",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Stack profileImageAndBack(dynamic userModel) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Background Image
        Container(
          height: 200,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: userModel["backgroundUrl"] != null &&
                      userModel["backgroundUrl"] != ""
                  ? CachedNetworkImageProvider(userModel["backgroundUrl"],
                      cacheManager: MyCacheManager())
                  : const AssetImage("assets/background-image.png")
                      as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Change Background Button
        Positioned(
          top: 150,
          right: 10,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () async {
              var result = await sl<ImagePath>().getImagePath();
              result.fold((l) {
                print("failded to fetch iamge");
              }, (r) {
                setState(() {
                  newBackgroundImage = r;
                  isImageChanged = true;
                });
              });
            }, // Pick background image
            child: const Icon(Icons.camera_alt, color: Colors.black),
          ),
        ),

        // Profile Image Section
        Positioned(
          top: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    userModel["photoUrl"] != null && userModel["photoUrl"] != ""
                        ? CachedNetworkImageProvider(userModel["photoUrl"],
                            cacheManager: MyCacheManager())
                        : userModel['gender'] == 'male'
                            ? const AssetImage("assets/male.png")
                            : const AssetImage("assets/woman.png"),
              ),

              // Change Profile Image Button
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 25,
                  width: 25,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4)
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: 10,
                    ),
                    onPressed: () async {
                      var result = await sl<ImagePath>().getImagePath();
                      result.fold((l) {
                        print("failded to fetch iamge");
                      }, (r) {
                        setState(() {
                          newProfileImage = r;
                          isImageChanged = true;
                        });
                      });
                    }, // Pick profile image
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
