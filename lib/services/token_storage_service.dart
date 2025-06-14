// token_storage_service.dart
// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _userIdKey = 'user_id';
  static const String _phoneNumberKey = 'phone_number';
  static const String _userNameKey = 'user_name';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _refreshTokenKey = 'refresh_token';

  // Store authentication data
  static Future<bool> storeAuthData({
    required String token,
    String tokenType = 'bearer',
    String? userId,
    String? phoneNumber,
    String? userName,
    String? refreshToken,
    DateTime? expiryTime,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_tokenTypeKey, tokenType);
      
      if (userId != null) await prefs.setString(_userIdKey, userId);
      if (phoneNumber != null) await prefs.setString(_phoneNumberKey, phoneNumber);
      if (userName != null) await prefs.setString(_userNameKey, userName);
      if (refreshToken != null) await prefs.setString(_refreshTokenKey, refreshToken);
      
      // Store expiry time (default to 24 hours if not provided)
      final expiry = expiryTime ?? DateTime.now().add(const Duration(hours: 24));
      await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
      
      print('Auth data stored successfully');
      print('Token: ${token.substring(0, 20)}...'); // Log partial token for debugging
      
      return true;
    } catch (e) {
      print('Error storing auth data: $e');
      return false;
    }
  }

  // Get stored authentication token
  static Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      if (token != null && await isTokenValid()) {
        return token;
      }
      
      return null;
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  // Get authorization header value
  static Future<String?> getAuthorizationHeader() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = await getAuthToken();
      final tokenType = prefs.getString(_tokenTypeKey) ?? 'bearer';
      
      if (token != null) {
        return '${tokenType.toLowerCase()} $token';
      }
      
      return null;
    } catch (e) {
      print('Error getting authorization header: $e');
      return null;
    }
  }

  // Check if token is valid (not expired)
  static Future<bool> isTokenValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString(_tokenExpiryKey);
      
      if (expiryString == null) return false;
      
      final expiryTime = DateTime.parse(expiryString);
      return DateTime.now().isBefore(expiryTime);
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && await isTokenValid();
  }

  // Get all stored user data
  static Future<Map<String, String?>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return {
        'token': await getAuthToken(),
        'tokenType': prefs.getString(_tokenTypeKey),
        'userId': prefs.getString(_userIdKey),
        'phoneNumber': prefs.getString(_phoneNumberKey),
        'userName': prefs.getString(_userNameKey),
        'refreshToken': prefs.getString(_refreshTokenKey),
        'tokenExpiry': prefs.getString(_tokenExpiryKey),
      };
    } catch (e) {
      print('Error getting user data: $e');
      return {};
    }
  }

  // Clear all stored authentication data
  static Future<bool> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove(_tokenKey);
      await prefs.remove(_tokenTypeKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_phoneNumberKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_tokenExpiryKey);
      
      print('Auth data cleared successfully');
      return true;
    } catch (e) {
      print('Error clearing auth data: $e');
      return false;
    }
  }

  // Update token expiry time
  static Future<bool> updateTokenExpiry(DateTime newExpiry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenExpiryKey, newExpiry.toIso8601String());
      return true;
    } catch (e) {
      print('Error updating token expiry: $e');
      return false;
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  // Get phone number
  static Future<String?> getPhoneNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_phoneNumberKey);
    } catch (e) {
      print('Error getting phone number: $e');
      return null;
    }
  }

  // Get user name
  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey);
    } catch (e) {
      print('Error getting user name: $e');
      return null;
    }
  }

  // Print stored auth data for debugging
  static Future<void> debugPrintAuthData() async {
    final userData = await getUserData();
    print('=== Stored Auth Data ===');
    userData.forEach((key, value) {
      if (key == 'token' && value != null && value.length > 20) {
        print('$key: ${value.substring(0, 20)}...');
      } else {
        print('$key: $value');
      }
    });
    print('========================');
  }
}