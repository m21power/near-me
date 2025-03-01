import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/Auth/domain/entities/user_entities.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserModel>> getUserById(String id);
  Future<Either<Failure, UserModel>> updateProfile(
      String? profileImage,
      String? backgroundImage,
      String? fullName,
      String? bio,
      String? university,
      String? major);
}
