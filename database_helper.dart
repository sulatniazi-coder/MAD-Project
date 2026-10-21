
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _usersKey = 'findit_users';

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<List<Map<String, dynamic>>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedUsers = prefs.getString(_usersKey);

    if (savedUsers == null) return [];

    final List<dynamic> decoded = jsonDecode(savedUsers);
    return decoded
        .map((user) => Map<String, dynamic>.from(user))
        .toList();
  }

  Future<String?> registerUser(
      String name,
      String email,
      String password,
      ) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _getUsers();

    if (normalizedEmail.isEmpty || password.isEmpty || name.trim().isEmpty) {
      return 'Please fill in all fields.';
    }

    if (users.any((user) => user['email'] == normalizedEmail)) {
      return 'An account with this email already exists.';
    }

    users.add({
      'name': name.trim(),
      'email': normalizedEmail,
      'passwordHash': _hashPassword(password),
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));

    return null;
  }

  Future<Map<String, dynamic>?> loginUser(
      String email,
      String password,
      ) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _getUsers();

    for (final user in users) {
      if (user['email'] == normalizedEmail &&
          user['passwordHash'] == _hashPassword(password)) {
        return {
          'name': user['name'],
          'email': user['email'],
        };
      }
    }

    return null;
  }
}
