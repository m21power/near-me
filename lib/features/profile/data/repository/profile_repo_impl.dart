import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:near_me/core/constants/api_constant.dart';
import 'package:near_me/core/constants/constant.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/core/network/network_info.dart';
import 'package:near_me/core/util/public_id_from_url.dart';
import 'package:near_me/features/Auth/domain/entities/user_entities.dart';
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
  ProfileRepoImpl(
      this.firebaseAppCheck,
      this.firestore,
      this.firebaseAuth,
      this.networkInfo,
      this.secureStorage,
      this.sharedPreferences,
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
        String? userId =
            await secureStorage.read(key: Constant.userIdSecureStorageKey);
        if (userId != null) {
          var user = await firestore.collection("users").doc(userId).get();
          if (user.exists) {
            var userMap = user.data()!;
            if (profileImage != null &&
                profileImage.isNotEmpty &&
                profileImage != userMap["photoUrl"]) {
              var result = await uploadImage(
                  true, profileImage, userMap["photoUrl"], userId);
              if (result.isNotEmpty) {
                userMap["photoUrl"] = result;
              } else {
                return const Left(
                    ServerFailure(message: "Image upload failed"));
              }
            }
            if (backgroundImage != null &&
                backgroundImage.isNotEmpty &&
                backgroundImage != userMap["backgroundUrl"]) {
              var result = await uploadImage(
                  false, backgroundImage, userMap["backgroundUrl"], userId);
              if (result.isNotEmpty) {
                userMap["backgroundUrl"] = result;
              } else {
                return const Left(
                    ServerFailure(message: "Image upload failed"));
              }
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

  Future<String> uploadImage(
      bool isProfile, String imagePath, String prevUrl, String userId) async {
    try {
      print(prevUrl);
      if (isProfile == true) {
        var isDeleted = true;
        if (prevUrl.isNotEmpty) {
          isDeleted = await deleteImage(prevUrl);
        }
        if (isDeleted) {
          var request = http.MultipartRequest(
              "POST", Uri.parse('${ApiConstant.BASE_URL}/upload'));
          // attach images
          request.files
              .add(await http.MultipartFile.fromPath('file', imagePath));
          request.fields["userId"] = userId;
          request.fields["imageType"] = "profile";
          var response = await request.send();
          if (response.statusCode == 200) {
            var responseData = await http.Response.fromStream(response);
            var responseBody = jsonDecode(responseData.body);
            return responseBody["imageURL"];
          } else {
            return "";
          }
        } else {
          return "";
        }
      } else {
        var isDeleted = true;
        if (prevUrl.isNotEmpty) {
          isDeleted = await deleteImage(prevUrl);
        }
        if (isDeleted) {
          var request = http.MultipartRequest(
              "POST", Uri.parse('${ApiConstant.BASE_URL}/upload'));
          // attach images
          request.files
              .add(await http.MultipartFile.fromPath('file', imagePath));
          request.fields["userId"] = userId;
          request.fields["imageType"] = "background";
          var response = await request.send();
          if (response.statusCode == 200) {
            var responseData = await http.Response.fromStream(response);
            var responseBody = jsonDecode(responseData.body);
            return responseBody["imageURL"];
          } else {
            return "";
          }
        } else {
          return "";
        }
      }
    } catch (e) {
      print(e);
      return "";
    }
  }

  Future<bool> deleteImage(String imageUrl) async {
    try {
      String publicId = publicIdFromUrl(imageUrl);
      var uri = Uri.parse('${ApiConstant.BASE_URL}/delete/$publicId');
      var response = await client.delete(uri);

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }
}
