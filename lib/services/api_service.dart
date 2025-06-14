// services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  static const String baseUrl = 'https://backend2.swecha.org'; // Replace with your actual API URL
  static const String apiVersion = '/api/v1';
  
  // Headers for API requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    // Add authorization header if needed
    // 'Authorization': 'Bearer $token',
  };

  // Create a new record
  static Future<Map<String, dynamic>> createRecord({
    required String title,
    required String description,
    required String categoryId,
    required String userId,
    required String mediaType,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$apiVersion/records/');
      
      final body = {
        'title': title,
        'description': description,
        'category_id': categoryId,
        'user_id': userId,
        'media_type': mediaType,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
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
      final url = Uri.parse('$baseUrl$apiVersion/records/upload');
      
      var request = http.MultipartRequest('POST', url);
      
      // Add headers (excluding Content-Type as it's set automatically for multipart)
      request.headers.addAll({
        'Accept': 'application/json',
        // Add authorization header if needed
        // 'Authorization': 'Bearer $token',
      });

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

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

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

      final response = await http.get(url, headers: _headers);

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
      final response = await http.get(url, headers: _headers);

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
      final url = Uri.parse('$baseUrl$apiVersion/records/$recordId');
      
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (categoryId != null) body['category_id'] = categoryId;
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;

      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

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
      final url = Uri.parse('$baseUrl$apiVersion/records/$recordId');
      final response = await http.delete(url, headers: _headers);

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
      return {
        'success': false,
        'error': 'Network error: $e',
        'message': 'Please check your internet connection'
      };
    }
  }

  // Search records nearby (if location-based search is needed)
  static Future<Map<String, dynamic>> searchRecordsNearby({
    required double latitude,
    required double longitude,
    double? radius,
  }) async {
    try {
      final queryParams = <String, String>{
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };
      
      if (radius != null) queryParams['radius'] = radius.toString();

      final url = Uri.parse('$baseUrl$apiVersion/records/search/nearby').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
          'message': 'Nearby records retrieved successfully'
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to search nearby records: ${response.statusCode}',
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
}