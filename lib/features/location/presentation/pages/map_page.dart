import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/util/cache_manager.dart';
import 'package:near_me/features/Auth/domain/entities/user_entities.dart';
import 'package:near_me/features/location/domain/entities/user_entity_loc.dart';
import 'package:near_me/features/location/presentation/bloc/location_bloc.dart';
import 'package:near_me/features/profile/presentation/pages/my_profile_page.dart';

import '../../../home/presentation/bloc/Internet/bloc/internet_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/pages/user_profile_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  // LatLng myLocation = const LatLng(9.031859697470294, 38.763446899832886);
  LatLng myLocation = UserConstant().getLocation() ??
      LatLng(9.031859697470294, 38.763446899832886);
  bool isLoading = false;
  List<UserLocEntity> userLoc = [];
  int _dotsCount = 1;
  late Timer _timer;
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Start the dots cycle
  void _startDotCycle() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        // Cycle through 1 dot, 2 dots, 3 dots, then back to 1 dot
        _dotsCount = (_dotsCount % 3) + 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    UserModel user = UserConstant().getUser()!;

    return BlocConsumer<LocationBloc, LocationState>(
      listener: (context, state) {
        print("state: $state");
        if (state is GetNearbyUsersSuccessState) {
          setState(() {
            userLoc = state.nearbyUsers;
            _timer?.cancel();
            isFetching = false;
          });
        }
        if (state is GetNearbyUsersFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
          _timer?.cancel();
          isFetching = false;
        }
        if (state is NearbyUserFetchingState) {
          setState(() {
            _startDotCycle();
            isFetching = true;
          });
        }
        if (UserConstant().getLocation() != myLocation &&
            UserConstant().getLocation() != null) {
          myLocation = UserConstant().getLocation()!;
          Future.delayed(Duration(milliseconds: 200), () {
            if (mounted) {
              mapController.move(myLocation, 15);
            }
          });
          isLoading = false;
        }
      },
      builder: (context, state) {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Stack(
          children: [
            // Map takes the full screen
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialZoom: 15,
                initialCenter: myLocation,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag |
                      InteractiveFlag.flingAnimation |
                      InteractiveFlag.pinchMove |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  tileProvider: FMTCTileProvider(
                    stores: const {
                      'mapStore': BrowseStoreStrategy.readUpdateCreate
                    },
                  ),
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: [
                  buildMarker(
                    UserLocEntity(
                        userId: UserConstant().getUserId()!,
                        name: 'Me',
                        email: user.email,
                        photoUrl: user.photoUrl ?? '',
                        latitude: myLocation.latitude,
                        longitude: myLocation.longitude,
                        university: user.university,
                        major: user.major,
                        backgroundUrl: user.backgroundUrl ?? '',
                        isEmailVerified: true,
                        password: '',
                        bio: user.bio ?? '',
                        gender: user.gender,
                        fcmToken: user.fcmToken),
                    context,
                  ),
                  ...userLoc.map((user) => buildMarker(user, context)),
                ])
              ],
            ),

            // Positioned Refresh Button
            // Positioned(
            //   top: 160,
            //   right: 10,
            //   child: TextButton(
            //     onPressed: () {
            //       // Add refresh logic here
            //     },
            //     child: Text("Refresh"),
            //     style: TextButton.styleFrom(
            //       backgroundColor: Colors.white.withOpacity(0.8),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //     ),
            //   ),
            // ),
            Positioned(
                top: 160,
                left: 0,
                right: 0,
                child: isFetching
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Fetching nearby users " +
                              "." *
                                  _dotsCount, // Show 1, 2, or 3 dots based on `_dotsCount`
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : SizedBox()),
            Positioned(
              top: 160,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  context.read<LocationBloc>().add(GetNearbyUsersEvent());
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.purple], // Gradient colors
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Refresh",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Positioned No Internet Connection Banner
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: BlocBuilder<InternetBloc, InternetState>(
                builder: (context, intState) {
                  if (intState is NoInternetConnectionState) {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              'No Internet Connection',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SizedBox(); // Empty space if no internet issue
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

Marker buildMarker(UserLocEntity userLoc, BuildContext context) {
  return Marker(
      width: 100,
      height: 100,
      point: LatLng(userLoc.latitude, userLoc.longitude),
      child: profileMaker(userLoc, context));
}

GestureDetector profileMaker(UserLocEntity userLoc, BuildContext context) {
  return GestureDetector(
    onTap: () {
      userLoc.userId != UserConstant().getUserId()
          ? {
              context.read<ProfileBloc>().add(GetUserByIdEvent(userLoc.userId)),
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserProfilePage()))
            }
          : Navigator.push(context,
              MaterialPageRoute(builder: (context) => MyProfilePage()));
    },
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60, // Adjust size (radius * 2 + border)
          height: 60,
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
              radius: 30,
              backgroundImage: userLoc.gender == 'male'
                  ? Image.asset('assets/male.png').image
                  : Image.asset('assets/woman.png').image,
              foregroundImage: userLoc.photoUrl != ''
                  ? CachedNetworkImageProvider(userLoc.photoUrl,
                      cacheManager: MyCacheManager())
                  : null,
            ),
          ),
        ),
        Positioned(
          bottom: 0, // Adjust position
          child: Text(
            userLoc.name,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
