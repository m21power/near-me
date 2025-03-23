import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/home/domain/entities/connection_model.dart';
import 'package:near_me/features/home/domain/repository/home_repository.dart';

class GetMyConnectionUsecase {
  final HomeRepository homeRepository;
  GetMyConnectionUsecase({required this.homeRepository});
  Future<Either<Failure, List<ConnectionModel>>> call() {
    return homeRepository.getMyConnections();
  }
}
