// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

// Category model class
class Category {
  final String id;
  final String name;
  final String title;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, title: $title, description: $description)';
  }
}

// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String message = 'Success'}) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: 200,
    );
  }

  factory ApiResponse.error(String message, {String? error, int? statusCode}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      error: error,
      statusCode: statusCode,
    );
  }
}

class GetCategoriesApi {
  // Base URL for the API
  static const String baseUrl = 'https://backend2.swecha.org/api/v1';
  static const String categoriesEndpoint = '/categories/';
  
  // Timeout duration
  static const Duration timeoutDuration = Duration(seconds: 15);
  
  // Simple headers for public API access
  static const Map<String, String> _publicHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Flutter-App/1.0',
  };

  /// Safely extracts a list from JSON data
  static List<dynamic>? _extractListFromJson(Map<String, dynamic> jsonData) {
    // Try different possible keys for the categories list
    final possibleKeys = ['data', 'categories', 'results', 'items', 'content'];
    
    for (final key in possibleKeys) {
      if (jsonData.containsKey(key)) {
        final value = jsonData[key];
        if (value is List<dynamic>) {
          return value;
        } else if (value is Map<String, dynamic>) {
          // If it's a map, look for nested arrays
          for (final nestedKey in ['categories', 'items', 'results', 'data']) {
            if (value.containsKey(nestedKey) && value[nestedKey] is List<dynamic>) {
              return value[nestedKey] as List<dynamic>;
            }
          }
        }
      }
    }
    
    return null;
  }

  /// Fetches all categories from the public API (no authentication required)
  static Future<ApiResponse<List<Category>>> getCategories() async {
    try {
      final url = Uri.parse('$baseUrl$categoriesEndpoint');
      
      print('🌐 Fetching categories from: $url');
      print('📋 Using public access (no authentication)');
      
      final response = await http.get(
        url,
        headers: _publicHeaders,
      ).timeout(timeoutDuration);

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response content-type: ${response.headers['content-type']}');
      
      if (response.statusCode == 200) {
        return _parseSuccessResponse(response);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('🔒 Authentication required response received');
        print('📄 Response body: ${response.body}');
        
        // Try to extract specific error message
        String errorMessage = 'This API requires authentication';
        try {
          final errorData = json.decode(response.body);
          if (errorData is Map<String, dynamic>) {
            errorMessage = errorData['detail']?.toString() ?? 
                          errorData['message']?.toString() ?? 
                          errorMessage;
          }
        } catch (e) {
          // Keep default message if parsing fails
        }
        
        return ApiResponse.error(
          errorMessage,
          error: 'authentication_required',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 404) {
        print('🔍 Categories endpoint not found');
        return ApiResponse.error(
          'Categories service not available',
          error: 'endpoint_not_found',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        print('🔥 Server error: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
        return ApiResponse.error(
          'Server is temporarily unavailable',
          error: 'server_error',
          statusCode: response.statusCode,
        );
      } else {
        print('⚠️ Unexpected status code: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
        
        return ApiResponse.error(
          'Failed to load categories (HTTP ${response.statusCode})',
          error: 'http_error',
          statusCode: response.statusCode,
        );
      }
      
    } catch (error) {
      print('💥 Network/Request error: $error');
      
      String errorMessage = 'Failed to connect to server';
      String errorType = 'network_error';
      
      if (error.toString().contains('TimeoutException')) {
        errorMessage = 'Request timeout - server took too long to respond';
        errorType = 'timeout_error';
      } else if (error.toString().contains('SocketException')) {
        errorMessage = 'No internet connection available';
        errorType = 'connection_error';
      } else if (error.toString().contains('HandshakeException')) {
        errorMessage = 'SSL/TLS connection failed';
        errorType = 'ssl_error';
      } else if (error.toString().contains('FormatException')) {
        errorMessage = 'Invalid server response format';
        errorType = 'format_error';
      }
      
      return ApiResponse.error(
        errorMessage,
        error: errorType,
      );
    }
  }

  /// Parse successful response
  static ApiResponse<List<Category>> _parseSuccessResponse(http.Response response) {
    try {
      final dynamic decodedJson = json.decode(response.body);
      print('📦 Parsed response data type: ${decodedJson.runtimeType}');
      
      List<dynamic> categoriesJson;
      
      if (decodedJson is List<dynamic>) {
        // Direct array response: [...]
        categoriesJson = decodedJson;
        print('✅ Found direct array with ${categoriesJson.length} items');
      } else if (decodedJson is Map<String, dynamic>) {
        // Response is an object, try to extract the list
        final extractedList = _extractListFromJson(decodedJson);
        
        if (extractedList != null) {
          categoriesJson = extractedList;
          print('✅ Extracted array with ${categoriesJson.length} items');
        } else {
          // If no list found, check if it's a single category object
          if (decodedJson.containsKey('id') || decodedJson.containsKey('name')) {
            print('⚠️ Single category object detected');
            categoriesJson = [decodedJson];
          } else {
            print('❌ No categories data found in response');
            print('📋 Available keys: ${decodedJson.keys.toList()}');
            return ApiResponse.error(
              'No categories found in response',
              error: 'no_categories_data',
            );
          }
        }
      } else {
        print('❌ Unexpected response format: ${decodedJson.runtimeType}');
        return ApiResponse.error(
          'Invalid response format from server',
          error: 'invalid_response_format',
        );
      }
      
      final List<Category> categories = [];
      int parseErrors = 0;
      
      for (int i = 0; i < categoriesJson.length; i++) {
        final categoryData = categoriesJson[i];
        if (categoryData is Map<String, dynamic>) {
          try {
            final category = Category.fromJson(categoryData);
            categories.add(category);
          } catch (categoryParseError) {
            parseErrors++;
            print('⚠️ Failed to parse category #$i: $categoryParseError');
            print('📄 Category data: $categoryData');
          }
        } else {
          parseErrors++;
          print('⚠️ Invalid category data #$i: $categoryData');
        }
      }
      
      print('✅ Successfully parsed ${categories.length} categories');
      if (parseErrors > 0) {
        print('⚠️ Skipped $parseErrors invalid category entries');
      }
      
      if (categories.isEmpty) {
        return ApiResponse.error(
          'No valid categories found',
          error: 'no_valid_categories',
        );
      }
      
      return ApiResponse.success(
        categories,
        message: 'Categories loaded successfully',
      );
      
    } catch (parseError) {
      print('❌ JSON parsing error: $parseError');
      print('📄 Raw response body: ${response.body}');
      
      return ApiResponse.error(
        'Failed to parse server response',
        error: 'json_parse_error',
      );
    }
  }

  /// Test the API connection
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testing API connection...');
      final response = await getCategories();
      final isConnected = response.success;
      print(isConnected ? '✅ API connection successful' : '❌ API connection failed');
      return isConnected;
    } catch (error) {
      print('❌ Connection test failed: $error');
      return false;
    }
  }

  /// Get a specific category by ID (public access)
  static Future<ApiResponse<Category>> getCategoryById(String categoryId) async {
    try {
      final url = Uri.parse('$baseUrl$categoriesEndpoint$categoryId/');
      
      print('🌐 Fetching category by ID: $url');
      
      final response = await http.get(
        url,
        headers: _publicHeaders,
      ).timeout(timeoutDuration);

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final dynamic decodedJson = json.decode(response.body);
          
          Map<String, dynamic> categoryJson;
          
          if (decodedJson is Map<String, dynamic>) {
            // Handle different possible API response structures
            if (decodedJson.containsKey('data') && decodedJson['data'] is Map<String, dynamic>) {
              categoryJson = decodedJson['data'] as Map<String, dynamic>;
            } else if (decodedJson.containsKey('category') && decodedJson['category'] is Map<String, dynamic>) {
              categoryJson = decodedJson['category'] as Map<String, dynamic>;
            } else {
              categoryJson = decodedJson;
            }
          } else {
            return ApiResponse.error(
              'Invalid response format for category',
              error: 'invalid_response_format',
              statusCode: response.statusCode,
            );
          }
          
          final Category category = Category.fromJson(categoryJson);
          
          return ApiResponse.success(
            category,
            message: 'Category loaded successfully',
          );
          
        } catch (parseError) {
          return ApiResponse.error(
            'Failed to parse category data',
            error: 'json_parse_error',
            statusCode: response.statusCode,
          );
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return ApiResponse.error(
          'Authentication required for category details',
          error: 'authentication_required',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 404) {
        return ApiResponse.error(
          'Category not found',
          error: 'category_not_found',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          'Failed to load category',
          error: 'http_error',
          statusCode: response.statusCode,
        );
      }
      
    } catch (error) {
      print('💥 Error fetching category: $error');
      return ApiResponse.error(
        'Failed to connect to server',
        error: 'network_error',
      );
    }
  }

  /// Get API status info
  static String get apiInfo => 'Public API access (no authentication required)';
}