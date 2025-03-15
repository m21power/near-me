import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:near_me/core/core.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/home/domain/entities/entity.dart';
import 'package:near_me/features/home/domain/repository/home_repository.dart';

class HomeRepoImpl implements HomeRepository {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;
  HomeRepoImpl({required this.firestore, required this.networkInfo});
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

  @override
  Stream<bool> checkInternet() async* {
    yield* Stream.periodic(Duration(seconds: 1))
        .asyncMap((_) => networkInfo.isConnected);
  }
}
