import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/Auth/domain/entities/user_entities.dart';
import 'package:near_me/features/profile/domain/repository/profile_repository.dart';

class UpdateProfileUsecase {
  final ProfileRepository profileRepository;
  UpdateProfileUsecase({required this.profileRepository});
  Future<Either<Failure, UserModel>> call(
      String? profileImage,
      String? backgroundImage,
      String? fullName,
      String? bio,
      String? university,
      String? major) {
    return profileRepository.updateProfile(
        profileImage, backgroundImage, fullName, bio, university, major);
  }
}
