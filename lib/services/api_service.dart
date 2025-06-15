// services/api_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
// ignore: depend_on_referenced_packages
import 'package:mime/mime.dart';
import 'token_storage_service.dart'; 
import 'uuid_service.dart';

class ApiService {
  static const String baseUrl = 'https://backend2.swecha.org';
  static const String apiVersion = '/api/v1';
  
  // Headers for API requests with authentication (made public)
  static Future<Map<String, String>> getHeaders() async {
    final authHeader = await TokenStorageService.getAuthorizationHeader();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
      print('Using auth header: ${authHeader.substring(0, 20)}...'); // Debug log
    } else {
      print('Warning: No auth token available');
    }
    
    return headers;
  }

  // Private method for backward compatibility
  static Future<Map<String, String>> _getHeaders() async {
    return await getHeaders();
  }

  // Headers for multipart requests (without Content-Type)
  static Future<Map<String, String>> _getMultipartHeaders() async {
    final authHeader = await TokenStorageService.getAuthorizationHeader();
    final headers = {
      'Accept': 'application/json',
    };
    
    if (authHeader != null) {
      headers['Authorization'] = authHeader;
    }
    
    return headers;
  }

  // Create a new record with proper schema
  static Future<Map<String, dynamic>> createRecord({
    required String title,
    required String description,
    required String categoryId,
    required String userId,
    required String mediaType,
    double? latitude,
    double? longitude,
    String? fileName,
    int? fileSize,
  }) async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await TokenStorageService.isAuthenticated();
      if (!isAuthenticated) {
        return {
          'success': false,
          'error': 'User not authenticated',
          'message': 'Please login again'
        };
      }

      final url = Uri.parse('$baseUrl$apiVersion/records/');
      final headers = await _getHeaders();
      
      final body = <String, dynamic>{
        'title': title,
        'description': description,
        'media_type': mediaType,
        'file_url': '', // Will be updated after upload
        'file_name': fileName ?? '',
        'file_size': fileSize ?? 0,
        'status': 'pending',
        'reviewed': false,
        'user_id': userId,
        'category_id': categoryId,
      };

      // Add location as nested object if coordinates are provided
      if (latitude != null && longitude != null) {
        body['location'] = {
          'latitude': latitude,
          'longitude': longitude,
        };
      }

      print('Creating record with body: ${jsonEncode(body)}'); // Debug log

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('Create record response: ${response.statusCode} - ${response.body}'); // Debug log

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'Record created successfully'
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to create record: ${response.statusCode}',
          'message': response.body
        };
      }
    } catch (e) {
      print('Create record error: $e'); // Debug log
      return {
        'success': false,
        'error': 'Network error: $e',
        'message': 'Please check your internet connection'
      };
    }
  }

  // Upload file for a record
  static Future<Map<String, dynamic>> uploadRecord({
    required String recordId,
    required File file,
    String? description,
  }) async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await TokenStorageService.isAuthenticated();
      if (!isAuthenticated) {
        return {
          'success': false,
          'error': 'User not authenticated',
          'message': 'Please login again'
        };
      }

      final url = Uri.parse('$baseUrl$apiVersion/records/upload');
      
      var request = http.MultipartRequest('POST', url);
      
      // Add headers (excluding Content-Type as it's set automatically for multipart)
      final headers = await _getMultipartHeaders();
      request.headers.addAll(headers);

      // Add form fields
      request.fields['record_id'] = recordId;
      if (description != null) {
        request.fields['description'] = description;
      }

      // Add file
      String? mimeType = lookupMimeType(file.path);
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      );
      request.files.add(multipartFile);

      print('Uploading file for record: $recordId'); // Debug log

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Upload response: ${response.statusCode} - ${response.body}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'File uploaded successfully'
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to upload file: ${response.statusCode}',
          'message': response.body
        };
      }
    } catch (e) {
      print('Upload error: $e'); // Debug log
      return {
        'success': false,
        'error': 'Upload error: $e',
        'message': 'Failed to upload file'
      };
    }
  }

  // Get all records with optional filtering
  static Future<Map<String, dynamic>> getRecords({
    String? categoryId,
    String? userId,
    String? mediaType,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (userId != null) queryParams['user_id'] = userId;
      if (mediaType != null) queryParams['media_type'] = mediaType;

      final url = Uri.parse('$baseUrl$apiVersion/records/').replace(
        queryParameters: queryParams,
      );

      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'Records retrieved successfully'
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get records: ${response.statusCode}',
          'message': response.body
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
        'message': 'Please check your internet connection'
      };
    }
  }

  // Get a specific record by ID
  static Future<Map<String, dynamic>> getRecord(String recordId) async {
    try {
      final url = Uri.parse('$baseUrl$apiVersion/records/$recordId');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'Record retrieved successfully'
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get record: ${response.statusCode}',
          'message': response.body
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
        'message': 'Please check your internet connection'
      };
    }
  }

  // Update a record
  static Future<Map<String, dynamic>> updateRecord({
    required String recordId,
    String? title,
    String? description,
    String? categoryId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await TokenStorageService.isAuthenticated();
      if (!isAuthenticated) {
        return {
          'success': false,
          'error': 'User not authenticated',
          'message': 'Please login again'
        };
      }

      final url = Uri.parse('$baseUrl$apiVersion/records/$recordId');
      final headers = await _getHeaders();
      
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (categoryId != null) body['category_id'] = categoryId;
      // Add location as nested object if coordinates are provided
      if (latitude != null && longitude != null) {
        body['location'] = {
          'latitude': latitude,
          'longitude': longitude,
        };
      }

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('Update record response: ${response.statusCode} - ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'Record updated successfully'
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to update record: ${response.statusCode}',
          'message': response.body
        };
      }
    } catch (e) {
      print('Update record error: $e'); // Debug log
      return {
        'success': false,
        'error': 'Network error: $e',
        'message': 'Please check your internet connection'
      };
    }
  }

  // Delete a record
  static Future<Map<String, dynamic>> deleteRecord(String recordId) async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await TokenStorageService.isAuthenticated();
      if (!isAuthenticated) {
        return {
          'success': false,
          'error': 'User not authenticated',
          'message': 'Please login again'
        };
      }

      final url = Uri.parse('$baseUrl$apiVersion/records/$recordId');
      final headers = await _getHeaders();
      final response = await http.delete(url, headers: headers);

      print('Delete record response: ${response.statusCode} - ${response.body}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Record deleted successfully'
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to delete record: ${response.statusCode}',
          'message': response.body
        };
      }
    } catch (e) {
      print('Delete record error: $e'); // Debug log
      return {
        'success': false,
        'error': 'Network error: $e',
        'message': 'Please check your internet connection'
      };
    }
  }

  // Get user's own records
  static Future<Map<String, dynamic>> getUserRecords({
    String? categoryId,
    String? mediaType,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      // Get current user ID from UuidService
      final userId = await UuidService.getCurrentUserId();
      if (userId == null) {
        return {
          'success': false,
          'error': 'User not authenticated',
          'message': 'Please login again'
        };
      }

      return await getRecords(
        categoryId: categoryId,
        userId: userId,
        mediaType: mediaType,
        skip: skip,
        limit: limit,
      );
    } catch (e) {
      return {
        'success': false,
        'error': 'Error getting user records: $e',
        'message': 'Failed to retrieve your records'
      };
    }
  }

  // Create record with UUID service integration
  static Future<Map<String, dynamic>> createRecordWithUuids({
    required String title,
    required String description,
    String? categoryName, // Use category name instead of ID
    required String mediaType,
    double? latitude,
    double? longitude,
    String? fileName,
    int? fileSize,
  }) async {
    try {
      // Get current user ID and category UUID
      final userId = await UuidService.getCurrentUserId();
      final categoryId = await UuidService.getCategoryUuid(categoryName);

      if (userId == null) {
        return {
          'success': false,
          'error': 'User not authenticated',
          'message': 'Please login again'
        };
      }

      return await createRecord(
        title: title,
        description: description,
        categoryId: categoryId,
        userId: userId,
        mediaType: mediaType,
        latitude: latitude,
        longitude: longitude,
        fileName: fileName,
        fileSize: fileSize,
      );
    } catch (e) {
      return {
        'success': false,
        'error': 'Error creating record: $e',
        'message': 'Failed to create record'
      };
    }
  }

  // Get categories from API (used by UuidService)
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final url = Uri.parse('$baseUrl$apiVersion/categories/');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'Categories retrieved successfully'
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get categories: ${response.statusCode}',
          'message': response.body
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
        'message': 'Please check your internet connection'
      };
    }
  }

  // Get current user info from API (used by UuidService)
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final url = Uri.parse('$baseUrl$apiVersion/users/me');
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      print('Get current user response: ${response.statusCode} - ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'User info retrieved successfully'
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get user info: ${response.statusCode}',
          'message': response.body
        };
      }
    } catch (e) {
      print('Get current user error: $e'); // Debug log
      return {
        'success': false,
        'error': 'Network error: $e',
        'message': 'Please check your internet connection'
      };
    }
  }

  // Upload file with progress callback
  static Future<Map<String, dynamic>> uploadRecordWithProgress({
    required String recordId,
    required File file,
    String? description,
    Function(double progress)? onProgress,
  }) async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await TokenStorageService.isAuthenticated();
      if (!isAuthenticated) {
        return {
          'success': false,
          'error': 'User not authenticated',
          'message': 'Please login again'
        };
      }

      final url = Uri.parse('$baseUrl$apiVersion/records/upload');
      
      var request = http.MultipartRequest('POST', url);
      
      // Add headers (excluding Content-Type as it's set automatically for multipart)
      final headers = await _getMultipartHeaders();
      request.headers.addAll(headers);

      // Add form fields
      request.fields['record_id'] = recordId;
      if (description != null) {
        request.fields['description'] = description;
      }

      // Add file
      String? mimeType = lookupMimeType(file.path);
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      );
      request.files.add(multipartFile);

      print('Uploading file for record: $recordId'); // Debug log

      var streamedResponse = await request.send();
      
      // Listen to upload progress if callback provided
      if (onProgress != null) {
        streamedResponse.stream.listen(
          (List<int> chunk) {
            // Calculate progress based on bytes sent
            // Note: This is a simplified progress calculation
            // For more accurate progress, you might need a different approach
          },
          onDone: () {
            onProgress(1.0); // Upload complete
          },
        );
      }

      var response = await http.Response.fromStream(streamedResponse);

      print('Upload response: ${response.statusCode} - ${response.body}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'File uploaded successfully'
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to upload file: ${response.statusCode}',
          'message': response.body
        };
      }
    } catch (e) {
      print('Upload error: $e'); // Debug log
      return {
        'success': false,
        'error': 'Upload error: $e',
        'message': 'Failed to upload file'
      };
    }
  }

  // Validate server connection
  static Future<bool> validateConnection() async {
    try {
      final url = Uri.parse('$baseUrl/health'); // Assuming health check endpoint
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print('Connection validation failed: $e');
      return false;
    }
  }

  // Clear all cached data
  static void clearCache() {
    UuidService.clearCache();
  }
}