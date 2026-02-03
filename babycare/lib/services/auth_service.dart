import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  final DatabaseService _dbService = DatabaseService();

  // Hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        return {'success': false, 'message': 'Invalid email format'};
      }

      // Validate password strength
      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters'
        };
      }

      // Check if email already exists
      final existingUser = await getUserByEmail(email);
      if (existingUser != null) {
        return {'success': false, 'message': 'Email already registered'};
      }

      // Hash password and create user
      final passwordHash = _hashPassword(password);
      final user = User(
        email: email.toLowerCase().trim(),
        passwordHash: passwordHash,
        fullName: fullName.trim(),
        phoneNumber: phoneNumber?.trim(),
        createdAt: DateTime.now().toIso8601String(),
      );

      final db = await _dbService.database;
      final userId = await db.insert('user', user.toMap());

      return {
        'success': true,
        'message': 'Registration successful',
        'userId': userId
      };
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  // Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await getUserByEmail(email.toLowerCase().trim());

      if (user == null) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      final passwordHash = _hashPassword(password);
      if (user.passwordHash != passwordHash) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      return {
        'success': true,
        'message': 'Login successful',
        'user': user.copyWithoutPassword()
      };
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    try {
      final db = await _dbService.database;
      final maps = await db.query(
        'user',
        where: 'email = ?',
        whereArgs: [email.toLowerCase().trim()],
      );

      if (maps.isEmpty) return null;
      return User.fromMap(maps.first);
    } catch (e) {
      return null;
    }
  }

  // Get user by ID
  Future<User?> getUserById(int id) async {
    try {
      final db = await _dbService.database;
      final maps = await db.query(
        'user',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;
      return User.fromMap(maps.first);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    required int userId,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final db = await _dbService.database;
      await db.update(
        'user',
        {
          'full_name': fullName.trim(),
          'phone_number': phoneNumber?.trim(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = await getUserById(userId);
      if (user == null) {
        return {'success': false, 'message': 'User not found'};
      }

      final currentHash = _hashPassword(currentPassword);
      if (user.passwordHash != currentHash) {
        return {'success': false, 'message': 'Current password is incorrect'};
      }

      if (newPassword.length < 6) {
        return {
          'success': false,
          'message': 'New password must be at least 6 characters'
        };
      }

      final newHash = _hashPassword(newPassword);
      final db = await _dbService.database;
      await db.update(
        'user',
        {'password_hash': newHash},
        where: 'id = ?',
        whereArgs: [userId],
      );

      return {'success': true, 'message': 'Password changed successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to change password: $e'};
    }
  }

  // Email validation
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
