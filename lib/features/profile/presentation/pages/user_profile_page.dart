import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/shimmer_effect.dart';
import 'package:near_me/features/chat/domain/entities/chat_entities.dart';
import 'package:near_me/features/chat/presentation/pages/conversation_page.dart';
import 'package:near_me/features/post/domain/enitities/post_entities.dart';
import 'package:near_me/features/post/presentation/bloc/Post_bloc/bloc/home_post_bloc.dart';
import 'package:near_me/features/profile/presentation/bloc/profile_bloc.dart';

import '../../../Auth/domain/entities/user_entities.dart';
import '../../../chat/presentation/bloc/conversation/bloc/conversation_bloc.dart';
import '../../../post/presentation/widgets/posts.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

bool isConnected = false;
bool sentConnection = false;
bool didNotAcceptTheRequestYet = false;
UserModel? userModel;
List<PostModel> userPosts = [];
HashSet<int> likedPostIds = HashSet<int>();
bool isLoading = true;

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            if (isConnected)
              IconButton(
                onPressed: () {
                  if (userModel != null) {
                    var user = UserConstant().getUser();
                    context.read<ConversationBloc>().add(GetMessageEvent(
                          userModel!.id,
                        ));
                    ChatEntities chatEntity = ChatEntities(
                        chatId: '',
                        lastMessage: '',
                        lastMessageTime: Timestamp.now(),
                        user1Id: user!.id,
                        user2Name: userModel!.name,
                        user2Id: userModel!.id,
                        user2ProfilePic: userModel!.photoUrl ?? '',
                        unreadCount: 0,
                        totalUnreadCount: 0,
                        user2Gender: userModel!.gender,
                        user1Gender: user.gender ?? '',
                        user1Name: user.name ?? '',
                        user1ProfilePic: user.photoUrl ?? '');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ConversationPage(
                                chatEntity: chatEntity, amUser1: true)));
                  }
                },
                icon: FaIcon(FontAwesomeIcons.rocketchat,
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
            if (!isConnected && sentConnection)
              IconButton(
                onPressed: () {},
                icon: FaIcon(FontAwesomeIcons.userCheck,
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
            if (!isConnected && !sentConnection)
              if (didNotAcceptTheRequestYet)
                ElevatedButton(
                    onPressed: () {
                      context
                          .read<ProfileBloc>()
                          .add(AcceptConReqEvent(userModel!.id));
                    },
                    child: Text("Accept"))
              else
                IconButton(
                  onPressed: () {
                    context
                        .read<ProfileBloc>()
                        .add(SendConnectionRequest(userModel!.id));
                  },
                  icon: FaIcon(FontAwesomeIcons.userPlus,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
          ],
        ),
        body: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is CheckConnectionSuccessState) {
              if (state.connectionReqModel.status == 'accepted') {
                setState(() {
                  isConnected = true;
                });
              } else if (state.connectionReqModel.from ==
                  UserConstant().getUserId()) {
                setState(() {
                  sentConnection = true;
                });
              } else if (state.connectionReqModel.from !=
                  UserConstant().getUserId()) {
                setState(() {
                  didNotAcceptTheRequestYet = true;
                });
              }
            }
            if (state is SendConReqSuccessState) {
              setState(() {
                sentConnection = true;
              });
            }
            if (state is GetUserByIdSuccessState) {
              userModel = state.userModel;
              context
                  .read<ProfileBloc>()
                  .add(CheckConnectionEvent(userModel!.id));
              context.read<HomePostBloc>().add(GetUserPostEvent(userModel!.id));
            }
            if (state is GetUserByidFailedState) {
              showError(state.message);
            }
            if (state is SendConReqFailuerState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is AcceptConReqSuccessState) {
              setState(() {
                isConnected = true;
              });
            }
            if (state is AcceptConReqFailureState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileInitial || userModel == null) {
              return ShimmerProfilePage();
            }
            return Column(
              children: [
                // Top Section (Background + Profile Image)
                profileBar(),

                // Scrollable Content
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // User Info
                        Text(userModel!.name,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(
                            userModel!.university == ''
                                ? 'No University/College available'
                                : userModel!.university,
                            style: const TextStyle(fontSize: 16)),
                        Text(
                            userModel!.major == ''
                                ? 'No major available'
                                : userModel!.major,
                            style: const TextStyle(fontSize: 16)),

                        const SizedBox(height: 10),

                        // Bio
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            (userModel!.bio?.isEmpty ?? true)
                                ? "No bio available"
                                : userModel!.bio!,
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
                      ],
                    ),
                  ),
                ),

                BlocConsumer<HomePostBloc, HomePostState>(
                    listener: (context, homePostState) {
                  print(homePostState);
                  if (homePostState is GetUserPostsSuccessState) {
                    userPosts = homePostState.posts;
                    likedPostIds = homePostState.likedIds;
                  }
                  if (homePostState is GetUserPostsInitialState) {
                    isLoading = true;
                  } else {
                    isLoading = false;
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
              ],
            );
          },
        ),
      ),
    );
  }

  Stack profileBar() {
    return Stack(
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
        Positioned(
          top: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/male.png"),
                foregroundImage: userModel!.photoUrl != null
                    ? NetworkImage(userModel!.photoUrl!)
                    : null,
              ),
            ],
          ),
        ),
      ],
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
}
