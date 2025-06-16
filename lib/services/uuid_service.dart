// services/uuid_service.dart
// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_storage_service.dart';

class UuidService {
  // Cache for categories to avoid repeated API calls
  static Map<String, String>? _categoryCache;
  static String? _currentUserId;
  
  // API constants
  static const String baseUrl = 'https://backend2.swecha.org';
  static const String apiVersion = '/api/v1';

  /// Get current user's UUID from authentication token or API
  static Future<String?> getCurrentUserId() async {
    if (_currentUserId != null) {
      return _currentUserId;
    }

    try {
      // Option 1: Try to extract from token if it contains user info
      final token = await TokenStorageService.getAuthToken(); // Fixed: changed from getToken() to getAuthToken()

      print("uuid_service token: ${token}");
      if (token != null) {
        // If your JWT token contains user ID, decode it here
        // You can use jwt_decoder package for this:
        // final decoded = JwtDecoder.decode(token);
        // if (decoded.containsKey('user_id') || decoded.containsKey('sub')) {
        //   _currentUserId = decoded['user_id'] ?? decoded['sub'];
        //   return _currentUserId;
        // }
      }

      // Option 2: Call API to get current user info
      final response = await _getCurrentUserFromApi();
      print("_getCurrentUserFromApi ${response}");
      if (response['success']) {
        _currentUserId = response['data']['id'];
        return _currentUserId;
      }
    } catch (e) {
      print('Error getting current user ID: $e');
    }

    // Fallback: return null to indicate no user found
    // Don't return a default UUID as this can cause data issues
    return null;
  }

  /// Get all available categories with their UUIDs
  static Future<Map<String, String>> getCategories() async {
    if (_categoryCache != null) {
      return _categoryCache!;
    }

    try {
      final url = Uri.parse('$baseUrl$apiVersion/categories/');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final categories = <String, String>{};
        
        // Handle different API response formats
        List<dynamic> categoryList = [];
        if (data is List) {
          categoryList = data;
        } else if (data is Map && data.containsKey('categories')) {
          categoryList = data['categories'];
        } else if (data is Map && data.containsKey('data')) {
          categoryList = data['data'];
        }

        for (final category in categoryList) {
          if (category is Map && category.containsKey('name') && category.containsKey('id')) {
            categories[category['name']] = category['id'];
          }
        }

        if (categories.isNotEmpty) {
          _categoryCache = categories;
          return categories;
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }

    // Fallback: return default categories (these should match your backend)
    final fallbackCategories = {
  'Fables': '379d6867-57c1-4f57-b6ee-fb734313e538',
  'Events': '7a184c41-1a49-4beb-a01a-d8dc01693b15',
  'Music': '94979e9f-4895-4cd7-8601-ad53d8099bf4',
  'Places': '96e5104f-c786-4928-b932-f59f5b4ddbf0',
  'Food': '833299f6-ff1c-4fde-804f-6d3b3877c76e',
  'People': 'af8b7a27-00b4-4192-9fa6-90152a0640b2',
  'Literature': '74b133e7-e496-4e9d-85b0-3bd5eb4c3871',
  'Architecture': '94a13c20-8a03-45da-8829-10e2fe1e61a1',
  'Skills': '6f6f5023-a99e-4a29-a44a-6d5acbf88085',
  'Images': '4366cab1-031e-4b37-816b-311ee34461a9',
  'Culture': 'ab9fa2ce-1f83-4e91-b89d-cca18e8b301e',
  'Flora & Fauna': '5f40610f-ae47-4472-944c-cb899128ebbf',
  'Education': '784ddb92-9540-4ce1-b4e4-6c1b7b18849d',
  'Vegetation': '2f831ae2-f0cd-4142-8646-68dd195dfba2',
  'Dance': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
};
    
    _categoryCache = fallbackCategories;
    return fallbackCategories;
  }

  /// Get category UUID by name
  static Future<String> getCategoryUuid(String? categoryName) async {
    print("category name: ${categoryName}");
    if (categoryName == null || categoryName.isEmpty) {
      categoryName = 'General';
    }

    final categories = await getCategories();
    print("category: $categories");

    return categories[categoryName.toLowerCase()] ?? categories['general'] ?? '660e8400-e29b-41d4-a716-446655440004';
  }

  /// Get category name by UUID
  static Future<String?> getCategoryName(String categoryUuid) async {
    final categories = await getCategories();
    for (final entry in categories.entries) {
      if (entry.value == categoryUuid) {
        return entry.key;
      }
    }
    return null;
  }

  /// Get all category names
  static Future<List<String>> getCategoryNames() async {
    final categories = await getCategories();
    return categories.keys.toList();
  }

  /// Validate if a string is a valid UUID format
  static bool isValidUuid(String uuid) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    );
    return uuidRegex.hasMatch(uuid);
  }

  /// Check if user is authenticated and has valid UUID
  static Future<bool> isUserAuthenticated() async {
    final userId = await getCurrentUserId();
    return userId != null && isValidUuid(userId);
  }

  /// Refresh user data from API
  static Future<bool> refreshUserData() async {
    _currentUserId = null; // Clear cache
    final userId = await getCurrentUserId();
    return userId != null;
  }

  /// Refresh categories from API
  static Future<bool> refreshCategories() async {
    _categoryCache = null; // Clear cache
    final categories = await getCategories();
    return categories.isNotEmpty;
  }

  /// Clear cached data (call this when user logs out)
  static void clearCache() {
    _categoryCache = null;
    _currentUserId = null;
  }

  /// Get headers for API requests
  static Future<Map<String, String>> _getHeaders() async {
    final authHeader = await TokenStorageService.getAuthorizationHeader();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
    }
    
    return headers;
  }

  /// Private method to get current user from API
  static Future<Map<String, dynamic>> _getCurrentUserFromApi() async {
    try {
      final url = Uri.parse('$baseUrl$apiVersion/auth/me');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      print('Get current user response: ${response.statusCode}, ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get user info: ${response.statusCode}',
          'message': response.body,
        };
      }
    } catch (e) {
      print('Error getting current user from API: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Initialize service (call this when app starts)
  static Future<bool> initialize() async {
    try {
      // Pre-load user data and categories
      await Future.wait([
        getCurrentUserId(),
        getCategories(),
      ]);
      return true;
    } catch (e) {
      print('Error initializing UuidService: $e');
      return false;
    }
  }
}