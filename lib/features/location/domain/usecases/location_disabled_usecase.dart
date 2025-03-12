import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/location/domain/repository/location_repository.dart';

class LocationDisabledUsecase {
  final LocationRepository locationRepository;

  LocationDisabledUsecase({required this.locationRepository});

  Stream<Either<Failure, Unit>> call() {
    return locationRepository.locationDisabled();
  }
}
