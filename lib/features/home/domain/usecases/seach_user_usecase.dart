import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/home/domain/entities/entity.dart';
import 'package:near_me/features/home/domain/repository/home_repository.dart';

class SearchUserUsecase {
  final HomeRepository homeRepository;
  SearchUserUsecase({required this.homeRepository});
  Future<Either<Failure, List<SearchedUser>>> call(String name) {
    return homeRepository.searchUser(name);
  }
}
