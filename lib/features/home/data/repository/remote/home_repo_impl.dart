import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:near_me/core/core.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/home/data/repository/local/local_db.dart';
import 'package:near_me/features/home/domain/entities/connection_model.dart';
import 'package:near_me/features/home/domain/entities/entity.dart';
import 'package:near_me/features/home/domain/repository/home_repository.dart';

class HomeRepoImpl implements HomeRepository {
  final FirebaseFirestore firestore;
  final NetworkInfo networkInfo;
  final DatabaseHelper localDb;
  HomeRepoImpl(
      {required this.firestore,
      required this.networkInfo,
      required this.localDb});
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

  @override
  Future<Either<Failure, List<ConnectionModel>>> getMyConnections() async {
    try {
      var result = await localDb.getAllConnections();

      // Sort: Online users first, then by last seen time (most recent first)
      result.sort((a, b) {
        if (a.isOnline && !b.isOnline) {
          return -1; // `a` comes first
        } else if (!a.isOnline && b.isOnline) {
          return 1; // `b` comes first
        } else {
          // Both are either online or offline, sort by lastSeen
          return DateTime.parse(b.lastSeen)
              .compareTo(DateTime.parse(a.lastSeen));
        }
      });

      return Right(result);
    } catch (e) {
      return const Left(ServerFailure(
          message: "Unable to load your connections, please try again!"));
    }
  }
}
