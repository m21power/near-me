import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:near_me/core/constants/api_constant.dart';
import 'package:near_me/core/constants/constant.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/core/network/network_info.dart';
import 'package:near_me/core/util/public_id_from_url.dart';
import 'package:near_me/features/Auth/domain/entities/user_entities.dart';
import 'package:near_me/features/home/data/repository/local/local_db.dart';
import 'package:near_me/features/home/domain/entities/connection_model.dart';
import 'package:near_me/features/profile/domain/entities/profile_entity.dart';
import 'package:near_me/features/profile/domain/repository/profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepoImpl extends ProfileRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final SharedPreferences sharedPreferences;
  final NetworkInfo networkInfo;
  final FirebaseAppCheck firebaseAppCheck;
  final FlutterSecureStorage secureStorage;
  final http.Client client;
  final DatabaseHelper localDb;
  ProfileRepoImpl(
      this.firebaseAppCheck,
      this.firestore,
      this.firebaseAuth,
      this.networkInfo,
      this.secureStorage,
      this.sharedPreferences,
      this.localDb,
      this.client);

  @override
  Future<Either<Failure, UserModel>> getUserById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        var value = await firestore.collection("users").doc(id).get();
        if (value.exists) {
          var user = UserModel.fromMap(value.data()!);
          return Right(user);
        } else {
          return const Left(ServerFailure(message: "User not found"));
        }
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(ServerFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateProfile(
      String? profileImage,
      String? backgroundImage,
      String? fullName,
      String? bio,
      String? university,
      String? major) async {
    if (await networkInfo.isConnected) {
      try {
        var uri = Uri.parse('${ApiConstant.POST_BASE_URL}/update-profile');
        String? userId = UserConstant().getUserId();
        if (userId != null) {
          var user = await firestore.collection("users").doc(userId).get();
          if (user.exists) {
            var userMap = user.data()!;
            if (profileImage != null &&
                profileImage.isNotEmpty &&
                profileImage != userMap["photoUrl"]) {
              String prev = '';
              String url = '';
              if (userMap['photoUrl'] == "" || userMap['photoUrl'] == null) {
                url = userMap['photoUrl'];
                prev = 'true';
              } else {
                prev = 'false';
                url = "url";
              }
              var request = http.MultipartRequest('POST', uri)
                ..files.add(
                    await http.MultipartFile.fromPath('profile', profileImage))
                ..fields['prev'] = prev
                ..fields['url'] = url
                ..fields['isProfile'] = "true"
                ..fields['userId'] = userId;
              var response = await request.send();
              if (response.statusCode != 200) {
                return const Left(
                    ServerFailure(message: "Oops! Image upload failed"));
              }
              var responseData = await http.Response.fromStream(response);
              var responseBody = jsonDecode(responseData.body);
              userMap['photoUrl'] = responseBody['url'];
            }
            if (backgroundImage != null &&
                backgroundImage.isNotEmpty &&
                backgroundImage != userMap["backgroundUrl"]) {
              String prev = '';
              String url = '';
              if (userMap['backgroundUrl'] == "" ||
                  userMap['backgroundUrl'] == null) {
                url = userMap['backgroundUrl'];
                prev = 'true';
              } else {
                prev = 'false';
                url = "url";
              }
              var request = http.MultipartRequest('POST', uri)
                ..files.add(await http.MultipartFile.fromPath(
                    'profile', backgroundImage))
                ..fields['prev'] = prev
                ..fields['url'] = url
                ..fields['isProfile'] = "false"
                ..fields['userId'] = userId;

              var response = await request.send();
              if (response.statusCode != 200) {
                return const Left(
                    ServerFailure(message: "Oops! Image upload failed"));
              }
              var responseData = await http.Response.fromStream(response);
              var responseBody = jsonDecode(responseData.body);
              userMap['backgroundUrl'] = responseBody['url'];
            }

            userMap["name"] = fullName;

            userMap["bio"] = bio;

            userMap["university"] = university;

            userMap["major"] = major;

            await firestore.collection("users").doc(userId).update(userMap);
            await secureStorage.write(
                key: Constant.userIdSecureStorageKey, value: userMap["id"]);
            userMap["id"] = "";
            userMap["password"] = "";
            var updatedUser = UserModel.fromMap(userMap);
            await sharedPreferences.setString(
                Constant.userPreferenceKey, updatedUser.toJson());
            UserConstant().setUser();
            return Right(updatedUser);
          } else {
            return const Left(ServerFailure(message: "User not found"));
          }
        } else {
          return const Left(ServerFailure(message: "User not found"));
        }
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(ServerFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendConnectionRequest(String to) async {
    if (await networkInfo.isConnected) {
      try {
        var user = UserConstant().getUser();
        await firestore
            .collection('request')
            .doc(to)
            .collection('connection_request')
            .add({
          "from": user!.id,
          'to': to,
          'status': "pending",
        });
        Map<String, dynamic> notModel = {
          "accepted": false,
          "from": user.id,
          "to": to,
          "title": "New Connection Request",
          "body": "${user!.name} has sent you a connection request.",
          "timestamp": FieldValue.serverTimestamp(),
          "profilePic": user.photoUrl,
          "name": user.name,
          "status": "unseen",
          "major": user.major,
          "fromGender": user.gender
        };

        // add the not to the notification collection of the to
        await firestore
            .collection('notifications')
            .doc(to)
            .collection("notification")
            .add(notModel);
        return const Right(unit);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(ServerFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, ConnectionReqModel>> checkConnectionRequest(
      String receiverId) async {
    if (await networkInfo.isConnected) {
      var userId = UserConstant().getUserId();
      var ids = [receiverId, userId];
      ids.sort();
      var conId = ids.join('_');
      var data = await firestore.collection('connections').doc(conId).get();
      if (data.exists) {
        var ans = ConnectionReqModel(to: '', from: '', status: 'accepted');
        return Right(ans);
      }
      // if they are not connected let's check if the request was sent
      var myRequest = await firestore
          .collection('request')
          .doc(receiverId)
          .collection('connection_request')
          .where('from', isEqualTo: userId)
          .get();
      if (myRequest.docs.isNotEmpty) {
        return Right(ConnectionReqModel(
            from: userId!, to: receiverId, status: 'pending'));
      }
      var hisRequest = await firestore
          .collection('request')
          .doc(userId)
          .collection('connection_request')
          .where('from', isEqualTo: receiverId)
          .get();
      if (hisRequest.docs.isNotEmpty) {
        return Right(ConnectionReqModel(
            from: receiverId, to: userId!, status: 'pending'));
      }
      return const Left(ServerFailure(message: "They are not connected"));
    } else {
      return const Left(ServerFailure(message: "No Internet Connection"));
    }
  }

  @override
  Future<Either<Failure, Unit>> acceptRequest(String userId) async {
    if (await networkInfo.isConnected) {
      var myId = UserConstant().getUserId();
      var user1 = UserConstant().getUser();
      var requestSnapshot = await firestore
          .collection('request')
          .doc(myId)
          .collection('connection_request')
          .where('from', isEqualTo: userId)
          .get();

      for (var doc in requestSnapshot.docs) {
        await doc.reference.delete();
      }
      var user2 = await firestore.collection('users').doc(userId).get();
      var user2Model = UserModel.fromMap(user2.data()!);

      var ids = [myId, userId];
      ids.sort();
      var conId = ids.join("_");
      Map<String, dynamic> connectModel = {
        "users": [userId, myId],
        "acceptedAt": FieldValue.serverTimestamp()
      };
      await firestore.collection("connections").doc(conId).set(connectModel);
      // saved to the local db
      ConnectionModel conModel = ConnectionModel(
          name: user2Model.name,
          profilePic: user2Model.photoUrl ?? "",
          id: userId,
          gender: user2Model.gender,
          isOnline: true,
          lastSeen: DateTime.now().toIso8601String());
      await localDb.insertConnection(conModel);
      Map<String, dynamic> notModel = {
        'accepted': true,
        "from": myId,
        "to": userId,
        "title": "Connection Request Accepted",
        "body": "${user1!.name} has accepted your connection request.",
        "timestamp": FieldValue.serverTimestamp(),
        "profilePic": user1.photoUrl,
        "name": user1.name,
        "status": "unseen",
        "major": user1.major,
        "fromGender": user1.gender
      };
      await firestore
          .collection("notifications")
          .doc(userId)
          .collection("notification")
          .add(notModel);
      Map<String, dynamic> notModel2 = {
        'accepted': true,
        "from": userId,
        "to": myId,
        "title": "Connection Request Accepted",
        "body": "You can now communicate with ${user2Model.name}.",
        "timestamp": FieldValue.serverTimestamp(),
        "profilePic": user2Model.photoUrl,
        "status": "unseen",
        "name": user2Model.name,
        "major": user2Model.major,
        "fromGender": user2Model.gender
      };
      await firestore
          .collection("notifications")
          .doc(myId)
          .collection("notification")
          .where("from", isEqualTo: userId)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      await firestore
          .collection("notifications")
          .doc(myId)
          .collection("notification")
          .add(notModel2);
      return const Right(unit);
    } else {
      return const Left(ServerFailure(message: 'No Internet Connection'));
    }
  }

  @override
  Future<Either<Failure, Unit>> rejectRequest(String userId) async {
    if (await networkInfo.isConnected) {
      var myId = UserConstant().getUserId();
      var requestSnapshot = await firestore
          .collection('request')
          .doc(myId)
          .collection('connection_request')
          .where('from', isEqualTo: userId)
          .get();
      for (var doc in requestSnapshot.docs) {
        await doc.reference.delete();
      }
      await firestore
          .collection("notifications")
          .doc(myId)
          .collection("notification")
          .where("from", isEqualTo: userId)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      await firestore
          .collection("notifications")
          .doc(userId)
          .collection("notification")
          .where("from", isEqualTo: myId)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      return const Right(unit);
    } else {
      return const Left(ServerFailure(message: 'No Internet Connection'));
    }
  }
}
