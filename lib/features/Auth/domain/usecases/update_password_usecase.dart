import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repository/auth_repository.dart';

class UpdatePasswordUsecase {
  final AuthRepository repository;

  UpdatePasswordUsecase(this.repository);

  Future<Either<Failure, Unit>> call(String email, String password) async {
    return await repository.updatePassword(email, password);
  }
}
