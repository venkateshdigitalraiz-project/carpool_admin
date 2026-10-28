import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/entities/user_profile.dart';

/// Centralized local storage manager using SharedPreferences.
/// Handles persistence of user credentials, login state, and authentication tokens.
class StoredLocal {
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserProfile = 'cached_user_profile';
  static const String keyPhoneNumber = 'user_phone_number';
  static const String keyAuthToken = 'auth_token';

  // Singleton instance
  static final StoredLocal _instance = StoredLocal._internal();
  factory StoredLocal([SharedPreferences? prefs]) {
    if (prefs != null) {
      _sharedPrefs = prefs;
    }
    return _instance;
  }
  StoredLocal._internal();

  static SharedPreferences? _sharedPrefs;
  static UserProfile? _memoryUser;
  static bool? _memoryIsLoggedIn;

  Future<SharedPreferences> get _prefs async {
    _sharedPrefs ??= await SharedPreferences.getInstance();
    return _sharedPrefs!;
  }

  /// Initialize SharedPreferences in advance (e.g. in main.dart)
  Future<void> init() async {
    try {
      _sharedPrefs = await SharedPreferences.getInstance();
      try {
        await _sharedPrefs?.reload();
      } catch (_) {}
      debugPrint('[StoredLocal] Initialized successfully. Keys: ${_sharedPrefs?.getKeys()}');
    } catch (e) {
      debugPrint('[StoredLocal] Error initializing SharedPreferences: $e');
    }
  }

  /// Save logged-in user profile & mark login state
  Future<bool> saveUser(UserProfile user) async {
    _memoryUser = user;
    _memoryIsLoggedIn = true;
    try {
      final prefs = await _prefs;
      final jsonStr = jsonEncode(user.toJson());
      await prefs.setString(keyUserProfile, jsonStr);
      await prefs.setBool(keyIsLoggedIn, true);
      await prefs.setString(keyPhoneNumber, user.phoneNumber);
      debugPrint('[StoredLocal] User persisted successfully: ${user.fullName} (${user.phoneNumber})');
      return true;
    } catch (e) {
      debugPrint('[StoredLocal] Error saving user: $e');
      return false;
    }
  }

  /// Retrieve cached UserProfile from storage
  Future<UserProfile?> getUser() async {
    // 1. Try reading from SharedPreferences
    try {
      final prefs = await _prefs;
      try {
        await prefs.reload();
      } catch (_) {}

      final jsonStr = prefs.getString(keyUserProfile);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(jsonStr);
        final user = UserProfile.fromJson(map);
        _memoryUser = user;
        _memoryIsLoggedIn = true;
        debugPrint('[StoredLocal] Restored user from JSON: ${user.fullName} (${user.phoneNumber})');
        return user;
      }

      // 2. Fallback check for isLoggedIn flag or phone number
      final bool loggedIn = prefs.getBool(keyIsLoggedIn) ?? false;
      final String? phone = prefs.getString(keyPhoneNumber);
      if (loggedIn || (phone != null && phone.isNotEmpty)) {
        final fallbackUser = UserProfile(
          id: 'usr_${(phone ?? 'user').replaceAll(RegExp(r'[^0-9]'), '')}',
          firstName: 'Vankatesh',
          lastName: '',
          email: '${phone ?? 'user'}@carpool.com',
          phoneNumber: phone ?? '',
          authProvider: 'phone',
        );
        _memoryUser = fallbackUser;
        _memoryIsLoggedIn = true;
        debugPrint('[StoredLocal] Restored user from fallback credentials: ${fallbackUser.phoneNumber}');
        return fallbackUser;
      }
    } catch (e) {
      debugPrint('[StoredLocal] Error getting user: $e');
    }

    // 3. Fallback to in-memory cached user
    if (_memoryUser != null) {
      debugPrint('[StoredLocal] Restored user from memory cache: ${_memoryUser?.phoneNumber}');
      return _memoryUser;
    }

    debugPrint('[StoredLocal] No saved user found.');
    return null;
  }

  /// Check if user has previously completed login / OTP verification
  Future<bool> isLoggedIn() async {
    if (_memoryIsLoggedIn == true) return true;
    try {
      final prefs = await _prefs;
      try {
        await prefs.reload();
      } catch (_) {}
      final loggedIn = prefs.getBool(keyIsLoggedIn) ?? false;
      if (loggedIn) return true;
      final user = await getUser();
      return user != null;
    } catch (e) {
      debugPrint('[StoredLocal] Error checking login status: $e');
      return false;
    }
  }

  /// Clear all user auth data upon logout
  Future<void> clearUser() async {
    _memoryUser = null;
    _memoryIsLoggedIn = false;
    try {
      final prefs = await _prefs;
      await prefs.remove(keyUserProfile);
      await prefs.remove(keyIsLoggedIn);
      await prefs.remove(keyPhoneNumber);
      await prefs.remove(keyAuthToken);
      debugPrint('[StoredLocal] User cleared successfully.');
    } catch (e) {
      debugPrint('[StoredLocal] Error clearing user: $e');
    }
  }

  /// Helper to store arbitrary string values
  Future<void> setString(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  /// Helper to read arbitrary string values
  Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  /// Helper to store arbitrary boolean values
  Future<void> setBool(String key, bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(key, value);
  }

  /// Helper to read arbitrary boolean values
  Future<bool?> getBool(String key) async {
    final prefs = await _prefs;
    return prefs.getBool(key);
  }
}
