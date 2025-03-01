import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/Auth/domain/entities/user_entities.dart';
import 'package:near_me/features/profile/domain/repository/profile_repository.dart';

class GetUserByIdUsecase {
  final ProfileRepository profileRepository;
  GetUserByIdUsecase({required this.profileRepository});
  Future<Either<Failure, UserModel>> call(String id) {
    return profileRepository.getUserById(id);
  }
}
