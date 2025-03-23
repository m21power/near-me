import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:near_me/core/constants/user_status.dart';
import 'package:near_me/core/shimmer_effect.dart';
import 'package:near_me/core/util/cache_manager.dart';
import 'package:near_me/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:near_me/features/chat/presentation/pages/chat_page.dart';
import 'package:near_me/features/home/domain/entities/connection_model.dart';
import 'package:near_me/features/home/domain/entities/entity.dart';
import 'package:near_me/features/home/presentation/bloc/Home/home_bloc.dart';
import 'package:near_me/features/home/presentation/widgets/custom_drawer.dart';
import 'package:near_me/features/location/presentation/bloc/location_bloc.dart';
import 'package:near_me/features/location/presentation/pages/map_page.dart';
import 'package:near_me/features/notification/domain/entities/notif_entities.dart';
import 'package:near_me/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:near_me/features/notification/presentation/pages/notification_page.dart';
import 'package:near_me/features/post/presentation/pages/post_page.dart';

import '../../../../core/constants/user_constant.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/pages/my_profile_page.dart';
import '../../../profile/presentation/pages/user_profile_page.dart';

class TopBar extends StatefulWidget {
  @override
  State<TopBar> createState() => _TopBarState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class _TopBarState extends State<TopBar> {
  bool openSearchTextField = false;
  int totalUnreadChatCount = 0;
  int totalUnseenNotCount = 0;
  List<NotificationModel> notiModels = [];
  TextEditingController searchController = TextEditingController();
  List<SearchedUser> searchedUsers = [];
  List<ConnectionModel> myConnection = [];
  bool showDial = false;
  bool showSearchDialog = false;
  bool isSearching = false;
  bool showConnDialog = false;
  bool myConLoadStae = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, locationState) {
        if (locationState is LocationDisabledState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showLocationDialog(context);
          });
        }
        return BlocConsumer<HomeBloc, HomeState>(
          listener: (context, homeState) async {
            print("homestate : $homeState");
            print(isSearching);
            print(showSearchDialog);
            if (homeState is SearchLoadState) {
              isSearching = true;
            } else {
              isSearching = false;
            }
            if (homeState is SearchUserSuccessState) {
              searchedUsers = homeState.user;
              showSearchDialog = true;
            }
            if (homeState is GetMyConnectionsLoadingState) {
              myConLoadStae = true;
            } else {
              myConLoadStae = false;
            }
            if (homeState is GetMyConnectionsSuccessState) {
              myConnection = homeState.users;
              showConnDialog = true;
            }

            if (showSearchDialog || isSearching) {
              var value = await showSearchedUsers(isSearching);
              if (value == null || value == false) {
                showSearchDialog = false;
                isSearching = false;
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(false);
                }
              }
            }
            if (showConnDialog || myConLoadStae) {
              var value = await myConnectionsDialog(isSearching, myConnection);
              if (value == null || value == false) {
                myConLoadStae = false;
                showConnDialog = false;
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(false);
                }
              }
            }

            if (homeState is SearchUserFailureState) {}
            if (homeState is GetMyConnectionsFailureState) {}
          },
          builder: (context, homeState) {
            return DefaultTabController(
              length: 3,
              child: Scaffold(
                key: _scaffoldKey,
                drawer: customDrawer(context),
                extendBodyBehindAppBar: true,
                backgroundColor: Theme.of(context).colorScheme.background,
                appBar: AppBar(
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.menu,
                        color: Theme.of(context).colorScheme.onPrimary),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        if (searchController.text.trim().isNotEmpty) {
                          context
                              .read<HomeBloc>()
                              .add(SearchUserEvent(searchController.text));
                          searchController.clear();
                          openSearchTextField = false;
                        } else {
                          setState(() {
                            openSearchTextField = false;
                          });
                        }
                      },
                      icon: Icon(Icons.search),
                    ),
                    IconButton(
                      icon: BlocBuilder<NotificationBloc, NotificationState>(
                        builder: (context, notState) {
                          if (notState is GetNotificationSuccessState) {
                            totalUnseenNotCount = notState.totalUnreadCount;
                            notiModels = notState.notification;
                          }
                          return Stack(children: [
                            Icon(Icons.notifications,
                                size: 30,
                                color: Theme.of(context).colorScheme.onPrimary),
                            totalUnseenNotCount != 0
                                ? Positioned(
                                    top: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 9,
                                      backgroundColor: Colors.red,
                                      child: Text(
                                        totalUnseenNotCount > 9
                                            ? "9+"
                                            : totalUnseenNotCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ]);
                        },
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationPage(
                                      notiModels: notiModels,
                                    )));
                      },
                    ),
                  ],
                  title: openSearchTextField
                      ? TextField(
                          controller: searchController,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Search...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              openSearchTextField = true;
                            });
                          },
                          child: Text(
                            'Near Me',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                  centerTitle: true,
                  bottom: TabBar(
                    indicatorColor: Theme.of(context).colorScheme.onPrimary,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(
                        icon: FaIcon(FontAwesomeIcons.faceGrinTears,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      Tab(
                        icon: BlocBuilder<ChatBloc, ChatState>(
                          builder: (context, state) {
                            if (state is GetChatEntitiesState) {
                              totalUnreadChatCount =
                                  state.chatEntites.last.totalUnreadCount;
                            }
                            return Stack(
                              children: [
                                FaIcon(FontAwesomeIcons.rocketchat,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                                totalUnreadChatCount != 0
                                    ? Positioned(
                                        top: 0,
                                        right: 0,
                                        child: CircleAvatar(
                                          radius: 9,
                                          backgroundColor: Colors.red,
                                          child: Text(
                                            totalUnreadChatCount > 9
                                                ? "9+"
                                                : totalUnreadChatCount
                                                    .toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            );
                          },
                        ),
                      ),
                      Tab(
                        icon: FaIcon(FontAwesomeIcons.streetView,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ],
                  ),
                ),
                body: Container(
                  child: TabBarView(
                    children: [PostPage(), ChatPage(), MapPage()],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLocationDialog(BuildContext context) {
    // Show the dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (context) {
        return AlertDialog(
          title: const Text("Location Disabled"),
          content: const Text(
              "To continue, please enable location services in your settings."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Geolocator.openLocationSettings();
              },
              child: const Text("Enable"),
            ),
          ],
        );
      },
    );

    // Start a timer to check if location is enabled
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        timer.cancel(); // Stop checking
        if (context.mounted) {
          Navigator.of(context).pop(); // Close the dialog
        }
      }
    });
  }

  Future<bool?> showSearchedUsers(bool isSearching) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        // if (Navigator.of(context).canPop()) {
        //   Navigator.of(context).pop();
        // }
        return AlertDialog(
          title: const Text("Users"),
          content: SizedBox(
            width: double.maxFinite, // Makes dialog width flexible
            height: MediaQuery.of(context)
                .size
                .height, // Set a fixed height for the list
            child: isSearching
                ? ChatShimmerScreen()
                : searchedUsers.isNotEmpty
                    ? ListView.builder(
                        itemCount: searchedUsers.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) =>
                            Profile(searchedUsers[index]),
                      )
                    : Center(
                        child: Text("User not found"),
                      ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget Profile(SearchedUser user) {
    return ListTile(
      onTap: () {
        var userid = user.id;
        context.read<ProfileBloc>().add(GetUserByIdEvent(userid));
        if (userid == UserConstant().getUserId()) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => MyProfilePage()));
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UserProfilePage()));
        }
      },
      leading: CircleAvatar(
        backgroundImage: user.gender == 'male'
            ? AssetImage('assets/male.png')
            : AssetImage('assets/woman.png'),
        foregroundImage: user.profilePic != ''
            ? CachedNetworkImageProvider(user.profilePic,
                cacheManager: MyCacheManager())
            : null,
      ),
      title: Text(user.name),
      subtitle: Text(user.major != "" ? user.major : "No major avialable"),
    );
  }

  Future<bool?> myConnectionsDialog(
      bool isSearching, List<ConnectionModel> users) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("My Connections"),
          content: SizedBox(
            width: double.maxFinite, // Makes dialog width flexible
            height: MediaQuery.of(context)
                .size
                .height, // Set a fixed height for the list
            child: isSearching
                ? ChatShimmerScreen()
                : users.isNotEmpty
                    ? ListView.builder(
                        itemCount: users.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) =>
                            myConnectionsProfile(users[index]),
                      )
                    : const Center(
                        child: Text("No connection yet"),
                      ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget myConnectionsProfile(ConnectionModel user) {
    return ListTile(
      onTap: () {
        var userid = user.id;
        context.read<ProfileBloc>().add(GetUserByIdEvent(userid));
        if (userid == UserConstant().getUserId()) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => MyProfilePage()));
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => UserProfilePage()));
        }
      },
      leading: CircleAvatar(
        backgroundImage: user.gender == 'male'
            ? const AssetImage('assets/male.png')
            : const AssetImage('assets/woman.png'),
        foregroundImage: user.profilePic != ''
            ? CachedNetworkImageProvider(user.profilePic,
                cacheManager: MyCacheManager())
            : null,
      ),
      title: Text(user.name),
      subtitle: Text(userStatus[user.id]['online']
          ? "Online"
          : DateFormat('hh:mm a')
              .format(DateTime.parse(userStatus[user.id]['lastSeen']))),
    );
  }
}
