// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class OTPApiService {
  static const String baseUrl = 'https://backend2.swecha.org/api/v1/auth';
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  // Rate limiting variables
  static DateTime? _lastOTPRequestTime;
  static const int _minIntervalSeconds = 30; // 30 seconds between OTP requests
  
  // Check if enough time has passed since last OTP request
  static bool _canSendOTP() {
    if (_lastOTPRequestTime == null) return true;
    
    final now = DateTime.now();
    final timeDifference = now.difference(_lastOTPRequestTime!).inSeconds;
    return timeDifference >= _minIntervalSeconds;
  }
  
  static int _getSecondsUntilNextOTP() {
    if (_lastOTPRequestTime == null) return 0;
    
    final now = DateTime.now();
    final secondsSinceLastRequest = now.difference(_lastOTPRequestTime!).inSeconds;
    return (_minIntervalSeconds - secondsSinceLastRequest).clamp(0, _minIntervalSeconds);
  }
  
  // Send OTP with improved rate limiting and error handling
  static Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    // Client-side rate limiting check
    if (!_canSendOTP()) {
      int secondsLeft = _getSecondsUntilNextOTP();
      return {
        'success': false,
        'message': 'Please wait $secondsLeft seconds before requesting another OTP',
        'error': 'rate_limit_client_side',
        'waitTime': secondsLeft
      };
    }
    
    try {
      print('Sending OTP to: $phoneNumber');
      
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      ).timeout(timeoutDuration);
      
      print('Send OTP Response Status: ${response.statusCode}');
      print('Send OTP Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _lastOTPRequestTime = DateTime.now(); // Update timestamp on success
        final responseData = _parseResponse(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'OTP sent successfully'
        };
      } else if (response.statusCode == 429) {
        // Server-side rate limiting
        final errorData = _parseResponse(response.body);
        return {
          'success': false,
          'message': 'Too many requests. Please wait before trying again.',
          'error': 'rate_limit_server_side',
          'details': errorData
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'User not found. Please sign up first.',
          'error': 'user_not_found'
        };
      } else {
        final errorData = _parseResponse(response.body);
        String errorMessage = errorData['message'] ?? 'Failed to send OTP';
        
        // Check if error indicates user doesn't exist
        if (_isUserNotFoundError(errorMessage)) {
          return {
            'success': false,
            'message': 'User not found. Please sign up first.',
            'error': 'user_not_found'
          };
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
        'message': 'Request timed out. Please check your internet connection and try again.',
        'error': 'timeout'
      };
    } catch (e) {
      print('Send OTP Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString()
      };
    }
  }
  
  // Verify OTP with improved error handling
  static Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otpCode) async {
    try {
      print('Verifying OTP for: $phoneNumber with code: $otpCode');
      
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'otp_code': otpCode,
          'has_given_consent': true,
        }),
      ).timeout(timeoutDuration);
      
      print('Verify OTP Response Status: ${response.statusCode}');
      print('Verify OTP Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = _parseResponse(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'OTP verified successfully'
        };
      } else if (response.statusCode == 400) {
        final errorData = _parseResponse(response.body);
        String errorMessage = errorData['message'] ?? 'Invalid OTP';
        
        if (_isInvalidOTPError(errorMessage)) {
          errorMessage = 'Invalid or expired OTP. Please try again.';
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'error': errorData
        };
      } else {
        final errorData = _parseResponse(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'OTP verification failed',
          'error': errorData
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please check your internet connection and try again.',
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
  
  // Resend OTP with improved rate limiting
  static Future<Map<String, dynamic>> resendOTP(String phoneNumber) async {
    // Use the same rate limiting as sendOTP
    if (!_canSendOTP()) {
      int secondsLeft = _getSecondsUntilNextOTP();
      return {
        'success': false,
        'message': 'Please wait $secondsLeft seconds before requesting another OTP',
        'error': 'rate_limit_client_side',
        'waitTime': secondsLeft
      };
    }
    
    try {
      print('Resending OTP to: $phoneNumber');
      
      final response = await http.post(
        Uri.parse('$baseUrl/resend-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      ).timeout(timeoutDuration);
      
      print('Resend OTP Response Status: ${response.statusCode}');
      print('Resend OTP Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _lastOTPRequestTime = DateTime.now(); // Update timestamp on success
        final responseData = _parseResponse(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'OTP resent successfully'
        };
      } else if (response.statusCode == 429) {
        final errorData = _parseResponse(response.body);
        return {
          'success': false,
          'message': 'Too many requests. Please wait before trying again.',
          'error': 'rate_limit_server_side',
          'details': errorData
        };
      } else {
        final errorData = _parseResponse(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to resend OTP',
          'error': errorData
        };
      }
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Please check your internet connection and try again.',
        'error': 'timeout'
      };
    } catch (e) {
      print('Resend OTP Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString()
      };
    }
  }
  
  // Get remaining wait time for next OTP request
  static int getRemainingWaitTime() {
    return _getSecondsUntilNextOTP();
  }
  
  // Check if OTP can be sent now
  static bool canSendOTPNow() {
    return _canSendOTP();
  }
  
  // Helper method to safely parse JSON responses
  static Map<String, dynamic> _parseResponse(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'message': 'Unexpected response format', 'raw': decoded};
    } catch (e) {
      return {'message': 'Failed to parse response', 'raw': responseBody};
    }
  }
  
  // Helper method to check if error indicates user not found
  static bool _isUserNotFoundError(String errorMessage) {
    final message = errorMessage.toLowerCase();
    return message.contains('user not found') || 
           message.contains('does not exist') ||
           message.contains('user does not exist') ||
           message.contains('no user found') ||
           message.contains('user not registered');
  }
  
  // Helper method to check if error indicates invalid OTP
  static bool _isInvalidOTPError(String errorMessage) {
    final message = errorMessage.toLowerCase();
    return message.contains('invalid otp') ||
           message.contains('incorrect otp') ||
           message.contains('expired otp') ||
           message.contains('otp expired') ||
           message.contains('wrong otp');
  }
}