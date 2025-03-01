import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:near_me/features/location/domain/repository/location_repository.dart';

class EmitCurrentLocationUsecase {
  final LocationRepository locationRepository;
  EmitCurrentLocationUsecase({required this.locationRepository});
  Future<Unit> call(Position position) {
    return locationRepository.emitLocation(position);
  }
}
