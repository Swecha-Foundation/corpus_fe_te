// // api_service.dart
// // ignore_for_file: avoid_print

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'token_storage_service.dart';

// class ApiService {
//   static const String baseUrl = 'https://backend2.swecha.org/api/v1';
//   static const Duration timeoutDuration = Duration(seconds: 30);

//   // Get headers with authentication
//   static Future<Map<String, String>> _getAuthHeaders({
//     Map<String, String>? additionalHeaders,
//   }) async {
//     Map<String, String> headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };

//     // Add stored authorization header if available
//     final authHeader = await TokenStorageService.getAuthorizationHeader();
//     if (authHeader != null) {
//       headers['Authorization'] = authHeader;
//       print('Added Authorization header: ${authHeader.substring(0, 20)}...');
//     }

//     // Add any additional headers
//     if (additionalHeaders != null) {
//       headers.addAll(additionalHeaders);
//     }

//     return headers;
//   }

//   // Generic GET request with authentication
//   static Future<Map<String, dynamic>> get(String endpoint) async {
//     try {
//       final headers = await _getAuthHeaders();
//       final url = Uri.parse('$baseUrl$endpoint');

//       print('GET Request to: $url');
//       print('Headers: $headers');

//       final response =
//           await http.get(url, headers: headers).timeout(timeoutDuration);

//       print('Response Status: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       return _handleResponse(response);
//     } catch (e) {
//       print('GET Request Error: $e');
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//         'error': e.toString()
//       };
//     }
//   }

//   // Generic POST request with authentication
//   static Future<Map<String, dynamic>> post(
//       String endpoint, Map<String, dynamic> body) async {
//     try {
//       final headers = await _getAuthHeaders();
//       final url = Uri.parse('$baseUrl$endpoint');

//       print('POST Request to: $url');
//       print('Headers: $headers');
//       print('Body: ${jsonEncode(body)}');

//       final response = await http
//           .post(
//             url,
//             headers: headers,
//             body: jsonEncode(body),
//           )
//           .timeout(timeoutDuration);

//       print('Response Status: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       return _handleResponse(response);
//     } catch (e) {
//       print('POST Request Error: $e');
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//         'error': e.toString()
//       };
//     }
//   }

//   // Generic PUT request with authentication
//   static Future<Map<String, dynamic>> put(
//       String endpoint, Map<String, dynamic> body) async {
//     try {
//       final headers = await _getAuthHeaders();
//       final url = Uri.parse('$baseUrl$endpoint');

//       print('PUT Request to: $url');
//       print('Headers: $headers');
//       print('Body: ${jsonEncode(body)}');

//       final response = await http
//           .put(
//             url,
//             headers: headers,
//             body: jsonEncode(body),
//           )
//           .timeout(timeoutDuration);

//       print('Response Status: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       return _handleResponse(response);
//     } catch (e) {
//       print('PUT Request Error: $e');
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//         'error': e.toString()
//       };
//     }
//   }

//   // Generic DELETE request with authentication
//   static Future<Map<String, dynamic>> delete(String endpoint) async {
//     try {
//       final headers = await _getAuthHeaders();
//       final url = Uri.parse('$baseUrl$endpoint');

//       print('DELETE Request to: $url');
//       print('Headers: $headers');

//       final response =
//           await http.delete(url, headers: headers).timeout(timeoutDuration);

//       print('Response Status: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       return _handleResponse(response);
//     } catch (e) {
//       print('DELETE Request Error: $e');
//       return {
//         'success': false,
//         'message': 'Network error: ${e.toString()}',
//         'error': e.toString()
//       };
//     }
//   }

