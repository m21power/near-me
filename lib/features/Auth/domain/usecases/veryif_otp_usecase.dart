import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repository/auth_repository.dart';

class VerifyOtpUsecase {
  final AuthRepository _authRepository;

  VerifyOtpUsecase(this._authRepository);

  Future<Either<Failure, Unit>> call(String email, String otp) async {
    return await _authRepository.verifyOtp(email, otp);
  }
}
