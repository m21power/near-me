import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:near_me/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:near_me/features/chat/presentation/pages/chat_page.dart';
import 'package:near_me/features/home/domain/entities/entity.dart';
import 'package:near_me/features/home/presentation/bloc/Home/home_bloc.dart';
import 'package:near_me/features/home/presentation/widgets/custom_drawer.dart';
import 'package:near_me/features/location/presentation/bloc/location_bloc.dart';
import 'package:near_me/features/location/presentation/pages/map_page.dart';
import 'package:near_me/features/notification/domain/entities/notif_entities.dart';
import 'package:near_me/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:near_me/features/notification/presentation/pages/notification_page.dart';
import 'package:near_me/features/post/presentation/pages/post_page.dart';

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
  bool showDial = false;
  bool showSearchDialog = false;
  bool isSearching = false;
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
            if (homeState is SearchUserSuccessState) {
              searchedUsers = homeState.user;
              showSearchDialog = true;
              isSearching = false;
            }

            if (showSearchDialog) {
              var value = await showSearchedUsers();
              if (value == null || value == false) {
                showSearchDialog = false;
              }
            }
            if (homeState is SearchUserFailureState) {}
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
                body: homeState is SearchLoadState
                    ? const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.transparent,
                        ),
                      )
                    : Container(
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

  Future<bool?> showSearchedUsers() async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Users"),
          content: SizedBox(
            width: double.maxFinite, // Makes dialog width flexible
            height: MediaQuery.of(context)
                .size
                .height, // Set a fixed height for the list
            child: searchedUsers.isNotEmpty
                ? ListView.builder(
                    itemCount: searchedUsers.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) => Profile(),
                  )
                : Center(
                    child: Text("User not found"),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget Profile() {
    return ListTile(
      onTap: () {},
      leading: CircleAvatar(
        backgroundImage: AssetImage('assets/male.png'),
      ),
      title: Text('Mesay'),
      subtitle: Text('Computer Science'),
    );
  }
}
