import 'package:dartz/dartz.dart';
import 'package:near_me/features/Auth/domain/repository/auth_repository.dart';

import '../../../../core/error/failure.dart';

class EmailValForResetPassUsecase {
  final AuthRepository authRepository;
  EmailValForResetPassUsecase(this.authRepository);
  Future<Either<Failure, Unit>> call(String email) async {
    return await authRepository.emailValidationForResettingPassword(email);
  }
}
