import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repository/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<Either<Failure, Unit>> call(
    String email,
    String password,
    String name,
    String gender,
  ) async {
    return await repository.register(email, password, name, gender);
  }
}
