import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _userIdKey = 'user_id';
  static const String _phoneNumberKey = 'phone_number';
  static const String _userNameKey = 'user_name';

  // Store authentication data
  static Future<void> storeAuthData({
    required String token,
    required String tokenType,
    String? userId,
    String? phoneNumber,
    String? userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenTypeKey, tokenType);
    
    if (userId != null) {
      await prefs.setString(_userIdKey, userId);
    }
    if (phoneNumber != null) {
      await prefs.setString(_phoneNumberKey, phoneNumber);
    }
    if (userName != null) {
      await prefs.setString(_userNameKey, userName);
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get token type
  static Future<String?> getTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey) ?? 'bearer';
  }

  // Get authorization header value
  static Future<String?> getAuthorizationHeader() async {
    final token = await getToken();
    final tokenType = await getTokenType();
    
    if (token != null) {
      return '$tokenType $token';
    }
    return null;
  }

  // Get user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Get phone number
  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneNumberKey);
  }

  // Get user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all stored data (logout)
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenTypeKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_phoneNumberKey);
    await prefs.remove(_userNameKey);
  }

  // Get all auth data
  static Future<Map<String, dynamic>> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'token': prefs.getString(_tokenKey),
      'tokenType': prefs.getString(_tokenTypeKey),
      'userId': prefs.getString(_userIdKey),
      'phoneNumber': prefs.getString(_phoneNumberKey),
      'userName': prefs.getString(_userNameKey),
    };
  }
}