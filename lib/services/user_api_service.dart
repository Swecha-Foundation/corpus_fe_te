// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class UserApiService {
  static const String baseUrl = 'https://backend2.swecha.org/api/v1';
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  // Create new user
  static Future<Map<String, dynamic>> createUser({
    required String phone,
    required String name,
    required String email,
    required String gender,
    required DateTime dateOfBirth,
    required String place,
    required String password,
  }) async {
    try {
      print('Creating user with phone: $phone');
      
      final response = await http.post(
        Uri.parse('$baseUrl/users/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'name': name,
          'email': email,
          'gender': gender,
          'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
          'place': place,
          'password': password,
          'has_given_consent': true,
        }),
      ).timeout(timeoutDuration);
      
      print('Create User Response Status: ${response.statusCode}');
      print('Create User Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'User created successfully'
        };
      } else {
        final errorData = _parseErrorResponse(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to create user',
          'error': errorData
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please check your internet connection.',
        'error': 'timeout'
      };
    } catch (e) {
      print('Create User Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString()
      };
    }
  }
  
  // Get user by phone number using the dedicated endpoint
  static Future<Map<String, dynamic>> getUserByPhone(String phone) async {
    try {
      print('Getting user by phone: $phone');
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/phone/$phone'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(timeoutDuration);
      
      print('Get User By Phone Response Status: ${response.statusCode}');
      print('Get User By Phone Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'User found successfully'
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'User not found',
          'error': 'user_not_found'
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Access forbidden. Authentication may be required.',
          'error': 'forbidden'
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': 'Invalid phone number format',
          'error': 'validation_error'
        };
      } else {
        final errorData = _parseErrorResponse(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to get user',
          'error': errorData
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please check your internet connection.',
        'error': 'timeout'
      };
    } catch (e) {
      print('Get User By Phone Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString()
      };
    }
  }
  
  // Check if user exists - now using the dedicated endpoint
  static Future<Map<String, dynamic>> checkUserExists(String phone) async {
    try {
      print('Checking if user exists with phone: $phone');
      
      final result = await getUserByPhone(phone);
      
      if (result['success']) {
        return {
          'success': true,
          'data': {
            'phone': phone,
            'exists': true,
            'user': result['data']
          },
          'message': 'User exists'
        };
      } else if (result['error'] == 'user_not_found') {
        return {
          'success': false,
          'data': {
            'phone': phone,
            'exists': false
          },
          'message': 'User not found',
          'error': 'user_not_found'
        };
      } else {
        return result; // Return the original error
      }
    } catch (e) {
      print('Check User Exists Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString()
      };
    }
  }
  
  // Login user with phone and password
  static Future<Map<String, dynamic>> loginUser({
    required String phone,
    required String password,
  }) async {
    try {
      print('Logging in user with phone: $phone');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      ).timeout(timeoutDuration);
      
      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Login successful'
        };
      } else {
        final errorData = _parseErrorResponse(response.body);
        String errorMessage = errorData['message'] ?? 'Login failed';
        
        // Provide more user-friendly error messages
        if (_isInvalidCredentialsError(errorMessage)) {
          errorMessage = 'Invalid phone number or password';
        } else if (_isUserNotFoundError(errorMessage)) {
          errorMessage = 'No account found with this phone number';
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'error': errorData
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please check your internet connection.',
        'error': 'timeout'
      };
    } catch (e) {
      print('Login Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString()
      };
    }
  }
  
  // Verify OTP and get user data
  static Future<Map<String, dynamic>> verifyOTPAndGetUser({
    required String phone,
    required String otp,
  }) async {
    try {
      print('Verifying OTP and getting user data for phone: $phone');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phone,
          'otp_code': otp,
          'has_given_consent': true,
        }),
      ).timeout(timeoutDuration);
      
      print('Verify OTP Response Status: ${response.statusCode}');
      print('Verify OTP Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'OTP verified successfully'
        };
      } else {
        final errorData = _parseErrorResponse(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'OTP verification failed',
          'error': errorData
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please check your internet connection.',
        'error': 'timeout'
      };
    } catch (e) {
      print('Verify OTP Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString()
      };
    }
  }
  
  // Update user's last login
  static Future<Map<String, dynamic>> updateLastLogin(String userId, {String? authToken}) async {
    try {
      print('Updating last login for user: $userId');
      
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }
      
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
        body: jsonEncode({
          'last_login_at': DateTime.now().toIso8601String(),
        }),
      ).timeout(timeoutDuration);
      
      print('Update Last Login Response Status: ${response.statusCode}');
      print('Update Last Login Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Last login updated successfully'
        };
      } else {
        final errorData = _parseErrorResponse(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to update last login',
          'error': errorData
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please check your internet connection.',
        'error': 'timeout'
      };
    } catch (e) {
      print('Update Last Login Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString()
      };
    }
  }
  
  // Get user profile (requires authentication)
  static Future<Map<String, dynamic>> getUserProfile(String userId, {required String authToken}) async {
    try {
      print('Getting user profile for ID: $userId');
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(timeoutDuration);
      
      print('Get User Profile Response Status: ${response.statusCode}');
      print('Get User Profile Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'User profile retrieved successfully'
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'User not found',
          'error': 'user_not_found'
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Authentication required',
          'error': 'not_authenticated'
        };
      } else {
        final errorData = _parseErrorResponse(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to get user profile',
          'error': errorData
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please check your internet connection.',
        'error': 'timeout'
      };
    } catch (e) {
      print('Get User Profile Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString()
      };
    }
  }
  
  // Helper method to parse error responses safely
  static Map<String, dynamic> _parseErrorResponse(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return {
          'message': decoded['detail'] ?? decoded['message'] ?? decoded['error'] ?? 'An error occurred',
          'details': decoded
        };
      }
      return {'message': 'An error occurred', 'details': decoded};
    } catch (e) {
      return {'message': 'An error occurred', 'details': responseBody};
    }
  }
  
  // Helper method to check if error indicates user not found
  static bool _isUserNotFoundError(String errorMessage) {
    final message = errorMessage.toLowerCase();
    return message.contains('user not found') || 
           message.contains('does not exist') ||
           message.contains('user does not exist') ||
           message.contains('no user found');
  }
  
  // Helper method to check if error indicates invalid credentials
  static bool _isInvalidCredentialsError(String errorMessage) {
    final message = errorMessage.toLowerCase();
    return message.contains('invalid credentials') ||
           message.contains('incorrect') ||
           message.contains('wrong password') ||
           message.contains('authentication failed');
  }
}