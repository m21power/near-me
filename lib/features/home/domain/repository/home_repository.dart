import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/home/domain/entities/entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<SearchedUser>>> searchUser(String name);
}
