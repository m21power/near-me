import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';

import '../repository/auth_repository.dart';

class LogOutUsecase {
  final AuthRepository _authRepository;

  LogOutUsecase(this._authRepository);

  Future<Either<Failure, Unit>> call() async {
    return await _authRepository.logOut();
  }
}
