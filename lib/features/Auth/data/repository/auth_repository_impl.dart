import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_me/core/constants/api_constant.dart';
import 'package:near_me/core/constants/constant.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/core.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/core/service/email_service.dart';
import 'package:near_me/core/service/random_otp_generator.dart';
import 'package:near_me/dependency_injection.dart';
import 'package:near_me/features/Auth/domain/repository/auth_repository.dart';

import 'package:near_me/features/Auth/domain/entities/user_entities.dart';
import 'package:near_me/features/home/data/repository/local/listen_conn_status.dart';
import 'package:near_me/features/home/data/repository/local/local_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final SharedPreferences sharedPreferences;
  final NetworkInfo networkInfo;
  final FirebaseAppCheck firebaseAppCheck;
  final FlutterSecureStorage secureStorage;
  final FirebaseMessaging firebaseMessaging;
  final DatabaseHelper localDb;
  AuthRepositoryImpl(
      this.firestore,
      this.firebaseAuth,
      this.sharedPreferences,
      this.networkInfo,
      this.firebaseAppCheck,
      this.secureStorage,
      this.localDb,
      this.firebaseMessaging);
  @override
  Future<Either<Failure, Unit>> requestOtp(String email) async {
    try {
      if (await networkInfo.isConnected) {
        String otp = generateRandomOTP();
        var result = await EmailService.sendOtpEmail(email, otp);

        if (result.isRight()) {
          const expirationDuration = const Duration(days: 1);
          final otpData = {
            "email": email,
            "otp": otp,
            "timestamp": FieldValue.serverTimestamp(),
            "expiration_duraton": expirationDuration.inMilliseconds
          };
          await firestore.collection("otp_data").doc(email).set(otpData);
          return const Right(unit);
        }
        return const Left(ServerFailure(message: "Failed to send OTP"));
      }
      return const Left(ServerFailure(message: "No internet connection"));
    } catch (e) {
      return Left(ServerFailure(message: "Unexpected error happened"));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyOtp(String email, String otp) async {
    if (await networkInfo.isConnected) {
      var isExpired = await isOtpExpiredAndDelete(email);
      if (isExpired) {
        return const Left(ServerFailure(message: "OTP is expired"));
      }
      var data = await firestore.collection("otp_data").doc(email).get();
      if (data.exists) {
        if (data["otp"] == otp) {
          await firestore.collection('otp_data').doc(email).delete();
          return const Right(unit);
        }
      }
      return const Left(ServerFailure(message: "Invalid OTP"));
    }
    return const Left(ServerFailure(message: "No internet connection"));
  }

  Future<bool> isOtpExpiredAndDelete(String email) async {
    final docSnapshot = await firestore.collection('otp_data').doc(email).get();

    if (docSnapshot.exists) {
      final otpTimestamp = docSnapshot['timestamp'] as Timestamp?;
      final expirationDuration = docSnapshot['expiration_duraton'] as int?;

      if (otpTimestamp != null && expirationDuration != null) {
        final otpTime = otpTimestamp.toDate();
        final currentTime = DateTime.now();

        // Calculate expiry time
        final expiryTime =
            otpTime.add(Duration(milliseconds: expirationDuration));

        if (currentTime.isAfter(expiryTime)) {
          await firestore.collection('otp_data').doc(email).delete();
          return true;
        }
      }
    }
    return false;
  }

  @override
  Future<Either<Failure, Unit>> register(
    String email,
    String password,
    String name,
    String gender,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        UserCredential userCredential = await firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);
        var uid = userCredential.user!.uid;
        var token = await firebaseMessaging.getToken();
        var value = UserModel(
                id: uid,
                email: email,
                name: name,
                photoUrl: "",
                backgroundUrl: "",
                isEmailVerified: true,
                password: password,
                bio: "",
                university: "",
                major: "",
                gender: gender,
                fcmToken: token ?? '')
            .toMap();
        await firestore.collection("users").doc(uid).set(value);
        secureStorage.write(key: Constant.userIdSecureStorageKey, value: uid);
        secureStorage.write(
            key: Constant.userPasswordSecureStoreKey, value: password);
        value["id"] = null;
        value["password"] = null;
        sharedPreferences.setString(
            Constant.userPreferenceKey, value.toString());
        return const Right(unit);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          return const Left(ServerFailure(message: "Email already in use"));
        }
        if (e.code == 'weak-password') {
          return const Left(ServerFailure(message: "Weak password"));
        }
        if (e.code == 'invalid-email') {
          return const Left(ServerFailure(message: "Invalid email"));
        }
        if (e.code == 'network-request-failed') {
          return const Left(ServerFailure(message: "Network error"));
        }
        return const Left(const ServerFailure(message: "Unknown error"));
      }
    } else {
      return const Left(ServerFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, Unit>> emailValidationForRegister(
      String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        if (password.length < 6) {
          return const Left(
              ServerFailure(message: "Password must be at least 6 characters"));
        }
        if (!email.contains("@")) {
          return const Left(ServerFailure(message: "Invalid email"));
        }
        var value = await firebaseAuth.fetchSignInMethodsForEmail(email);
        if (value.isEmpty) {
          return const Right(unit);
        } else {
          return const Left(ServerFailure(message: "Email already in use"));
        }
      } catch (e) {
        print(e.toString());
        return const Left(ServerFailure(message: "Network error"));
      }
    } else {
      return const Left(ServerFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, UserModel>> login(
      String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        print(email);
        print(password);
        await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);

        var value = await firestore
            .collection("users")
            .where("email", isEqualTo: email)
            .get();

        if (value.docs.isNotEmpty) {
          print(value.docs.first.data());
          var user = UserModel.fromMap(value.docs.first.data());
          print(user.id);
          await secureStorage.write(
              key: Constant.userIdSecureStorageKey, value: user.id);
          await secureStorage.write(
              key: Constant.userPasswordSecureStoreKey, value: password);
          // Create a copy of user data without sensitive fields
          var userData = Map<String, dynamic>.from(value.docs.first.data());
          userData.remove("id");
          userData.remove("password");

          // Store in SharedPreferences as JSON string
          await sharedPreferences.setString(
              Constant.userPreferenceKey, jsonEncode(userData));

          print("---------------------------");
          var storedUserId =
              await secureStorage.read(key: Constant.userIdSecureStorageKey);
          print(storedUserId);
          await UserConstant().initializeUser();
          UserConstant().setUser();
          sl<ConnectionStatusListener>().listenToConnectionStatus();
          return Right(user);
        } else {
          return const Left(ServerFailure(message: "User not found"));
        }
      } on FirebaseAuthException catch (e) {
        print("------------------FirebaseAuthException------------------");
        print(e.code);
        if (e.code == 'user-not-found') {
          return const Left(ServerFailure(message: "User not found"));
        }
        if (e.code == 'wrong-password') {
          return const Left(ServerFailure(message: "Wrong password"));
        }
        if (e.code == 'invalid-email') {
          return const Left(ServerFailure(message: "Invalid email"));
        }
        if (e.code == 'network-request-failed') {
          return const Left(ServerFailure(message: "Network error"));
        }
        return Left(ServerFailure(message: e.code));
      } catch (e) {
        print(e.toString());
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(ServerFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, Unit>> emailValidationForResettingPassword(
      String email) async {
    if (await networkInfo.isConnected) {
      try {
        if (!email.contains("@")) {
          return const Left(ServerFailure(message: "Invalid email"));
        }
        var value = await firestore
            .collection("users")
            .where("email", isEqualTo: email)
            .get();
        if (value.docs.isEmpty) {
          return const Left(
              ServerFailure(message: "no user found with this email"));
        } else {
          return const Right(unit);
        }
      } catch (e) {
        return const Left(ServerFailure(message: "Network error"));
      }
    } else {
      return const Left(ServerFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePassword(
      String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        // Get the App Check token
        print("------------------appCheckToken------------------");
        var appCheckToken = await firebaseAppCheck.getToken(true);
        print(appCheckToken);

        // Send the token in the request header
        final response = await http.put(
          Uri.parse('${ApiConstant.BASE_URL}/update-password'),
          headers: {
            'X-Firebase-AppCheck': appCheckToken!, // Attach token here
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'email': email,
            'newPassword': password,
          }),
        );
        // Handle the response
        if (response.statusCode == 200) {
          print('Request was successful!');
          return const Right(unit);
        } else {
          print(response.statusCode);
          print(response.body);

          print('Failed to authenticate');
          return Left(ServerFailure(message: "failed to authenticate"));
        }
      } catch (e) {
        print('Error: $e');
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      return const Left(ServerFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, Unit>> logOut() async {
    if (await networkInfo.isConnected) {
      try {
        await firebaseAuth.signOut();
        secureStorage.deleteAll();
        sharedPreferences.clear();
        await localDb.clearDatabase();
        return const Right(unit);
      } catch (e) {
        return const Left(ServerFailure(message: "Failed to log out"));
      }
    } else {
      return const Left(ServerFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failure, Unit>> isLoggedIn() async {
    var value = await secureStorage.read(key: Constant.userIdSecureStorageKey);
    if (value != null) {
      await UserConstant().initializeUser();
      UserConstant().setUser();
      sl<ConnectionStatusListener>().listenToConnectionStatus();

      return const Right(unit);
    }

    return const Left(ServerFailure(message: "User not logged in"));
  }
}
