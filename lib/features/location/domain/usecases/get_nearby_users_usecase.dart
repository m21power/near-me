import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/location/domain/entities/user_entity_loc.dart';
import 'package:near_me/features/location/domain/repository/location_repository.dart';

class GetNearbyUsersUsecase {
  final LocationRepository locationRepository;
  GetNearbyUsersUsecase({required this.locationRepository});

  Future<Either<Failure, List<UserLocEntity>>> call() {
    return locationRepository.getNearbyUsers();
  }
}
