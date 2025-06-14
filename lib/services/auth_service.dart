// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage_service.dart';

class ApiService {
  static const String baseUrl = 'https://backend2.swecha.org';
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  // Get headers with authorization if token is available
  static Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (includeAuth) {
      try {
        final authHeader = await TokenStorageService.getAuthorizationHeader();
        if (authHeader != null && authHeader.isNotEmpty) {
          headers['Authorization'] = authHeader;
        }
      } catch (e) {
        print('Error getting auth header: $e');
      }
    }
    
    return headers;
  }

  // Generic GET request with authentication
  static Future<Map<String, dynamic>> get(String endpoint, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(timeoutDuration);

      print('GET $endpoint - Status: ${response.statusCode}');
      print('Response: ${response.body}');

      final responseData = _parseResponse(response.body);
      
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': responseData,
        'message': responseData['message'] ?? '',
      };
    } catch (e) {
      print('GET $endpoint error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': null,
      };
    }
  }

  // Generic POST request with authentication
  static Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> data, 
    {bool requireAuth = true}
  ) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      ).timeout(timeoutDuration);

      print('POST $endpoint - Status: ${response.statusCode}');
      print('Response: ${response.body}');

      final responseData = _parseResponse(response.body);
      
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'statusCode': response.statusCode,
        'data': responseData,
        'message': responseData['message'] ?? '',
      };
    } catch (e) {
      print('POST $endpoint error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': null,
      };
    }
  }

  // Generic PUT request with authentication
  static Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> data, 
    {bool requireAuth = true}
  ) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      ).timeout(timeoutDuration);

      print('PUT $endpoint - Status: ${response.statusCode}');
      print('Response: ${response.body}');

      final responseData = _parseResponse(response.body);
      
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'data': responseData,
        'message': responseData['message'] ?? '',
      };
    } catch (e) {
      print('PUT $endpoint error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': null,
      };
    }
  }

  // Generic DELETE request with authentication
  static Future<Map<String, dynamic>> delete(String endpoint, {bool requireAuth = true}) async {
    try {
      final headers = await _getHeaders(includeAuth: requireAuth);
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(timeoutDuration);

      print('DELETE $endpoint - Status: ${response.statusCode}');
      print('Response: ${response.body}');

      final responseData = _parseResponse(response.body);
      
      return {
        'success': response.statusCode == 200 || response.statusCode == 204,
        'statusCode': response.statusCode,
        'data': responseData,
        'message': responseData['message'] ?? '',
      };
    } catch (e) {
      print('DELETE $endpoint error: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': null,
      };
    }
  }

  // Helper method to safely parse JSON responses
  static Map<String, dynamic> _parseResponse(String responseBody) {
    try {
      if (responseBody.isEmpty) {
        return {'message': 'Empty response'};
      }
      
      final decoded = json.decode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'message': 'Unexpected response format', 'raw': decoded};
    } catch (e) {
      return {'message': 'Failed to parse response', 'raw': responseBody};
    }
  }

  // Test authenticated endpoint
  static Future<Map<String, dynamic>> testAuth() async {
    return await get('/api/v1/auth/me');
  }

  // Get user profile (requires authentication)
  static Future<Map<String, dynamic>> getUserProfile() async {
    return await get('/api/v1/auth/me');
  }

  // Change password (requires authentication)
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await post('/api/v1/auth/change-password', {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  // Refresh token
  static Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshResult = await post('/api/v1/auth/refresh', {});
      
      if (refreshResult['success'] == true) {
        final responseData = refreshResult['data'];
        if (responseData != null) {
          String? newToken = responseData['access_token']?.toString();
          String tokenType = responseData['token_type']?.toString() ?? 'bearer';
          
          if (newToken != null && newToken.isNotEmpty) {
            // Get existing user data
            final existingData = await TokenStorageService.getAuthData();
            
            // Store updated token with existing user data
            await TokenStorageService.storeAuthData(
              token: newToken,
              tokenType: tokenType,
              userId: existingData['userId'],
              phoneNumber: existingData['phoneNumber'],
              userName: existingData['userName'],
            );
          }
        }
      }
      
      return refreshResult;
    } catch (e) {
      print('Refresh token error: $e');
      return {
        'success': false,
        'message': 'Failed to refresh token: $e',
      };
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      // Try to call logout endpoint if available
      final logoutResult = await post('/api/v1/auth/logout', {});
      
      // Always clear stored auth data regardless of API call result
      await TokenStorageService.clearAuthData();
      
      return {
        'success': true,
        'message': 'Logged out successfully',
        'data': logoutResult['data'],
      };
    } catch (e) {
      print('Logout error: $e');
      // Still clear local data even if API call fails
      await TokenStorageService.clearAuthData();
      return {
        'success': true,
        'message': 'Logged out locally',
      };
    }
  }

  // Check if token is valid
  static Future<bool> isTokenValid() async {
    try {
      final result = await testAuth();
      return result['success'] == true;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  // Auto-refresh token if needed and retry request
  static Future<Map<String, dynamic>> authenticatedRequest(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    try {
      // Try the request first
      var result = await request();
      
      // If unauthorized, try to refresh token and retry
      if (result['statusCode'] == 401) {
        print('Token expired, attempting refresh...');
        final refreshResult = await refreshToken();
        
        if (refreshResult['success'] == true) {
          print('Token refreshed successfully, retrying request...');
          result = await request();
        } else {
          print('Token refresh failed, logging out...');
          await logout();
          return {
            'success': false,
            'message': 'Authentication expired, please login again',
            'statusCode': 401,
          };
        }
      }
      
      return result;
    } catch (e) {
      print('Authenticated request error: $e');
      return {
        'success': false,
        'message': 'Request failed: $e',
      };
    }
  }
}