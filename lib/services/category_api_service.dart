// api_helper.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_storage_service.dart';

class ApiHelper {
  static const String baseUrl = 'https://backend2.swecha.org/api/v1';
  
  // Get all categories
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final authHeader = await TokenStorageService.getAuthorizationHeader();
      
      if (authHeader == null) {
        return {
          'success': false,
          'message': 'No authentication token found. Please login again.',
          'error': 'unauthorized',
        };
      }
      
      print('Fetching categories from API...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/categories/'),
        headers: {
          'accept': 'application/json',
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );
      
      print('Categories API Response Status: ${response.statusCode}');
      print('Categories API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> categoriesData = json.decode(response.body);
        return {
          'success': true,
          'data': categoriesData,
          'message': 'Categories fetched successfully',
        };
      } else {
        return _handleResponse(response);
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return {
        'success': false,
        'message': 'Network error occurred while fetching categories',
        'error': 'network_error',
      };
    }
  }
  
  // Generic authenticated GET request
  static Future<Map<String, dynamic>> authenticatedGet(String endpoint) async {
    try {
      final authHeader = await TokenStorageService.getAuthorizationHeader();
      
      if (authHeader == null) {
        return {
          'success': false,
          'message': 'No authentication token found. Please login again.',
          'error': 'unauthorized',
        };
      }
      
      print('Making authenticated GET request to: $endpoint');
      
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'accept': 'application/json',
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );
      
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('Error making authenticated GET request: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': 'network_error',
      };
    }
  }
  
  // Generic authenticated POST request
  static Future<Map<String, dynamic>> authenticatedPost(
    String endpoint, 
    Map<String, dynamic> body
  ) async {
    try {
      final authHeader = await TokenStorageService.getAuthorizationHeader();
      
      if (authHeader == null) {
        return {
          'success': false,
          'message': 'No authentication token found. Please login again.',
          'error': 'unauthorized',
        };
      }
      
      print('Making authenticated POST request to: $endpoint');
      
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'accept': 'application/json',
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('Error making authenticated POST request: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': 'network_error',
      };
    }
  }
  
  // Generic authenticated PUT request
  static Future<Map<String, dynamic>> authenticatedPut(
    String endpoint, 
    Map<String, dynamic> body
  ) async {
    try {
      final authHeader = await TokenStorageService.getAuthorizationHeader();
      
      if (authHeader == null) {
        return {
          'success': false,
          'message': 'No authentication token found. Please login again.',
          'error': 'unauthorized',
        };
      }
      
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'accept': 'application/json',
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      
      return _handleResponse(response);
    } catch (e) {
      print('Error making authenticated PUT request: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': 'network_error',
      };
    }
  }
  
  // Generic authenticated DELETE request
  static Future<Map<String, dynamic>> authenticatedDelete(String endpoint) async {
    try {
      final authHeader = await TokenStorageService.getAuthorizationHeader();
      
      if (authHeader == null) {
        return {
          'success': false,
          'message': 'No authentication token found. Please login again.',
          'error': 'unauthorized',
        };
      }
      
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'accept': 'application/json',
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );
      
      return _handleResponse(response);
    } catch (e) {
      print('Error making authenticated DELETE request: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': 'network_error',
      };
    }
  }
  
  // Handle common response patterns
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return {
        'success': true,
        'data': responseData,
        'message': 'Request successful',
      };
    } else if (response.statusCode == 401) {
      return {
        'success': false,
        'message': 'Session expired. Please login again.',
        'error': 'token_expired',
      };
    } else if (response.statusCode == 403) {
      return {
        'success': false,
        'message': 'Access forbidden. Insufficient permissions.',
        'error': 'forbidden',
      };
    } else if (response.statusCode == 404) {
      return {
        'success': false,
        'message': 'Resource not found',
        'error': 'not_found',
      };
    } else {
      try {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Request failed',
          'error': 'api_error',
        };
      } catch (e) {
        return {
          'success': false,
          'message': 'Request failed with status ${response.statusCode}',
          'error': 'api_error',
        };
      }
    }
  }
  
  // Check if user is authenticated before making requests
  static Future<bool> isUserAuthenticated() async {
    return await TokenStorageService.isAuthenticated();
  }
  
  // Get current user data
  static Future<Map<String, String?>> getCurrentUserData() async {
    return await TokenStorageService.getUserData();
  }
}