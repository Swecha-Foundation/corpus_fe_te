import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class OTPApiService {
  static const String baseUrl = 'https://backend2.swecha.org/api/v1/auth';
  
  // Rate limiting variables
  static DateTime? _lastSendOTPTime;
  static DateTime? _lastResendOTPTime;
  static const int _minIntervalSeconds = 30; // 1 minute between OTP requests
  
  // Check if enough time has passed since last OTP request
  static bool _canSendOTP() {
    if (_lastSendOTPTime == null) return true;
    
    final now = DateTime.now();
    final timeDifference = now.difference(_lastSendOTPTime!).inSeconds;
    return timeDifference >= _minIntervalSeconds;
  }
  
  static bool _canResendOTP() {
    if (_lastResendOTPTime == null) return true;
    
    final now = DateTime.now();
    final timeDifference = now.difference(_lastResendOTPTime!).inSeconds;
    return timeDifference >= _minIntervalSeconds;
  }
  
  static int _getSecondsUntilNextOTP() {
    if (_lastSendOTPTime == null && _lastResendOTPTime == null) return 0;
    
    final now = DateTime.now();
    int secondsSinceLastSend = _lastSendOTPTime != null 
        ? now.difference(_lastSendOTPTime!).inSeconds 
        : _minIntervalSeconds;
    int secondsSinceLastResend = _lastResendOTPTime != null 
        ? now.difference(_lastResendOTPTime!).inSeconds 
        : _minIntervalSeconds;
    
    int secondsSinceLastRequest = [secondsSinceLastSend, secondsSinceLastResend].reduce((a, b) => a < b ? a : b);
    
    return _minIntervalSeconds - secondsSinceLastRequest;
  }
  
  // Send OTP with rate limiting
  static Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    // Check rate limiting
    if (!_canSendOTP()) {
      int secondsLeft = _getSecondsUntilNextOTP();
      return {
        'success': false,
        'message': 'Please wait ${secondsLeft} seconds before requesting another OTP',
        'error': 'rate_limit_client_side'
      };
    }
    
    try {
      print('Sending OTP to: $phoneNumber'); // Debug log
      
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );
      
      print('Send OTP Response Status: ${response.statusCode}'); // Debug log
      print('Send OTP Response Body: ${response.body}'); // Debug log
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _lastSendOTPTime = DateTime.now(); // Update timestamp on success
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'OTP sent successfully'
        };
      } else if (response.statusCode == 429) {
        // Rate limit exceeded from server
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': 'Too many requests. Please wait before trying again.',
          'error': 'rate_limit_server_side'
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? errorData['message'] ?? 'Failed to send OTP',
          'error': errorData
        };
      }
    } catch (e) {
      print('Send OTP Error: $e'); // Debug log
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': e.toString()
      };
    }
  }
  
  // Verify OTP - Updated to match API documentation
  static Future<Map<String, dynamic>> verifyOTP(String phoneNumber, String otpCode) async {
    try {
      print('Verifying OTP for: $phoneNumber with code: $otpCode'); // Debug log
      
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'otp_code': otpCode, // Changed from 'otp' to 'otp_code'
          'has_given_consent': true, // Added missing consent field
        }),
      );
      
      print('Verify OTP Response Status: ${response.statusCode}'); // Debug log
      print('Verify OTP Response Body: ${response.body}'); // Debug log
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'OTP verified successfully'
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? errorData['message'] ?? 'Invalid OTP',
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
  
  // Resend OTP with rate limiting
  static Future<Map<String, dynamic>> resendOTP(String phoneNumber) async {
    // Check rate limiting
    if (!_canResendOTP()) {
      int secondsLeft = _getSecondsUntilNextOTP();
      return {
        'success': false,
        'message': 'Please wait ${secondsLeft} seconds before requesting another OTP',
        'error': 'rate_limit_client_side'
      };
    }
    
    try {
      print('Resending OTP to: $phoneNumber'); // Debug log
      
      final response = await http.post(
        Uri.parse('$baseUrl/resend-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      );
      
      print('Resend OTP Response Status: ${response.statusCode}'); // Debug log
      print('Resend OTP Response Body: ${response.body}'); // Debug log
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _lastResendOTPTime = DateTime.now(); // Update timestamp on success
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'OTP resent successfully'
        };
      } else if (response.statusCode == 429) {
        // Rate limit exceeded from server
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': 'Too many requests. Please wait before trying again.',
          'error': 'rate_limit_server_side'
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['detail'] ?? errorData['message'] ?? 'Failed to resend OTP',
          'error': errorData
        };
      }
    } catch (e) {
      print('Resend OTP Error: $e'); // Debug log
      return {
        'success': false,
        'message': 'Network error: $e',
        'error': e.toString()
      };
    }
  }
}