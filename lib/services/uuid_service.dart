// services/uuid_service.dart
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
      'General': '660e8400-e29b-41d4-a716-446655440004',
      'Fables': '660e8400-e29b-41d4-a716-446655440001',
      'Stories': '660e8400-e29b-41d4-a716-446655440002',
      'Poetry': '660e8400-e29b-41d4-a716-446655440003',
      'Education': '660e8400-e29b-41d4-a716-446655440005',
      'News': '660e8400-e29b-41d4-a716-446655440006',
    };
    
    _categoryCache = fallbackCategories;
    return fallbackCategories;
  }

  /// Get category UUID by name
  static Future<String> getCategoryUuid(String? categoryName) async {
    if (categoryName == null || categoryName.isEmpty) {
      categoryName = 'General';
    }

    final categories = await getCategories();
    return categories[categoryName] ?? categories['General'] ?? '660e8400-e29b-41d4-a716-446655440004';
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
      final url = Uri.parse('$baseUrl$apiVersion/users/me');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      print('Get current user response: ${response.statusCode}'); // Debug log

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