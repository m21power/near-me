import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:near_me/core/constants/constant.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/image_picker/image_picker.dart';
import 'package:near_me/core/util/cache_manager.dart';
import 'package:near_me/dependency_injection.dart';
import 'package:near_me/features/post/domain/enitities/post_entities.dart';
import 'package:near_me/features/post/presentation/bloc/Post_bloc/bloc/home_post_bloc.dart';
import 'package:near_me/features/post/presentation/bloc/post_bloc.dart';
import 'package:near_me/features/post/presentation/widgets/posts.dart';
import 'package:near_me/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:near_me/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:near_me/features/profile/presentation/widgets/background_pic_alert_dialog.dart';
import 'package:near_me/features/profile/presentation/widgets/show_loading_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../home/presentation/bloc/Internet/bloc/internet_bloc.dart';
import '../widgets/profile_pic_alert_dialog.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  String? newProfileImage;
  String? newBackgroundImage;
  bool isImageChanged = false;
  List<PostModel> userPosts = [];
  HashSet<int> likedPostIds = HashSet<int>();
  bool isLoading = true;
  bool showLoading = false;

  @override
  void initState() {
    context
        .read<HomePostBloc>()
        .add(GetUserPostEvent(UserConstant().getUserId()!));
    super.initState();
  }

  Future<void> _onRefresh() async {
    context
        .read<HomePostBloc>()
        .add(GetUserPostEvent(UserConstant().getUserId()!));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: BlocConsumer<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is UpdatingState) {
                showLoading = true;
              } else {
                showLoading = false;
              }
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
              if (showLoading) {
                showLoadingDialog(context);
              } else {
                hideLoadingDialog(context);
              }
            },
            builder: (context, state) {
              var user =
                  sl<SharedPreferences>().getString(Constant.userPreferenceKey);
              var userModel = jsonDecode(user!);

              return Column(
                children: [
                  // Top Section (Background + Profile Image)
                  profileImageAndBack(userModel),
                  // Scrollable Content
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          // User Info
                          ElevatedButton(
                            onPressed: () {},
                            child: Text(
                                (userModel['name'] == '' ||
                                        userModel['name'] == null)
                                    ? "anonymous"
                                    : userModel['name'],
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 5),
                          Text(
                              (userModel['university'] == '' ||
                                      userModel['university'] == null)
                                  ? "Add University/college"
                                  : userModel['university'],
                              style: Theme.of(context).textTheme.bodyLarge),
                          Text(
                              (userModel['major'] == '' ||
                                      userModel['major'] == null)
                                  ? "Add Major"
                                  : userModel['major'],
                              style: Theme.of(context).textTheme.bodyLarge),

                          const SizedBox(height: 10),

                          // // Bio
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              (userModel['bio'] == "" ||
                                      userModel['bio'] == null)
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
                          postSection(context),
                        ],
                      ),
                    ),
                  ),
                  BlocConsumer<PostBloc, PostState>(
                    listener: (context, postState) {
                      if (postState is CreatePostSuccessState) {
                        context
                            .read<HomePostBloc>()
                            .add(GetUserPostEvent(UserConstant().getUserId()!));
                        context.read<HomePostBloc>().add(GetPostsEvent());
                        showSuccess("Post created successfully");
                      }
                      if (postState is CreatePostFailureState) {
                        showError("Failed to create post");
                      }
                    },
                    builder: (context, postState) {
                      if (postState is PostingState) {
                        print(postState);
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return SizedBox();
                    },
                  ),
                  BlocConsumer<HomePostBloc, HomePostState>(
                      listener: (context, homePostState) {
                    print("my profile: $homePostState");
                    if (homePostState is GetUserPostsInitialState) {
                      isLoading = true;
                    } else {
                      isLoading = false;
                    }
                    if (homePostState is GetUserPostsSuccessState) {
                      userPosts = homePostState.posts;
                      likedPostIds = homePostState.likedIds;
                    }
                    if (homePostState is GetUserPostsFailureState) {
                      userPosts = homePostState.posts;
                      likedPostIds = homePostState.likedIds;
                    }
                  }, builder: (context, homePostState) {
                    return PostCard(
                      posts: userPosts,
                      likedPostIds: likedPostIds,
                      isLoading: isLoading,
                    );
                  }),
                  // Save Button (Only appears if an image is changed)
                  if (isImageChanged) imageChanged(context, userModel),
                  BlocBuilder<InternetBloc, InternetState>(
                    builder: (context, intState) {
                      if (intState is NoInternetConnectionState) {
                        return const Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 10),
                                Text('Connecting...'),
                              ],
                            ),
                          ),
                        );
                      }
                      return SizedBox();
                    },
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Padding postSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("My Posts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: () async {
                var result = await sl<ImagePath>().getImagePath();
                result.fold((l) {
                  print("Error occurred picking image");
                }, (r) {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Confirm Post",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(r),
                                width: 250,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              "Are you sure you want to post this image?",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel",
                                      style: TextStyle(color: Colors.black)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                  ),
                                  onPressed: () {
                                    context
                                        .read<PostBloc>()
                                        .add(CreatePostEvent(r));
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Post",
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              },
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.emoji_emotions_outlined,
                      size: 30,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding imageChanged(BuildContext context, userModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {
          isImageChanged = false;
          context.read<ProfileBloc>().add(
                UpdateProfileEvent(
                  profileImage: newProfileImage ?? userModel['photoUrl'],
                  backgroundImage:
                      newBackgroundImage ?? userModel['backgroundUrl'],
                  fullName: userModel['name'],
                  bio: userModel['bio'],
                  university: userModel['University'],
                  major: userModel['Major'],
                ),
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text("Save Changes",
            style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
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
              image: (userModel["backgroundUrl"] != null &&
                      userModel["backgroundUrl"] != "")
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
                showBackgroundImageDialog(context, r, () {
                  setState(() {
                    newBackgroundImage = r;
                    isImageChanged = true;
                  });
                });
              });
            }, // Pick background image
            child: const Icon(Icons.camera_alt, color: Colors.black),
          ),
        ),
// Container(
//   width: 110, // Adjusted for border
//   height: 110,
//   decoration: BoxDecoration(
//     shape: BoxShape.circle,
//     gradient: LinearGradient(
//       colors: [Colors.purple, Colors.blue], // Change to your preferred colors
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     ),
//   ),
//   child: Padding(
//     padding: const EdgeInsets.all(3), // Border thickness
//     child: CircleAvatar(
//       radius: 50,
//       backgroundColor: Colors.white, // Avoids color mixing
//       backgroundImage: user == null
//           ? const AssetImage("assets/logo.png")
//           : user!.gender == 'male'
//               ? const AssetImage('assets/male.png')
//               : const AssetImage('assets/woman.png'),
//       foregroundImage: (user?.photoUrl != null && user?.photoUrl != '')
//           ? CachedNetworkImageProvider(
//               cacheManager: MyCacheManager(),
//               user!.photoUrl!)
//           : null,
//     ),
//   ),
// )

        // Profile Image Section
        Positioned(
          top: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple,
                      Colors.blue
                    ], // Change to your preferred colors
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: userModel["photoUrl"] != null &&
                            userModel["photoUrl"] != ""
                        ? CachedNetworkImageProvider(userModel["photoUrl"],
                            cacheManager: MyCacheManager())
                        : userModel['gender'] == 'male'
                            ? const AssetImage("assets/male.png")
                            : const AssetImage("assets/woman.png"),
                  ),
                ),
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
                        showProfileImageDialog(context, r, () {
                          setState(() {
                            newProfileImage = r;
                            isImageChanged = true;
                          });
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
