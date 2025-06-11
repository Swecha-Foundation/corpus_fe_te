// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class UserApiService {
  static const String baseUrl = 'https://backend2.swecha.org/api/v1';
  
  // Create new user
  static Future<Map<String, dynamic>> createUser({
    required String phone,
    required String name,
    required String email,
    required String gender,
    required DateTime dateOfBirth,
    required String place,
    required String password, // Add password parameter
  }) async {
    try {
      print('Creating user with phone: $phone'); // Debug log
      
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
          'date_of_birth': dateOfBirth.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
          'place': place,
          'password': password, // Include password in request body
          'has_given_consent': true,
        }),
      );
      
      print('Create User Response Status: ${response.statusCode}'); // Debug log
      print('Create User Response Body: ${response.body}'); // Debug log
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'User created successfully'
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? errorData['message'] ?? 'Failed to create user',
          'error': errorData
        };
      }
    } catch (e) {
      print('Create User Error: $e'); // Debug log
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': e.toString()
      };
    }
  }
  
  // Check if user exists by phone number (FIXED - now uses getUserByPhone)
  static Future<Map<String, dynamic>> checkUserExists(String phone) async {
    try {
      print('Checking if user exists with phone: $phone'); // Debug log
      
      // Use the existing getUserByPhone method instead of non-existent endpoint
      final response = await getUserByPhone(phone);
      
      if (response['success']) {
        return {
          'success': true,
          'data': response['data'],
          'message': 'User exists'
        };
      } else if (response['error'] == 'user_not_found') {
        return {
          'success': false,
          'message': 'User not found',
          'error': 'user_not_found'
        };
      } else if (response['error'] == 'not_authenticated') {
        // If authentication is required, try a different approach
        // This might happen if the getUserByPhone endpoint requires auth
        print('Authentication required for getUserByPhone, trying alternative approach');
        
        // Try to use the users endpoint without auth first
        try {
          final directResponse = await http.get(
            Uri.parse('$baseUrl/users/?phone=$phone'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          );
          
          print('Direct User Check Response Status: ${directResponse.statusCode}');
          print('Direct User Check Response Body: ${directResponse.body}');
          
          if (directResponse.statusCode == 200) {
            final responseData = jsonDecode(directResponse.body);
            
            // Check if user exists
            if (responseData is List && responseData.isNotEmpty) {
              return {
                'success': true,
                'data': responseData.first,
                'message': 'User exists'
              };
            } else if (responseData is Map && responseData.isNotEmpty) {
              return {
                'success': true,
                'data': responseData,
                'message': 'User exists'
              };
            } else {
              return {
                'success': false,
                'message': 'User not found',
                'error': 'user_not_found'
              };
            }
          } else {
            return {
              'success': false,
              'message': 'User not found',
              'error': 'user_not_found'
            };
          }
        } catch (e) {
          print('Direct user check error: $e');
          return {
            'success': false,
            'message': 'User not found',
            'error': 'user_not_found'
          };
        }
      } else {
        return response; // Return the original error response
      }
    } catch (e) {
      print('Check User Error: $e'); // Debug log
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': e.toString()
      };
    }
  }
  
  // Get user by phone number (Note: This requires authentication)
  static Future<Map<String, dynamic>> getUserByPhone(String phone, {String? authToken}) async {
    try {
      print('Getting user by phone: $phone'); // Debug log
      
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      // Add authorization header if token is provided
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/?phone=$phone'),
        headers: headers,
      );
      
      print('Get User Response Status: ${response.statusCode}'); // Debug log
      print('Get User Response Body: ${response.body}'); // Debug log
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        // Check if user exists (assuming API returns a list or single user object)
        if (responseData is List && responseData.isNotEmpty) {
          return {
            'success': true,
            'data': responseData.first,
            'message': 'User found'
          };
        } else if (responseData is Map && responseData.isNotEmpty) {
          return {
            'success': true,
            'data': responseData,
            'message': 'User found'
          };
        } else {
          return {
            'success': false,
            'message': 'User not found',
            'error': 'user_not_found'
          };
        }
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'User not found',
          'error': 'user_not_found'
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'Authentication required',
          'error': 'not_authenticated'
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? errorData['message'] ?? 'Failed to get user',
          'error': errorData
        };
      }
    } catch (e) {
      print('Get User Error: $e'); // Debug log
      return {
        'success': false,
        'message': 'Network error: $e',
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
      print('Logging in user with phone: $phone'); // Debug log
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'), // Adjust endpoint as needed
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );
      
      print('Login Response Status: ${response.statusCode}'); // Debug log
      print('Login Response Body: ${response.body}'); // Debug log
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Login successful'
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? errorData['message'] ?? 'Login failed',
          'error': errorData
        };
      }
    } catch (e) {
      print('Login Error: $e'); // Debug log
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': e.toString()
      };
    }
  }
  
  // Verify OTP and get user data (this should be called after OTP verification)
  static Future<Map<String, dynamic>> verifyOTPAndGetUser({
    required String phone,
    required String otp,
  }) async {
    try {
      print('Verifying OTP and getting user data for phone: $phone'); // Debug log
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'), // Adjust endpoint as needed
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
        }),
      );
      
      print('Verify OTP Response Status: ${response.statusCode}'); // Debug log
      print('Verify OTP Response Body: ${response.body}'); // Debug log
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'OTP verified successfully'
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? errorData['message'] ?? 'OTP verification failed',
          'error': errorData
        };
      }
    } catch (e) {
      print('Verify OTP Error: $e'); // Debug log
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': e.toString()
      };
    }
  }
  
  // Update user's last login
  static Future<Map<String, dynamic>> updateLastLogin(String userId, {String? authToken}) async {
    try {
      print('Updating last login for user: $userId'); // Debug log
      
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      // Add authorization header if token is provided
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }
      
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId'),
        headers: headers,
        body: jsonEncode({
          'last_login_at': DateTime.now().toIso8601String(),
        }),
      );
      
      print('Update Last Login Response Status: ${response.statusCode}'); // Debug log
      print('Update Last Login Response Body: ${response.body}'); // Debug log
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Last login updated successfully'
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? errorData['message'] ?? 'Failed to update last login',
          'error': errorData
        };
      }
    } catch (e) {
      print('Update Last Login Error: $e'); // Debug log
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': e.toString()
      };
    }
  }
}