//   // Handle HTTP response
//   static Map<String, dynamic> _handleResponse(http.Response response) {
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       try {
//         final responseData = jsonDecode(response.body);
//         return {
//           'success': true,
//           'data': responseData,
//           'message': 'Request successful',
//         };
//       } catch (e) {
//         return {
//           'success': true,
//           'data': response.body,
//           'message': 'Request successful',
//         };
//       }
//     } else if (response.statusCode == 401) {
//       return {
//         'success': false,
//         'message': 'Authentication required. Please login again.',
//         'error': 'unauthorized',
//         'statusCode': response.statusCode,
//       };
//     } else if (response.statusCode == 403) {
//       return {
//         'success': false,
//         'message': 'Access forbidden. You don\'t have permission.',
//         'error': 'forbidden',
//         'statusCode': response.statusCode,
//       };
//     } else {
//       try {
//         final errorData = jsonDecode(response.body);
//         return {
//           'success': false,
//           'message':
//               errorData['message'] ?? errorData['detail'] ?? 'Request failed',
//           'error': errorData,
//           'statusCode': response.statusCode,
//         };
//       } catch (e) {
//         return {
//           'success': false,
//           'message': 'Request failed with status ${response.statusCode}',
//           'error': response.body,
//           'statusCode': response.statusCode,
//         };
//       }
//     }
//   }

//   // Check if user is authenticated and token is valid
//   static Future<bool> isAuthenticated() async {
//     return await TokenStorageService.isAuthenticated();
//   }

//   // Logout user (clear stored data)
//   static Future<bool> logout() async {
//     return await TokenStorageService.clearAuthData();
//   }

//   // Get current user data
//   static Future<Map<String, String?>> getCurrentUser() async {
//     return await TokenStorageService.getUserData();
//   }

//   // Test API connection with authentication
//   static Future<Map<String, dynamic>> testConnection() async {
//     try {
//       final result = await get('/test'); // Adjust endpoint as needed
//       return result;
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Connection test failed: ${e.toString()}',
//         'error': e.toString()
//       };
//     }
//   }

// // Add this method to your ApiService class
//   static Future<Map<String, dynamic>> _makeAuthenticatedRequest(
//       Future<http.Response> Function() requestFunction) async {
//     // Check if token will expire soon
//     if (await TokenStorageService.willTokenExpireSoon()) {
//       print('Token expiring soon, user needs to re-authenticate');
//       await TokenStorageService.clearAuthData();
//       return {
//         'success': false,
//         'message': 'Session expired. Please login again.',
//         'error': 'token_expired'
//       };
//     }

//     final response = await requestFunction();

//     // Handle token expiry in response
//     if (response.statusCode == 401) {
//       await TokenStorageService.clearAuthData();
//       return {
//         'success': false,
//         'message': 'Session expired. Please login again.',
//         'error': 'unauthorized'
//       };
//     }

//     return _handleResponse(response);
//   }

//   // Copy token to clipboard for manual testing
//   static Future<String?> getTokenForTesting() async {
//     final token = await TokenStorageService.getAuthToken();
//     if (token != null) {
//       print('Token for API testing:');
//       print(token);
//       print('\nCopy this token to the Authorization field in Swagger UI');
//       print('Format: Bearer $token');
//     }
//     return token;
//   }
// }

// api_service.dart

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage_service.dart';

class ApiService {
  static const String baseUrl = 'https://backend2.swecha.org/api/v1';
  static const Duration timeoutDuration = Duration(seconds: 30);

  // Get headers with authentication
  static Future<Map<String, String>> _getAuthHeaders({
    Map<String, String>? additionalHeaders,
  }) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add stored authorization header if available
    final authHeader = await TokenStorageService.getAuthorizationHeader();
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
      print('Added Authorization header: ${authHeader.substring(0, 20)}...');
    }

    // Add any additional headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  // Enhanced request wrapper with automatic token expiry handling
  static Future<Map<String, dynamic>> _makeAuthenticatedRequest(
    Future<http.Response> Function() requestFunction
  ) async {
    // Check if token will expire soon (within 5 minutes)
    if (await TokenStorageService.willTokenExpireSoon()) {
      print('Token expiring soon, user needs to re-authenticate');
      await TokenStorageService.clearAuthData();
      return {
        'success': false,
        'message': 'Session expired. Please login again.',
        'error': 'token_expired',
        'requiresAuth': true,
      };
    }

    try {
      final response = await requestFunction();
      
      // Handle token expiry in response
      if (response.statusCode == 401 || response.statusCode == 403) {
        await TokenStorageService.clearAuthData();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'error': 'unauthorized',
          'requiresAuth': true,
          'statusCode': response.statusCode,
        };
      }
      
      return _handleResponse(response);
    } catch (e) {
      print('Request Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error': e.toString()
      };
    }
  }

  // Generic GET request with authentication
  static Future<Map<String, dynamic>> get(String endpoint) async {
    return await _makeAuthenticatedRequest(() async {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl$endpoint');
      print('GET Request to: $url');
      print('Headers: $headers');
      return await http.get(url, headers: headers).timeout(timeoutDuration);
    });
  }

  // Generic POST request with authentication
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    return await _makeAuthenticatedRequest(() async {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl$endpoint');
      print('POST Request to: $url');
      print('Headers: $headers');
      print('Body: ${jsonEncode(body)}');
      return await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(timeoutDuration);
    });
  }

  // Generic PUT request with authentication
  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    return await _makeAuthenticatedRequest(() async {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl$endpoint');
      print('PUT Request to: $url');
      print('Headers: $headers');
      print('Body: ${jsonEncode(body)}');
      return await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(timeoutDuration);
    });
  }

  // Generic DELETE request with authentication
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    return await _makeAuthenticatedRequest(() async {
      final headers = await _getAuthHeaders();
      final url = Uri.parse('$baseUrl$endpoint');
      print('DELETE Request to: $url');
      print('Headers: $headers');
      return await http.delete(url, headers: headers).timeout(timeoutDuration);
    });
  }

  // Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Request successful',
        };
      } catch (e) {
        return {
          'success': true,
          'data': response.body,
          'message': 'Request successful',
        };
      }
    } else if (response.statusCode == 401) {
      return {
        'success': false,
        'message': 'Authentication required. Please login again.',
        'error': 'unauthorized',
        'statusCode': response.statusCode,
        'requiresAuth': true,
      };
    } else if (response.statusCode == 403) {
      return {
        'success': false,
        'message': 'Access forbidden. You don\'t have permission.',
        'error': 'forbidden',
        'statusCode': response.statusCode,
      };
    } else {
      try {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? errorData['detail'] ?? 'Request failed',
          'error': errorData,
          'statusCode': response.statusCode,
        };
      } catch (e) {
        return {
          'success': false,
          'message': 'Request failed with status ${response.statusCode}',
          'error': response.body,
          'statusCode': response.statusCode,
        };
      }
    }
  }

  // Check if user is authenticated and token is valid
  static Future<bool> isAuthenticated() async {
    return await TokenStorageService.isAuthenticated();
  }

  // Logout user (clear stored data)
  static Future<bool> logout() async {
    return await TokenStorageService.clearAuthData();
  }

  // Get current user data
  static Future<Map<String, dynamic>> getCurrentUser() async {
    return await TokenStorageService.getUserData();
  }

  // Test API connection with authentication
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      final result = await get('/test'); // Adjust endpoint as needed
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection test failed: ${e.toString()}',
        'error': e.toString()
      };
    }
  }

  // Copy token to clipboard for manual testing
  static Future<String?> getTokenForTesting() async {
    final token = await TokenStorageService.getAuthToken();
    if (token != null) {
      print('Token for API testing:');
      print(token);
      print('\nCopy this token to the Authorization field in Swagger UI');
      print('Format: Bearer $token');
    }
    return token;
  }
}
