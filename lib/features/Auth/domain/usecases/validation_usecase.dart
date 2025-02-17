import 'package:dartz/dartz.dart';
import 'package:near_me/features/Auth/domain/repository/auth_repository.dart';

import '../../../../core/error/failure.dart';

class EmailValidationUsecase {
  final AuthRepository _authRepository;
  EmailValidationUsecase(this._authRepository);
  Future<Either<Failure, Unit>> call(String email, String password) async {
    return await _authRepository.emailValidationForRegister(email, password);
  }
}
