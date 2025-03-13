import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/home/domain/entities/entity.dart';
import 'package:near_me/features/home/domain/repository/home_repository.dart';

class HomeRepoImpl implements HomeRepository {
  final FirebaseFirestore firestore;
  HomeRepoImpl({required this.firestore});
  @override
  Future<Either<Failure, List<SearchedUser>>> searchUser(String name) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('name', isEqualTo: name)
          .get();
      final users = querySnapshot.docs
          .map((doc) => SearchedUser.fromMap(doc.data()))
          .toList();
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
