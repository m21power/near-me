import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/location/domain/entities/user_entity_loc.dart';

abstract class LocationRepository {
  Stream<Either<Failure, Position>> getCurrentLocation();
  Future<Unit> emitLocation(Position position);
  Stream<Either<Failure, Unit>> locationDisabled();
  Future<Either<Failure, List<UserLocEntity>>> getNearbyUsers();
}
