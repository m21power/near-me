import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/location/domain/repository/location_repository.dart';

class GetCurrentLocationUsecase {
  LocationRepository locationRepository;
  GetCurrentLocationUsecase({required this.locationRepository});
  Stream<Either<Failure, Position>> call() {
    return locationRepository.getCurrentLocation();
  }
}
