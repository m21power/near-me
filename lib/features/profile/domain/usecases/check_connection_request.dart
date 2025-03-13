import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/profile/domain/entities/profile_entity.dart';
import 'package:near_me/features/profile/domain/repository/profile_repository.dart';

class CheckConnectionRequestUsecase {
  final ProfileRepository profileRepository;
  CheckConnectionRequestUsecase({required this.profileRepository});
  Future<Either<Failure, ConnectionReqModel>> call(String receiverId) {
    return profileRepository.checkConnectionRequest(receiverId);
  }
}
