import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/Auth/domain/entities/user_entities.dart';
import 'package:near_me/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserModel>> getUserById(String id);
  Future<Either<Failure, UserModel>> updateProfile(
      String? profileImage,
      String? backgroundImage,
      String? fullName,
      String? bio,
      String? university,
      String? major);
  Future<Either<Failure, Unit>> sendConnectionRequest(String to);
  Future<Either<Failure, ConnectionReqModel>> checkConnectionRequest(
      String receiverId);
  Future<Either<Failure, Unit>> acceptRequest(String userId);
}
