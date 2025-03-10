import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:near_me/features/Auth/domain/entities/user_entities.dart';

import '../../../profile/presentation/pages/my_profile_page.dart';
import '../../../profile/presentation/pages/user_profile_page.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    LatLng myLocation = LatLng(9.034216592112697, 38.76468316212695);
    LatLng theirLocation = LatLng(9.033909315467003, 38.76399651668064);
    String thierName = "Filfilu";

    return FlutterMap(
      options: MapOptions(
        initialZoom: 15,
        initialCenter: myLocation,
        interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.drag |
                InteractiveFlag.flingAnimation |
                InteractiveFlag.pinchMove |
                InteractiveFlag.pinchZoom |
                InteractiveFlag.doubleTapZoom),
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          // tileProvider: CachingNetworkTileProvider(),
        ),
        MarkerLayer(markers: [
          buildMarker(myLocation, "Me", "assets/male.png", context),
          buildMarker(theirLocation, thierName, "assets/woman.png", context)
        ])
      ],
    );
  }

  Marker buildMarker(
      LatLng myLocation, String name, String imageUrl, BuildContext context) {
    return Marker(
        width: 100,
        height: 100,
        point: myLocation,
        child: profileMaker(name, imageUrl, context));
  }
}

GestureDetector profileMaker(
    String name, String imageUrl, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserProfilePage(
                    user: UserModel(
                        id: "uAbcTJRavsgmPYNlUpKIYh9kV4B2",
                        email: "mesay.lemma@a2sv.org",
                        university: '',
                        major: '',
                        name: name,
                        photoUrl:
                            "https://res.cloudinary.com/dl6vahv6t/image/upload/v1741457455/uAbcTJRavsgmPYNlUpKIYh9kV4B2/profileImage.jpg",
                        backgroundUrl: '',
                        isEmailVerified: true,
                        password: '',
                        bio: '',
                        gender: 'male'),
                    userPosts: [],
                  )));
    },
    child: Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 30, // Adjust size as needed
          backgroundImage: Image.asset(imageUrl).image,
        ),
        Positioned(
          bottom: 0, // Adjust position
          child: Text(
            name,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
