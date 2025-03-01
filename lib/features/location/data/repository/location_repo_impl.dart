import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_me/core/constants/constant.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/location/domain/repository/location_repository.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/io.dart';

class LocationRepoImpl implements LocationRepository {
  final IOWebSocketChannel channel;
  final FlutterSecureStorage secureStorage;
  LocationRepoImpl({required this.channel, required this.secureStorage});
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

    yield* Stream.periodic(const Duration(minutes: 1)).asyncMap((_) async {
      try {
        Position position = await Geolocator.getCurrentPosition();
        return Right<Failure, Position>(position); // Explicit type
      } catch (e) {
        return Left<Failure, Position>(
            ServerFailure(message: "Failed to get location: $e"));
      }
    });
  }

  @override
  Future<Unit> emitLocation(Position position) async {
    var userId = await secureStorage.read(key: Constant.userIdSecureStorageKey);
    // emit to the socket ,

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
}
