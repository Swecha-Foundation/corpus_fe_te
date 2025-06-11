// ignore_for_file: avoid_print

import 'get_categories_api.dart';

/// CategoryService class that provides a simplified interface for category operations
/// This acts as a service layer between the UI and the API
class CategoryService {
  
  /// Fetches all categories and returns them in a format expected by the UI
  /// Returns a Map with 'success', 'data', 'message', and 'error' keys
  static Future<Map<String, dynamic>> getCategories() async {
    try {
      print('🔄 CategoryService: Fetching categories...');
      
      // Call the API
      final ApiResponse<List<Category>> response = await GetCategoriesApi.getCategories();
      
      if (response.success && response.data != null) {
        print('✅ CategoryService: Successfully retrieved ${response.data!.length} categories');
        
        return {
          'success': true,
          'data': response.data!,
          'message': response.message,
          'error': null,
        };
      } else {
        print('❌ CategoryService: Failed to get categories - ${response.message}');
        
        return {
          'success': false,
          'data': <Category>[],
          'message': response.message,
          'error': response.error,
        };
      }
      
    } catch (error) {
      print('💥 CategoryService: Exception occurred - $error');
      
      return {
        'success': false,
        'data': <Category>[],
        'message': 'An unexpected error occurred',
        'error': 'service_exception',
      };
    }
  }

  /// Fetches a specific category by ID
  /// Returns a Map with 'success', 'data', 'message', and 'error' keys
  static Future<Map<String, dynamic>> getCategoryById(String categoryId) async {
    try {
      print('🔄 CategoryService: Fetching category with ID: $categoryId');
      
      // Call the API
      final ApiResponse<Category> response = await GetCategoriesApi.getCategoryById(categoryId);
      
      if (response.success && response.data != null) {
        print('✅ CategoryService: Successfully retrieved category: ${response.data!.title}');
        
        return {
          'success': true,
          'data': response.data!,
          'message': response.message,
          'error': null,
        };
      } else {
        print('❌ CategoryService: Failed to get category - ${response.message}');
        
        return {
          'success': false,
          'data': null,
          'message': response.message,
          'error': response.error,
        };
      }
      
    } catch (error) {
      print('💥 CategoryService: Exception occurred - $error');
      
      return {
        'success': false,
        'data': null,
        'message': 'An unexpected error occurred',
        'error': 'service_exception',
      };
    }
  }

  /// Tests the connection to the categories API
  /// Returns true if the connection is successful
  static Future<bool> testConnection() async {
    try {
      print('🔄 CategoryService: Testing API connection...');
      
      final bool isConnected = await GetCategoriesApi.testConnection();
      
      if (isConnected) {
        print('✅ CategoryService: API connection successful');
      } else {
        print('❌ CategoryService: API connection failed');
      }
      
      return isConnected;
    } catch (error) {
      print('💥 CategoryService: Connection test exception - $error');
      return false;
    }
  }

  /// Gets categories with caching support (optional enhancement)
  /// This method can be used to implement local caching if needed
  static Future<Map<String, dynamic>> getCategoriesWithCache() async {
    // For now, this just calls the regular getCategories method
    // In the future, you could implement caching logic here
    return await getCategories();
  }

  /// Searches categories by name or title (client-side filtering)
  /// Returns filtered categories based on the search query
  static Future<Map<String, dynamic>> searchCategories(String query) async {
    try {
      print('🔍 CategoryService: Searching categories for: "$query"');
      
      final result = await getCategories();
      
      if (result['success'] && result['data'] != null) {
        final List<Category> allCategories = result['data'] as List<Category>;
        
        final List<Category> filteredCategories = allCategories.where((category) {
          final String searchQuery = query.toLowerCase();
          return category.name.toLowerCase().contains(searchQuery) ||
                 category.title.toLowerCase().contains(searchQuery) ||
                 category.description.toLowerCase().contains(searchQuery);
        }).toList();
        
        print('✅ CategoryService: Found ${filteredCategories.length} categories matching "$query"');
        
        return {
          'success': true,
          'data': filteredCategories,
          'message': 'Search completed successfully',
          'error': null,
        };
      } else {
        return result; // Return the original error response
      }
      
    } catch (error) {
      print('💥 CategoryService: Search exception - $error');
      
      return {
        'success': false,
        'data': <Category>[],
        'message': 'Search failed',
        'error': 'search_exception',
      };
    }
  }

  /// Gets categories grouped by a specific field (optional utility method)
  /// This can be useful for organizing categories in the UI
  static Future<Map<String, List<Category>>> getCategoriesGrouped({String groupBy = 'name'}) async {
    try {
      print('🔄 CategoryService: Getting categories grouped by: $groupBy');
      
      final result = await getCategories();
      
      if (result['success'] && result['data'] != null) {
        final List<Category> categories = result['data'] as List<Category>;
        final Map<String, List<Category>> groupedCategories = <String, List<Category>>{};
        
        for (final category in categories) {
          String key;
          
          switch (groupBy.toLowerCase()) {
            case 'title':
              key = category.title.isNotEmpty ? category.title[0].toUpperCase() : 'Other';
              break;
            case 'name':
            default:
              key = category.name.isNotEmpty ? category.name[0].toUpperCase() : 'Other';
              break;
          }
          
          if (!groupedCategories.containsKey(key)) {
            groupedCategories[key] = <Category>[];
          }
          groupedCategories[key]!.add(category);
        }
        
        print('✅ CategoryService: Categories grouped into ${groupedCategories.length} groups');
        return groupedCategories;
      } else {
        print('❌ CategoryService: Failed to group categories');
        return <String, List<Category>>{};
      }
      
    } catch (error) {
      print('💥 CategoryService: Grouping exception - $error');
      return <String, List<Category>>{};
    }
  }
}