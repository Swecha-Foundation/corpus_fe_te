import 'package:flutter/material.dart';

// UI Constants
const kPrimaryColor = Color.fromARGB(255, 190, 94, 255);
const kPrimaryLightColor = Color(0xFFF1E6FF);

const double defaultPadding = 16.0;


class ApiConstants {
  
  static const String baseUrl = 'https://backend2.swecha.org/api/v1';
  
  // API Endpoints
  static const String categoriesEndpoint = '/categories/';
  
  
  static const String usersEndpoint = '/users/';
  static const String recordingsEndpoint = '/recordings/';
  static const String authEndpoint = '/auth/';
  
  // Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // API Version
  static const String apiVersion = 'v1';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Status codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;
}

// App Configuration Constants
class AppConfig {
  // Debug settings
  static const bool enableApiLogging = true;
  static const bool enableDebugPrint = true;
  
  // Cache settings
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100;
  
  // UI settings
  static const int gridColumns = 3;
  static const double gridAspectRatio = 0.9;
  static const int maxRetryAttempts = 3;
}

// Error Messages
class ErrorMessages {
  static const String networkError = 'Network connection failed. Please check your internet connection.';
  static const String serverError = 'Server error occurred. Please try again later.';
  static const String timeoutError = 'Request timeout. Please try again.';
  static const String authenticationError = 'Authentication required. Please login again.';
  static const String notFoundError = 'Requested resource not found.';
  static const String unknownError = 'An unexpected error occurred.';
  static const String noDataError = 'No data available.';
  static const String parseError = 'Failed to process server response.';
}