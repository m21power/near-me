import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/profile/domain/repository/profile_repository.dart';

class SendConnectionRequestUsecase {
  final ProfileRepository profileRepository;
  SendConnectionRequestUsecase({required this.profileRepository});
  Future<Either<Failure, Unit>> call(String receiverId) {
    return profileRepository.sendConnectionRequest(receiverId);
  }
}
