import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:near_me/core/constants/api_constant.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/core.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/location/domain/entities/user_entity_loc.dart';
import 'package:near_me/features/location/domain/repository/location_repository.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;

class LocationRepoImpl implements LocationRepository {
  final IOWebSocketChannel channel;
  final FlutterSecureStorage secureStorage;
  final http.Client client;
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;
  LocationRepoImpl(
      {required this.channel,
      required this.secureStorage,
      required this.client,
      required this.networkInfo,
      required this.firestore});
  @override
  Stream<Either<Failure, Position>> getCurrentLocation() async* {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      yield const Left(
          ServerFailure(message: "Location services are disabled."));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        yield const Left(
            ServerFailure(message: "Location permissions are denied."));
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      yield const Left(ServerFailure(
          message: "Location permissions are permanently denied."));
      return;
    }

    try {
      // Emit the initial location immediately
      Position position = await Geolocator.getCurrentPosition();
      yield Right<Failure, Position>(position);
    } catch (e) {
      yield Left<Failure, Position>(
          ServerFailure(message: "Failed to get location: $e"));
      return;
    }

    // Emit every 5 minutes
    yield* Stream.periodic(const Duration(minutes: 5)).asyncMap((_) async {
      try {
        Position position = await Geolocator.getCurrentPosition();
        return Right<Failure, Position>(position);
      } catch (e) {
        return Left<Failure, Position>(
            ServerFailure(message: "Failed to get location: $e"));
      }
    });
  }

  @override
  Future<Unit> emitLocation(Position position) async {
    var userId = UserConstant().getUserId();
    UserConstant()
        .updateLocation(LatLng(position.latitude, position.longitude));
    // emit to the socket ,

    // channel.sink.add(jsonEncode({
    //   'userId': userId,
    //   "latitude": 9.031859697470294,
    //   "longitude": 38.763446899832886
    // }));
    channel.sink.add(jsonEncode({
      'userId': userId,
      "latitude": position.latitude,
      "longitude": position.longitude
    }));
    return unit;
  }

  @override
  Stream<Either<Failure, Unit>> locationDisabled() {
    return Stream.periodic(const Duration(seconds: 2)).asyncMap((_) async {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(
            ServerFailure(message: "Location services are disabled."));
      }
      return const Right(unit);
    });
  }

  @override
  Future<Either<Failure, List<UserLocEntity>>> getNearbyUsers() async {
    if (await networkInfo.isConnected) {
      try {
        LatLng? currentLocation = UserConstant().getLocation();
        if (currentLocation == null) {
          return Future.value(
              Left(ServerFailure(message: "Location not available.")));
        }
        var uri =
            Uri.parse('${ApiConstant.BASE_URL}/api/v1/user-status/connected');
        var response = await client.get(uri);
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          List<UserLocEntity> users = [];
          for (var user in data['users']) {
            if (user['userId'] != UserConstant().getUser()!.id) {
              users.add(UserLocEntity.fromMap(user));
            }
          }
          for (var user in users) {
            await firestore
                .collection('users')
                .doc(user.userId)
                .get()
                .then((value) {
              user.name = value['name'] ?? '';
              user.photoUrl = value['photoUrl'] ?? '';
              user.backgroundUrl = value['backgroundUrl'] ?? '';
              user.bio = value['bio'] ?? '';
              user.password = '';
              user.isEmailVerified = true;
              user.major = value['major'] ?? '';
              user.university = value['university'] ?? '';
              user.email = value['email'] ?? '';
              user.gender = value['gender'] ?? '';
            });
          }
          return Future.value(Right(users));
        } else {
          return const Left(
              ServerFailure(message: "Failed to get nearby users."));
        }
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(ServerFailure(message: "No internet connection"));
    }
  }
}
