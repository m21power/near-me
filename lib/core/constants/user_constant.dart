import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:near_me/core/constants/constant.dart';
import 'package:near_me/dependency_injection.dart';
import 'package:near_me/features/Auth/domain/entities/user_entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserConstant {
  static final UserConstant _instance = UserConstant._internal();

  factory UserConstant() {
    return _instance;
  }

  UserConstant._internal();

  String? _cachedUserId;
  UserModel? user;

  Future<void> initializeUser() async {
    _cachedUserId ??= await sl<FlutterSecureStorage>()
        .read(key: Constant.userIdSecureStorageKey);
  }

  String? getUserId() {
    return _cachedUserId;
  }

  LatLng? _cachedLocation;

  // Getter to access location
  LatLng? getLocation() {
    return _cachedLocation;
  }

  void setUser() {
    var u = jsonDecode(
        sl<SharedPreferences>().getString(Constant.userPreferenceKey)!);
    user = UserModel(
        id: _cachedUserId!,
        email: u['email'] ?? '',
        university: u['university'] ?? '',
        major: u['major'] ?? '',
        name: u['name'] ?? '',
        photoUrl: u['photoUrl'] ?? '',
        backgroundUrl: u['backgroundUrl'] ?? '',
        isEmailVerified: true,
        password: '',
        bio: u['bio'] ?? '',
        fcmToken: u['fcmToken'] ?? '',
        gender: u['gender'] ?? '');
  }

  UserModel? getUser() {
    return user;
  }

  // Setter to update location
  void updateLocation(LatLng newLocation) {
    _cachedLocation = newLocation;
  }
}
