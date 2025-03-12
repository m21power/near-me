import 'package:dartz/dartz.dart';
import 'package:near_me/features/Auth/domain/entities/user_entities.dart';

import '../../../../core/error/failure.dart';
import '../repository/auth_repository.dart';

class LoginUsecase {
  final AuthRepository _authRepository;

  LoginUsecase(this._authRepository);

  Future<Either<Failure, UserModel>> call(String email, String passowrd) async {
    return await _authRepository.login(email, passowrd);
  }
}
