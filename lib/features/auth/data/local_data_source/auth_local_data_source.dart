import 'package:delivert_app2/core/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entiti/entity_login.dart';

class AuthLocalDataSource {
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userPhoneKey = 'user_phone';
  static const _userImageKey = 'user_image';

  var prefs = sl<SharedPreferences>();

  AuthLocalDataSource(this.prefs);

  Future<void> saveUser(User user) async {
    await prefs.setString(_userIdKey, user.id);
    await prefs.setString(_userNameKey, user.name);
    await prefs.setString(_userEmailKey, user.email);
    await prefs.setString(_userPhoneKey, user.phone ?? '');
    await prefs.setString(_userImageKey, user.image ?? '');
  }

  Future<User?> getUser() async {
    final userId = prefs.getString(_userIdKey) ?? '';
    final userName = prefs.getString(_userNameKey) ?? '';
    final userEmail = prefs.getString(_userEmailKey) ?? '';

    if (userId.isEmpty && userName.isEmpty && userEmail.isEmpty) {
      return null;
    }

    return User(
      id: userId,
      name: userName,
      email: userEmail,
      phone: prefs.getString(_userPhoneKey),
      image: prefs.getString(_userImageKey),
    );
  }

  Future<void> clearUser() async {
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_userImageKey);
  }

  bool isLoggedIn() {
    final userId = prefs.getString(_userIdKey) ?? '';
    final email = prefs.getString(_userEmailKey) ?? '';
    return userId.isNotEmpty || email.isNotEmpty;
  }
}
