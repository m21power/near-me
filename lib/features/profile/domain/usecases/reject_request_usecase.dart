import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/profile/domain/repository/profile_repository.dart';

class RejectRequestUsecase {
  final ProfileRepository profileRepository;
  RejectRequestUsecase({required this.profileRepository});
  Future<Either<Failure, Unit>> rejectRequest(String userId) {
    return profileRepository.rejectRequest(userId);
  }
}
