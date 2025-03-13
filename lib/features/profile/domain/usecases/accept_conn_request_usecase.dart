import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/profile/domain/repository/profile_repository.dart';

class AcceptConnRequestUsecase {
  final ProfileRepository profileRepository;
  AcceptConnRequestUsecase({required this.profileRepository});
  Future<Either<Failure, Unit>> call(String userId) {
    return profileRepository.acceptRequest(userId);
  }
}
