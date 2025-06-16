// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../constants.dart';
import '../../services/api_service.dart';
import '../../services/uuid_service.dart';
import '../../services/token_storage_service.dart';

class PictureInputScreen extends StatefulWidget {
  final String? selectedCategory;
  final String? categoryId;
  final String? selectedCategoryId;
  final String? userId;
  
  const PictureInputScreen({
    Key? key,
    this.selectedCategory,
    this.categoryId,
    this.selectedCategoryId,
    this.userId,
  }) : super(key: key);

  @override
  State<PictureInputScreen> createState() => _PictureInputScreenState();
}

class _PictureInputScreenState extends State<PictureInputScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  List<XFile> _selectedImages = [];
  bool _isProcessing = false;
  bool _isUploading = false;
  bool _isLoadingLocation = false;
  bool _isInitializing = false;
  String _selectedLanguage = 'Telugu';
  int _captionWordCount = 0;
  String? _createdRecordId;
  
  // ADD THESE MISSING VARIABLES TO YOUR CLASS
  String? _userId;                    // Current user ID
  String? _effectiveCategory;         // The category name being used
  String? _categoryId;               // The UUID of the category
  List<String> _availableCategories = []; // List of available category names
  
  // Location variables (these should already exist)
  double? _currentLatitude;
  double? _currentLongitude;
  String _locationStatus = 'Location not available';

  @override
  void initState() {
    super.initState();
    _captionController.addListener(_updateCaptionWordCount);
    _initializeData();
  }

  @override
  void dispose() {
    _captionController.removeListener(_updateCaptionWordCount);
    _captionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // Initialize all data including authentication and location
  Future<void> _initializeData() async {
  setState(() {
    _isInitializing = true;
  });

  try {
    // Initialize UUID service
    await UuidService.initialize();
    
    // Get current user ID - try multiple methods
    _userId = await _getCurrentUserId();
    print('DEBUG: Retrieved user ID: $_userId');
    
    // Get available categories
    final categories = await UuidService.getCategories();
    _availableCategories = categories.keys.toList();
    
    // If no categories available, add a default one
    if (_availableCategories.isEmpty) {
      _availableCategories = ['General'];
    }
    
    // Determine effective category and ID
    if (widget.selectedCategoryId != null && UuidService.isValidUuid(widget.selectedCategoryId!)) {
      // Use provided category ID
      _categoryId = widget.selectedCategoryId;
      _effectiveCategory = await UuidService.getCategoryName(_categoryId!) ?? 
                          widget.selectedCategory ?? 'General';
    } else if (widget.selectedCategory != null) {
      // Use provided category name
      _effectiveCategory = widget.selectedCategory!;
      _categoryId = await UuidService.getCategoryUuid(_effectiveCategory);
    } else {
      // Use default category
      _effectiveCategory = _availableCategories.isNotEmpty ? 
                          _availableCategories[0] : 'General';
      _categoryId = await UuidService.getCategoryUuid(_effectiveCategory);
    }
    
    // Check if user is authenticated
    if (_userId == null || _userId!.isEmpty) {
      print('DEBUG: User ID is null or empty');
      if (mounted) {
        _showSnackBar('Please login to submit content', Colors.orange);
      }
    } else {
      print('DEBUG: User is authenticated with ID: $_userId');
    }

    // Get location in parallel
    _getCurrentLocation();

  } catch (e) {
    print('Error initializing data: $e');
    if (mounted) {
      _showSnackBar('Error loading data: ${e.toString()}', Colors.red);
    }
  } finally {
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }
}


  // Enhanced user ID retrieval with multiple fallback methods
  Future<String?> _getCurrentUserId() async {
    try {
      // Method 1: Try TokenStorageService first
      String? userId = await TokenStorageService.getUserId();
      if (userId != null && userId.isNotEmpty) {
        return userId;
      }

      // Method 2: Try widget parameter
      if (widget.userId != null && widget.userId!.isNotEmpty) {
        return widget.userId;
      }

      // Method 3: Try to get from current user API call
      try {
        final userResult = await ApiService.getCurrentUser();
        if (userResult['success'] == true && userResult['data'] != null) {
          final userData = userResult['data'];
          if (userData['id'] != null) {
            return userData['id'].toString();
          }
        }
      } catch (e) {
        print('DEBUG: Failed to get user from API: $e');
      }

      return null;
    } catch (e) {
      print('DEBUG: Error in _getCurrentUserId: $e');
      return null;
    }
  }

  // Validate token before critical operations
  Future<bool> _validateToken() async {
    try {
      final isValid = await TokenStorageService.isTokenValid();
      if (!isValid) {
        print('DEBUG: Token expired');
        return false;
      }

      final token = await TokenStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        print('DEBUG: No token found');
        return false;
      }

      // Test the token by making a simple API call
      try {
        final testResult = await ApiService.getCurrentUser();
        if (testResult['success']) {
          print('DEBUG: Token validation passed');
          return true;
        } else {
          print('DEBUG: Token validation failed: ${testResult['error']}');
          return false;
        }
      } catch (e) {
        print('DEBUG: Token test failed: $e');
        return false;
      }
    } catch (e) {
      print('DEBUG: Token validation error: $e');
      return false;
    }
  }

  void _updateCaptionWordCount() {
    final text = _captionController.text.trim();
    setState(() {
      _captionWordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  // Location Services
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = 'Getting location...';
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = 'Location services are disabled';
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = 'Location permissions are denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'Location permissions are permanently denied';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
        _locationStatus = 'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _isLoadingLocation = false;
      });

      _showSnackBar('Location obtained successfully', Colors.green);
    } catch (e) {
      setState(() {
        _locationStatus = 'Failed to get location: $e';
        _isLoadingLocation = false;
      });
      _showSnackBar('Failed to get location: $e', Colors.red);
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (photo != null) {
        setState(() {
          _selectedImages.add(photo);
        });
        _showSnackBar('Photo captured successfully!', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Error capturing photo: $e', Colors.red);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
          // Limit to 10 images
          if (_selectedImages.length > 10) {
            _selectedImages = _selectedImages.take(10).toList();
            _showSnackBar('Maximum 10 images allowed', Colors.orange);
          }
        });
        _showSnackBar('${images.length} image(s) selected', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Error selecting images: $e', Colors.red);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    _showSnackBar('Image removed', Colors.grey);
  }

  Future<void> _processImages() async {
  if (_selectedImages.isEmpty) {
    _showSnackBar('Please select at least one image', Colors.orange);
    return;
  }

  if (_titleController.text.trim().isEmpty) {
    _showSnackBar('Please enter a title', Colors.orange);
    return;
  }

  // Re-check user authentication before submit
  final currentUserId = _userId ?? await _getCurrentUserId();
  if (currentUserId == null || currentUserId.isEmpty) {
    _showSnackBar('Please login to submit content', Colors.red);
    return;
  }

  // Validate token before proceeding
  final tokenValid = await _validateToken();
  if (!tokenValid) {
    if (mounted) {
      _showSnackBar('Session expired. Please login again.', Colors.red);
    }
    return;
  }

  setState(() {
    _isProcessing = true;
  });

  try {
    int successCount = 0;
    int failureCount = 0;

    // Process each image using the unified createAndUploadRecord method
    for (int i = 0; i < _selectedImages.length; i++) {
      try {
        final file = File(_selectedImages[i].path);
        
        // Prepare description for this specific image
        String imageDescription = _captionController.text.trim();
        if (_selectedImages.length > 1) {
          imageDescription += ' (Image ${i + 1} of ${_selectedImages.length})';
        }
        
        // Add location info if available
        if (_currentLatitude != null && _currentLongitude != null) {
          imageDescription += ' - Location: ${_currentLatitude!.toStringAsFixed(6)}, ${_currentLongitude!.toStringAsFixed(6)}';
        }

        // Get category ID - provide a default if null or invalid
        String categoryIdToUse = (_categoryId != null && UuidService.isValidUuid(_categoryId!)) 
            ? _categoryId! 
            : 'default'; // Provide a default value instead of null

        final result = await ApiService.createAndUploadRecord(
          title: '${_titleController.text.trim()}${_selectedImages.length > 1 ? ' - Image ${i + 1}' : ''}',
          description: imageDescription,
          userId: currentUserId,
          mediaType: 'image',
          categoryId: categoryIdToUse, // Now guaranteed to be non-null
          file: file,
          latitude: _currentLatitude,
          longitude: _currentLongitude,
        );

        if (result['success'] == true) {
          successCount++;
          print('Successfully uploaded image ${i + 1}: ${result['message'] ?? 'Success'}');
        } else {
          failureCount++;
          print('Upload failed for image ${i + 1}: ${result['message'] ?? 'Unknown error'}');
        }
      } catch (e) {
        failureCount++;
        print('Upload error for image ${i + 1}: $e');
        
        // Check for authentication errors
        if (e.toString().contains('User not authenticated') ||
            e.toString().contains('401') ||
            e.toString().contains('422') ||
            e.toString().contains('Unauthorized')) {
          _showSnackBar('Authentication failed. Please login again.', Colors.red);
          break; // Stop processing if authentication fails
        }
      }
    }

    setState(() {
      _isProcessing = false;
    });

    // Show results
    if (successCount > 0) {
      _showSnackBar(
        'Successfully uploaded $successCount/${_selectedImages.length} images',
        failureCount > 0 ? Colors.orange : Colors.green,
      );
      
      if (failureCount == 0) {
        // All images uploaded successfully, navigate back after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } else {
      _showSnackBar('Failed to upload images. Please try again.', Colors.red);
    }

  } catch (e) {
    setState(() {
      _isProcessing = false;
    });
    
    // Handle specific authentication errors
    String errorMessage = 'Error processing images: $e';
    if (e.toString().contains('User not authenticated') ||
        e.toString().contains('401') ||
        e.toString().contains('422') ||
        e.toString().contains('Unauthorized')) {
      errorMessage = 'Authentication failed. Please login again.';
    }
    
    _showSnackBar(errorMessage, Colors.red);
  }
}

Future<void> _saveDraft() async {
  if (_titleController.text.trim().isEmpty && 
      _captionController.text.trim().isEmpty && 
      _selectedImages.isEmpty) {
    _showSnackBar('Nothing to save', Colors.orange);
    return;
  }

  // Re-check user authentication before saving
  final currentUserId = _userId ?? await _getCurrentUserId();
  if (currentUserId == null || currentUserId.isEmpty) {
    _showSnackBar('Please login to save draft', Colors.red);
    return;
  }

  // Validate token before proceeding
  final tokenValid = await _validateToken();
  if (!tokenValid) {
    if (mounted) {
      _showSnackBar('Session expired. Please login again.', Colors.red);
    }
    return;
  }

  setState(() {
    _isProcessing = true;
  });

  try {
    // Get category ID - provide a default if null or invalid
    String categoryIdToUse = (_categoryId != null && UuidService.isValidUuid(_categoryId!)) 
        ? _categoryId! 
        : 'default'; // Provide a default value instead of null

    final recordResponse = await ApiService.createRecord(
      title: _titleController.text.trim().isEmpty 
          ? 'Draft - ${DateTime.now().toString().substring(0, 16)}' 
          : 'Draft - ${_titleController.text.trim()}',
      description: _captionController.text.trim(),
      categoryId: categoryIdToUse, // Now guaranteed to be non-null
      userId: currentUserId,
      mediaType: 'image',
      latitude: _currentLatitude,
      longitude: _currentLongitude,
      fileName: 'draft',
      fileSize: 0,
    );

    setState(() {
      _isProcessing = false;
    });

    if (recordResponse['success'] == true) {
      _showSnackBar('Draft saved successfully', Colors.green);
      print('Draft saved with ID: ${recordResponse['data']?['id']}');
    } else {
      _showSnackBar('Failed to save draft: ${recordResponse['message'] ?? 'Unknown error'}', Colors.red);
      print('Draft save failed: ${recordResponse['message']}');
    }
  } catch (e) {
    setState(() {
      _isProcessing = false;
    });
    
    // Handle authentication errors
    String errorMessage = 'Error saving draft: $e';
    if (e.toString().contains('User not authenticated') ||
        e.toString().contains('401') ||
        e.toString().contains('422') ||
        e.toString().contains('Unauthorized')) {
      errorMessage = 'Authentication failed. Please login again.';
    }
    
    _showSnackBar(errorMessage, Colors.red);
    print('Draft save error: $e');
  }
}

// Helper method to validate category before operations
bool _isValidCategory() {
  return _categoryId != null && UuidService.isValidUuid(_categoryId!);
}

  Future<void> _refreshCategoryData() async {
  try {
    if (_effectiveCategory != null) {
      final newCategoryId = await UuidService.getCategoryUuid(_effectiveCategory!);
      if (newCategoryId != null && newCategoryId != _categoryId) {
        setState(() {
          _categoryId = newCategoryId;
        });
        print('Updated category ID: $_categoryId for category: $_effectiveCategory');
      }
    }
  } catch (e) {
    print('Error refreshing category data: $e');
  }
}

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All'),
          content: const Text('Are you sure you want to clear all content?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedImages.clear();
                  _captionController.clear();
                  _titleController.clear();
                  _createdRecordId = null;
                });
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen during initialization
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: kPrimaryColor),
              SizedBox(height: 16),
              Text('Initializing...', style: TextStyle(color: kPrimaryColor)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
        ),
        title: const Text(
          'Picture Input',
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_selectedImages.isNotEmpty || 
              _captionController.text.isNotEmpty ||
              _titleController.text.isNotEmpty)
            IconButton(
              onPressed: _clearAll,
              icon: const Icon(Icons.clear, color: Colors.red),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Info with Location
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.selectedCategory ?? 'General',
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                        value: _selectedLanguage,
                        underline: Container(),
                        items: ['Telugu', 'English'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLanguage = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Share your visual story',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _isLoadingLocation 
                            ? Icons.location_searching 
                            : (_currentLatitude != null 
                                ? Icons.location_on 
                                : Icons.location_off),
                        size: 16,
                        color: _isLoadingLocation 
                            ? Colors.orange 
                            : (_currentLatitude != null 
                                ? Colors.green 
                                : Colors.red),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _locationStatus,
                          style: TextStyle(
                            fontSize: 12,
                            color: _isLoadingLocation 
                                ? Colors.orange 
                                : (_currentLatitude != null 
                                    ? Colors.green 
                                    : Colors.red),
                          ),
                        ),
                      ),
                      if (_isLoadingLocation)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                        )
                      else if (_currentLatitude == null)
                        IconButton(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.refresh, size: 16),
                          color: kPrimaryColor,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Input
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter a catchy title for your post',
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        maxLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),

                    // Image Selection Section
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.photo_camera, 
                                  color: kPrimaryColor, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Add Images',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_selectedImages.length}/10',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Image Selection Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _pickImageFromCamera,
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Camera'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickImageFromGallery,
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Gallery'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: kPrimaryColor,
                                    side: const BorderSide(color: kPrimaryColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Selected Images Grid
                          if (_selectedImages.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'Selected Images (${_selectedImages.length})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(File(_selectedImages[index].path)),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Caption Input
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.edit_note, 
                                  color: kPrimaryColor, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Caption',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$_captionWordCount words',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _captionController,
                            decoration: const InputDecoration(
                              hintText: 'Share your thoughts, story, or context...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            maxLines: 6,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Save Draft Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isProcessing || _isUploading ? null : _saveDraft,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryColor,
                        side: const BorderSide(color: kPrimaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isProcessing && !_isUploading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                              ),
                            )
                          : const Text('Save Draft'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Process/Upload Button
                  // Process/Upload Button
Expanded(
  flex: 2,
  child: ElevatedButton(
    onPressed: _isProcessing ? null : _processImages,
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
    ),
    child: _isProcessing
        ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              SizedBox(width: 8),
              Text('Processing...'),
            ],
          )
        : const Text('Process & Upload Images'),
  ),
),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}