import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/Auth/domain/repository/auth_repository.dart';

class IsLoggedInUsecase {
  final AuthRepository authRepository;
  IsLoggedInUsecase(this.authRepository);
  Future<Either<Failure, Unit>> call() {
    return authRepository.isLoggedIn();
  }
}
