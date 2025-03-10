import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_me/core/constants/constant.dart';
import 'package:near_me/dependency_injection.dart';

class UserConstant {
  static final UserConstant _instance = UserConstant._internal();

  factory UserConstant() {
    return _instance;
  }

  UserConstant._internal();

  String? _cachedUserId;

  Future<void> initializeUser() async {
    _cachedUserId ??= await sl<FlutterSecureStorage>()
        .read(key: Constant.userIdSecureStorageKey);
  }

  String? getUserId() {
    return _cachedUserId;
  }
}
