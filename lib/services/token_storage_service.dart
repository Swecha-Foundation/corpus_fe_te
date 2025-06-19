// token_storage_service.dart
// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
// ignore: unused_import
import 'dart:convert';

class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _userIdKey = 'user_id';
  static const String _phoneNumberKey = 'phone_number';
  static const String _userNameKey = 'user_name';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _isLoggedInKey = 'is_logged_in'; // Add explicit login state

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
      await prefs.setBool(_isLoggedInKey, true); // Explicitly set login state
      
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
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      if (!isLoggedIn) {
        print('User is not logged in (explicit logout)');
        return null;
      }
      
      final token = prefs.getString(_tokenKey);
      if (token != null && await isTokenValid()) {
        return token;
      }
      
      // If token is invalid, clear all data
      if (token != null && !await isTokenValid()) {
        print('Token expired, clearing auth data');
        await clearAuthData();
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
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      if (!isLoggedIn) {
        return null;
      }
      
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
      final isValid = DateTime.now().isBefore(expiryTime);
      
      if (!isValid) {
        print('Token has expired');
      }
      
      return isValid;
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      if (!isLoggedIn) {
        print('User explicitly logged out');
        return false;
      }
      
      final token = await getAuthToken();
      final isValid = token != null && await isTokenValid();
      
      if (!isValid) {
        print('Authentication failed - clearing data');
        await clearAuthData();
        return false;
      }
      
      return isValid;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  // Clear all stored authentication tokens and data
  static Future<bool> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove all auth-related keys
      await prefs.remove(_tokenKey);
      await prefs.remove(_tokenTypeKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_phoneNumberKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_tokenExpiryKey);
      await prefs.setBool(_isLoggedInKey, false); // Explicitly set logged out state
      
      // Also remove alternative keys for compatibility
      await prefs.remove('userId');
      
      print('Auth data cleared successfully');
      
      // Verify clearance
      final remainingKeys = prefs.getKeys();
      print('Remaining keys after clearance: $remainingKeys');
      
      return true;
    } catch (e) {
      print('Error clearing auth data: $e');
      return false;
    }
  }

  // Get all stored user data - CHANGED TO RETURN Map<String, String?>
  static Future<Map<String, String?>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      if (!isLoggedIn) {
        return {};
      }
      
      return {
        'token': await getAuthToken(),
        'tokenType': prefs.getString(_tokenTypeKey),
        'userId': prefs.getString(_userIdKey),
        'phoneNumber': prefs.getString(_phoneNumberKey),
        'userName': prefs.getString(_userNameKey),
        'refreshToken': prefs.getString(_refreshTokenKey),
        'tokenExpiry': prefs.getString(_tokenExpiryKey),
        'isLoggedIn': isLoggedIn.toString(), // Convert bool to String
      };
    } catch (e) {
      print('Error getting user data: $e');
      return {};
    }
  }

  // Clear all stored authentication tokens (alias for backward compatibility)
  static Future<bool> clearTokens() async {
    return await clearAuthData();
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
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      return isLoggedIn ? prefs.getString(_userIdKey) : null;
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  // Get phone number
  static Future<String?> getPhoneNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      return isLoggedIn ? prefs.getString(_phoneNumberKey) : null;
    } catch (e) {
      print('Error getting phone number: $e');
      return null;
    }
  }

  // Get user name
  static Future<String?> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      return isLoggedIn ? prefs.getString(_userNameKey) : null;
    } catch (e) {
      print('Error getting user name: $e');
      return null;
    }
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      return isLoggedIn ? prefs.getString(_refreshTokenKey) : null;
    } catch (e) {
      print('Error getting refresh token: $e');
      return null;
    }
  }

  // Get token expiry date
  static Future<DateTime?> getTokenExpiry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString(_tokenExpiryKey);
      if (expiryString != null) {
        return DateTime.parse(expiryString);
      }
      return null;
    } catch (e) {
      print('Error getting token expiry: $e');
      return null;
    }
  }

  // Check if token will expire within a given duration
  static Future<bool> willTokenExpireSoon({Duration threshold = const Duration(minutes: 5)}) async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) return true;
      final now = DateTime.now();
      final expiryThreshold = expiry.subtract(threshold);
      return now.isAfter(expiryThreshold);
    } catch (e) {
      print('Error checking token expiry threshold: $e');
      return true;
    }
  }

  // Store user ID separately (for compatibility)
  static Future<bool> storeUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      await prefs.setString('userId', userId);
      return true;
    } catch (e) {
      print('Error storing user ID: $e');
      return false;
    }
  }

  // Force logout - completely clear all auth data
  static Future<bool> forceLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get all keys and remove any that might be auth-related
      final allKeys = prefs.getKeys();
      final authKeys = allKeys.where((key) => 
        key.contains('auth') || 
        key.contains('token') || 
        key.contains('user') || 
        key.contains('login')
      ).toList();
      
      for (String key in authKeys) {
        await prefs.remove(key);
      }
      
      // Explicitly set logout state
      await prefs.setBool(_isLoggedInKey, false);
      
      print('Force logout completed - removed ${authKeys.length} keys');
      return true;
    } catch (e) {
      print('Error during force logout: $e');
      return false;
    }
  }

  // Debug print stored auth data - UPDATED FOR String? format
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
    
    final isAuth = await isAuthenticated();
    final tokenValid = await isTokenValid();
    final willExpire = await willTokenExpireSoon();
    
    print('isAuthenticated: $isAuth');
    print('isTokenValid: $tokenValid');
    print('willExpireSoon: $willExpire');
    print('========================');
  }
}
