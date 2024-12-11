import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pulsehub/core/utils/shared_pref_keys.dart';
import 'package:pulsehub/features/auth/data/models/login_response_model.dart';

class UserManager {
  static final UserManager _instance = UserManager._internal();
  static const _userKey = SharedPrefKeys.user; // Key for storing User

  User? _user;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();

  /// Initializes the UserManager by reading the stored User from secure storage.
  Future<void> init() async {
    String? userJson = await _secureStorage.read(key: _userKey);

    if (userJson != null) {
      _user = User.fromJson(jsonDecode(userJson));
    }
  }

  /// Getter for the current User.
  User? get user => _user;

  /// Sets the current User and stores it in secure storage.
  Future<void> setUser(User user) async {
    _user = user;
    await _secureStorage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),
    );
  }

  /// Clears the current User and removes it from secure storage.
  Future<void> clearUser() async {
    _user = null;
    await _secureStorage.delete(key: _userKey);
  }
}
