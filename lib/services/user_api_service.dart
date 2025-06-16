// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class UserApiService {
  static const String baseUrl = 'https://backend2.swecha.org/api/v1';
  static const Duration timeoutDuration = Duration(seconds: 30);

  static String _formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Remove +91 if it exists at the beginning
    if (cleanNumber.startsWith('91') && cleanNumber.length == 12) {
      cleanNumber = cleanNumber.substring(2);
    }
    
    // Ensure we have exactly 10 digits
    if (cleanNumber.length == 10) {
      return '+91$cleanNumber';
    }
    
    // Return with +91 prefix anyway for server validation
    return '+91$cleanNumber';
  }
  
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
    // Input validation
    if (phone.isEmpty || name.isEmpty || email.isEmpty || 
        gender.isEmpty || place.isEmpty || password.isEmpty) {
      return {
        'success': false,
        'message': 'All fields are required',
        'error': 'missing_fields'
      };
    }
    
    // Validate email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return {
        'success': false,
        'message': 'Please enter a valid email address',
        'error': 'invalid_email'
      };
    }
    
    // Validate password length
    if (password.length < 6) {
      return {
        'success': false,
        'message': 'Password must be at least 6 characters long',
        'error': 'weak_password'
      };
    }
    
    try {
      String formattedPhone = _formatPhoneNumber(phone);
      print('Creating user with phone: $formattedPhone');
      
      final response = await http.post(
        Uri.parse('$baseUrl/users/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': formattedPhone, // Use formatted phone number
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'gender': gender,
          'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
          'place': place.trim(),
          'password': password,
          'has_given_consent': true,
        }),
      ).timeout(timeoutDuration);
      
      print('Create User Response Status: ${response.statusCode}');
      print('Create User Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = _parseResponse(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'User created successfully'
        };
      } else if (response.statusCode == 400) {
        final errorData = _parseErrorResponse(response.body);
        String errorMessage = errorData['message'] ?? 'Failed to create user';
        
        // Handle specific validation errors
        if (_isUserExistsError(errorMessage)) {
          return {
            'success': false,
            'message': 'An account with this phone number or email already exists',
            'error': 'user_exists'
          };
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'error': 'validation_error'
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': 'An account with this phone number or email already exists',
          'error': 'user_exists'
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
    } on http.ClientException catch (e) {
      print('Create User Client Error: $e');
      return {
        'success': false,
        'message': 'Network connection error. Please check your internet connection.',
        'error': 'network_error'
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
    if (phone.isEmpty) {
      return {
        'success': false,
        'message': 'Phone number is required',
        'error': 'invalid_input'
      };
    }
    
    try {
      String formattedPhone = _formatPhoneNumber(phone);
      print('Getting user by phone: $formattedPhone');
      
      // Use the clean phone number without +91 for the URL
      String cleanPhone = formattedPhone.replaceFirst('+91', '');
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/phone/$cleanPhone'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(timeoutDuration);
      
      print('Get User By Phone Response Status: ${response.statusCode}');
      print('Get User By Phone Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = _parseResponse(response.body);
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
    } on http.ClientException catch (e) {
      print('Get User By Phone Client Error: $e');
      return {
        'success': false,
        'message': 'Network connection error. Please check your internet connection.',
        'error': 'network_error'
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
    if (phone.isEmpty) {
      return {
        'success': false,
        'message': 'Phone number is required',
        'error': 'invalid_input'
      };
    }
    
    try {
      String formattedPhone = _formatPhoneNumber(phone);
      print('Checking if user exists with phone: $formattedPhone');
      
      final result = await getUserByPhone(phone);
      
      if (result['success'] == true) {
        return {
          'success': true,
          'data': {
            'phone': formattedPhone,
            'exists': true,
            'user': result['data']
          },
          'message': 'User exists'
        };
      } else if (result['error'] == 'user_not_found') {
        return {
          'success': false,
          'data': {
            'phone': formattedPhone,
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
  // Input validation
  if (phone.isEmpty || password.isEmpty) {
    return {
      'success': false,
      'message': 'Phone number and password are required',
      'error': 'missing_credentials'
    };
  }
  
  try {
    String formattedPhone = _formatPhoneNumber(phone);
    print('=== LOGIN DEBUG START ===');
    print('Original phone: $phone');
    print('Formatted phone: $formattedPhone');
    print('Password length: ${password.length}');
    print('Request URL: $baseUrl/auth/login');
    
    final requestBody = {
      'phone': formattedPhone,
      'password': password,
    };
    print('Request body: $requestBody');
    
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(requestBody),
    ).timeout(timeoutDuration);
    
    print('Response Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    print('=== LOGIN DEBUG END ===');
    
    if (response.statusCode == 200) {
      final responseData = _parseResponse(response.body);
      print('Parsed response data: $responseData');
      
      return {
        'success': true,
        'data': responseData,
        'message': 'Login successful'
      };
    } else if (response.statusCode == 401) {
      final errorData = _parseErrorResponse(response.body);
      print('401 Error data: $errorData');
      
      return {
        'success': false,
        'message': 'Invalid phone number or password',
        'error': 'invalid_credentials',
        'details': errorData
      };
    } else if (response.statusCode == 404) {
      final errorData = _parseErrorResponse(response.body);
      print('404 Error data: $errorData');
      
      return {
        'success': false,
        'message': 'No account found with this phone number',
        'error': 'user_not_found',
        'details': errorData
      };
    } else if (response.statusCode == 422) {
      final errorData = _parseErrorResponse(response.body);
      print('422 Validation Error data: $errorData');
      
      return {
        'success': false,
        'message': 'Invalid input data. Please check your phone number and password.',
        'error': 'validation_error',
        'details': errorData
      };
    } else if (response.statusCode == 500) {
      final errorData = _parseErrorResponse(response.body);
      print('500 Server Error data: $errorData');
      
      return {
        'success': false,
        'message': 'Server error occurred. Please try again later.',
        'error': 'server_error',
        'details': errorData
      };
    } else {
      final errorData = _parseErrorResponse(response.body);
      print('Other Error (${response.statusCode}): $errorData');
      
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
        'error': 'login_failed',
        'statusCode': response.statusCode,
        'details': errorData
      };
    }
  } on TimeoutException {
    print('Login request timed out');
    return {
      'success': false,
      'message': 'Request timed out. Please check your internet connection.',
      'error': 'timeout'
    };
  } on http.ClientException catch (e) {
    print('Login Client Error: $e');
    return {
      'success': false,
      'message': 'Network connection error. Please check your internet connection.',
      'error': 'network_error',
      'details': e.toString()
    };
  } catch (e) {
    print('Login Unexpected Error: $e');
    print('Error type: ${e.runtimeType}');
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
    // Input validation
    if (phone.isEmpty || otp.isEmpty) {
      return {
        'success': false,
        'message': 'Phone number and OTP are required',
        'error': 'missing_fields'
      };
    }
    
    try {
      String formattedPhone = _formatPhoneNumber(phone);
      print('Verifying OTP and getting user data for phone: $formattedPhone');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone_number': formattedPhone,
          'otp_code': otp.trim(),
          'has_given_consent': true,
        }),
      ).timeout(timeoutDuration);
      
      print('Verify OTP Response Status: ${response.statusCode}');
      print('Verify OTP Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = _parseResponse(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'OTP verified successfully'
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': 'Invalid or expired OTP',
          'error': 'invalid_otp'
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'User not found',
          'error': 'user_not_found'
        };
      } else {
        final errorData = _parseErrorResponse(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'OTP verification failed',
          'error': 'verification_failed'
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please check your internet connection.',
        'error': 'timeout'
      };
    } on http.ClientException catch (e) {
      print('Verify OTP Client Error: $e');
      return {
        'success': false,
        'message': 'Network connection error. Please check your internet connection.',
        'error': 'network_error'
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
    if (userId.isEmpty) {
      return {
        'success': false,
        'message': 'User ID is required',
        'error': 'invalid_input'
      };
    }
    
    try {
      print('Updating last login for user: $userId');
      
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      // Add authorization header if token is provided
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }
      
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId/last-login'),
        headers: headers,
        body: jsonEncode({
          'last_login': DateTime.now().toIso8601String(),
        }),
      ).timeout(timeoutDuration);
      
      print('Update Last Login Response Status: ${response.statusCode}');
      print('Update Last Login Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = _parseResponse(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Last login updated successfully'
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication required',
          'error': 'unauthorized'
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'User not found',
          'error': 'user_not_found'
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
    } on http.ClientException catch (e) {
      print('Update Last Login Client Error: $e');
      return {
        'success': false,
        'message': 'Network connection error. Please check your internet connection.',
        'error': 'network_error'
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
  
  // Helper method to parse successful responses
  static Map<String, dynamic> _parseResponse(String responseBody) {
    try {
      return jsonDecode(responseBody);
    } catch (e) {
      print('Error parsing response: $e');
      return {'message': 'Invalid response format'};
    }
  }
  
  // Helper method to parse error responses
  static Map<String, dynamic> _parseErrorResponse(String responseBody) {
    try {
      final parsed = jsonDecode(responseBody);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      } else {
        return {'message': responseBody};
      }
    } catch (e) {
      print('Error parsing error response: $e');
      return {'message': responseBody.isNotEmpty ? responseBody : 'Unknown error occurred'};
    }
  }
  
  // Helper method to check if error indicates user already exists
  static bool _isUserExistsError(String errorMessage) {
    final message = errorMessage.toLowerCase();
    return message.contains('already exists') ||
           message.contains('duplicate') ||
           message.contains('user exists') ||
           message.contains('phone number already') ||
           message.contains('email already');
  }
  
  // Helper method to check if error indicates invalid credentials
  static bool _isInvalidCredentialsError(String errorMessage) {
    final message = errorMessage.toLowerCase();
    return message.contains('invalid credentials') ||
           message.contains('wrong password') ||
           message.contains('incorrect password') ||
           message.contains('authentication failed');
  }
  
  // Helper method to check if error indicates user not found
  static bool _isUserNotFoundError(String errorMessage) {
    final message = errorMessage.toLowerCase();
    return message.contains('user not found') ||
           message.contains('no user found') ||
           message.contains('account not found');
  }
}