import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:near_me/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:near_me/features/chat/presentation/pages/chat_page.dart';
import 'package:near_me/features/home/presentation/widgets/custom_drawer.dart';
import 'package:near_me/features/location/presentation/bloc/location_bloc.dart';
import 'package:near_me/features/location/presentation/pages/map_page.dart';
import 'package:near_me/features/post/presentation/pages/post_page.dart';

class TopBar extends StatefulWidget {
  @override
  State<TopBar> createState() => _TopBarState();
}

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class _TopBarState extends State<TopBar> {
  bool isSearching = false;
  int totalUnreadCount = 0;
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

  bool showDial = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, locationState) {
        if (locationState is LocationDisabledState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showLocationDialog(context);
          });
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            key: _scaffoldKey,
            drawer: customDrawer(context),
            extendBodyBehindAppBar: true,
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              elevation: 0,
              // backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: Icon(Icons.menu,
                    color: Theme.of(context).colorScheme.onPrimary),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.search,
                      color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.notifications,
                      color: Theme.of(context).colorScheme.onPrimary),
                  onPressed: () {},
                ),
              ],
              title: isSearching
                  ? TextField(
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
                  : Text(
                      'Near Me',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
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
                          totalUnreadCount =
                              state.chatEntites.last.totalUnreadCount;
                        }
                        return Stack(
                          children: [
                            FaIcon(FontAwesomeIcons.rocketchat,
                                color: Theme.of(context).colorScheme.onPrimary),
                            totalUnreadCount != 0
                                ? Positioned(
                                    top: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 9,
                                      backgroundColor: Colors.red,
                                      child: Text(
                                        totalUnreadCount > 9
                                            ? "9+"
                                            : totalUnreadCount.toString(),
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
  }
}
