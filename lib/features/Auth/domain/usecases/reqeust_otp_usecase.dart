import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';

import '../repository/auth_repository.dart';

class ReqeustOtpUsecase {
  final AuthRepository _authRepository;

  ReqeustOtpUsecase(this._authRepository);

  Future<Either<Failure, Unit>> call(String email) async {
    return await _authRepository.requestOtp(email);
  }
}
