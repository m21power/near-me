import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/Auth/domain/entities/user_entities.dart';

abstract class AuthRepository {
  Future<Either<Failure, Unit>> requestOtp(String email);
  Future<Either<Failure, Unit>> verifyOtp(String email, String otp);
  Future<Either<Failure, Unit>> register(
      String email, String password, String name, String gender);
  Future<Either<Failure, Unit>> emailValidationForRegister(
      String email, String password);
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, Unit>> emailValidationForResettingPassword(
      String email);
  Future<Either<Failure, Unit>> updatePassword(String email, String password);
  Future<Either<Failure, Unit>> logOut();
  Future<Either<Failure, Unit>> isLoggedIn();
}
