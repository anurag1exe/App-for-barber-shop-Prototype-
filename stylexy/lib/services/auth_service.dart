import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final _db = DatabaseService.instance;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  String _generateReferralCode() {
    final uuid = const Uuid().v4().replaceAll('-', '').toUpperCase();
    return uuid.substring(0, 8);
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('currentUserId');
    if (userId != null) {
      final rows = await _db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (rows.isNotEmpty) {
        _currentUser = AppUser.fromMap(rows.first);
      }
    }
  }

  Future<({bool success, String message})> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    // Validate inputs
    if (name.trim().isEmpty) {
      return (success: false, message: 'Name is required');
    }
    if (phone.trim().length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(phone.trim())) {
      return (success: false, message: 'Enter a valid 10-digit Indian mobile number');
    }
    if (password.length < 6) {
      return (success: false, message: 'Password must be at least 6 characters');
    }

    // Check for duplicate phone
    final existing = await _db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone.trim()],
    );
    if (existing.isNotEmpty) {
      return (success: false, message: 'An account with this phone number already exists');
    }

    final user = AppUser(
      id: const Uuid().v4(),
      name: name.trim(),
      phone: phone.trim(),
      referralCode: _generateReferralCode(),
      passwordHash: _hashPassword(password),
    );

    await _db.insert('users', user.toMap());
    _currentUser = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserId', user.id);

    return (success: true, message: 'Registration successful!');
  }

  Future<({bool success, String message})> login({
    required String phone,
    required String password,
  }) async {
    if (phone.trim().isEmpty || password.isEmpty) {
      return (success: false, message: 'Phone and password are required');
    }

    final rows = await _db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone.trim()],
    );

    if (rows.isEmpty) {
      return (success: false, message: 'No account found with this phone number');
    }

    final user = AppUser.fromMap(rows.first);
    if (user.passwordHash != _hashPassword(password)) {
      return (success: false, message: 'Incorrect password');
    }

    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserId', user.id);

    return (success: true, message: 'Login successful!');
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserId');
  }

  Future<void> updateProfile({String? name, String? phone, String? photoPath}) async {
    if (_currentUser == null) return;

    final updates = <String, dynamic>{};
    if (name != null && name.trim().isNotEmpty) updates['name'] = name.trim();
    if (phone != null && phone.trim().isNotEmpty) updates['phone'] = phone.trim();
    if (photoPath != null) updates['photoPath'] = photoPath;

    if (updates.isEmpty) return;

    await _db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [_currentUser!.id],
    );

    _currentUser = _currentUser!.copyWith(
      name: updates['name'] as String? ?? _currentUser!.name,
      phone: updates['phone'] as String? ?? _currentUser!.phone,
      photoPath: updates['photoPath'] as String? ?? _currentUser!.photoPath,
    );
  }

  Future<void> refreshCurrentUser() async {
    if (_currentUser == null) return;
    final rows = await _db.query(
      'users',
      where: 'id = ?',
      whereArgs: [_currentUser!.id],
    );
    if (rows.isNotEmpty) {
      _currentUser = AppUser.fromMap(rows.first);
    }
  }
}
