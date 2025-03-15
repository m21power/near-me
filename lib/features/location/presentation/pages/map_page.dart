import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/dependency_injection.dart';
import 'package:near_me/features/Auth/domain/entities/user_entities.dart';
import 'package:near_me/features/location/domain/entities/user_entity_loc.dart';
import 'package:near_me/features/location/presentation/bloc/location_bloc.dart';
import 'package:near_me/features/profile/presentation/pages/my_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../home/presentation/bloc/Internet/bloc/internet_bloc.dart';
import '../../../profile/presentation/pages/user_profile_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  LatLng myLocation = const LatLng(9.031859697470294, 38.763446899832886);
  // LatLng myLocation = UserConstant().getLocation() ??
  //     LatLng(9.031859697470294, 38.763446899832886);
  bool isLoading = false;
  List<UserLocEntity> userLoc = [];

  @override
  Widget build(BuildContext context) {
    UserModel user = UserConstant().getUser()!;

    return BlocConsumer<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state is GetNearbyUsersSuccessState) {
          setState(() {
            userLoc = state.nearbyUsers;
          });
        }
        // if (UserConstant().getLocation() != myLocation &&
        //     UserConstant().getLocation() != null) {
        //   myLocation = UserConstant().getLocation()!;
        //   Future.delayed(Duration(milliseconds: 200), () {
        //     if (mounted) {
        //       mapController.move(myLocation, 15);
        //     }
        //   });
        //   isLoading = false;
        // }
      },
      builder: (context, state) {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Column(
          children: [
            Expanded(
              child: FlutterMap(
                mapController: mapController, // Attach controller here
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
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
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
            ),
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
          ? Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserProfilePage(
                        user: UserModel(
                            id: userLoc.userId,
                            email: userLoc.email,
                            university: userLoc.university,
                            major: userLoc.major,
                            name: userLoc.name,
                            photoUrl: userLoc.photoUrl,
                            backgroundUrl: userLoc.backgroundUrl,
                            isEmailVerified: userLoc.isEmailVerified,
                            password: userLoc.password,
                            bio: userLoc.bio,
                            fcmToken: userLoc.fcmToken,
                            gender: userLoc.gender),
                        userPosts: [],
                      )))
          : Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyProfilePage(userPosts: [])));
    },
    child: Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: userLoc.gender == 'male'
              ? Image.asset('assets/male.png').image
              : Image.asset('assets/woman.png').image,
          foregroundImage:
              userLoc.photoUrl != '' ? NetworkImage(userLoc.photoUrl) : null,
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
