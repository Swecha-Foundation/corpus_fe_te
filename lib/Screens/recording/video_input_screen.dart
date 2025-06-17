// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../../constants.dart';
import '../../services/api_service.dart';
import '../../services/uuid_service.dart';
import '../../services/token_storage_service.dart';

class VideoInputScreen extends StatefulWidget {
  final String? selectedCategory;
  final String? categoryId;
  final String? selectedCategoryId;
  final String? userId;

  const VideoInputScreen({
    Key? key,
    this.selectedCategory,
    this.categoryId,
    this.selectedCategoryId,
    this.userId,
  }) : super(key: key);

  @override
  State<VideoInputScreen> createState() => _VideoInputScreenState();
}

class _VideoInputScreenState extends State<VideoInputScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedVideos = [];
  final List<int> _videoSizes = []; // Store actual file sizes
  bool _isProcessing = false;
  bool _isUploading = false;
  bool _isLoadingLocation = false;
  bool _isInitializing = false;
  String _selectedLanguage = 'Telugu';
  int _descriptionWordCount = 0;
  int _titleWordCount = 0;
  double _totalDuration = 0.0; // In seconds
  double _totalSize = 0.0; // In MB
  double _uploadProgress = 0.0;
  String? _createdRecordId;
  int _currentUploadIndex = 0;

  // ADD THESE MISSING VARIABLES TO YOUR CLASS
  String? _userId; // Current user ID
  String? _effectiveCategory; // The category name being used
  String? _categoryId; // The UUID of the category
  List<String> _availableCategories = []; // List of available category names

  // Location variables
  double? _currentLatitude;
  double? _currentLongitude;
  String _locationStatus = 'Location not available';

  // Fallback categories map for when categoryId is null
  final Map<String, String> _fallbackCategories = {
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

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_updateDescriptionWordCount);
    _titleController.addListener(_updateTitleWordCount);
    _initializeData();
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_updateDescriptionWordCount);
    _titleController.removeListener(_updateTitleWordCount);
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // Initialize data with proper authentication and categories
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
      if (widget.selectedCategoryId != null &&
          UuidService.isValidUuid(widget.selectedCategoryId!)) {
        // Use provided category ID
        _categoryId = widget.selectedCategoryId;
        _effectiveCategory = await UuidService.getCategoryName(_categoryId!) ??
            widget.selectedCategory ??
            'General';
      } else if (widget.selectedCategory != null) {
        // Use provided category name
        _effectiveCategory = widget.selectedCategory!;
        _categoryId = await UuidService.getCategoryUuid(_effectiveCategory);
      } else {
        // Use default category
        _effectiveCategory = _availableCategories.isNotEmpty
            ? _availableCategories[0]
            : 'General';
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

  // Helper method to get the appropriate category ID
  String _getCategoryId() {
    // First try to use the determined categoryId from initialization
    if (_categoryId != null && _categoryId!.isNotEmpty) {
      return _categoryId!;
    }

    // Fallback to provided categoryId
    if (widget.categoryId != null && widget.categoryId!.isNotEmpty) {
      return widget.categoryId!;
    }

    // If no categoryId, try to get it from selectedCategory name
    if (widget.selectedCategory != null) {
      final categoryId = _fallbackCategories[widget.selectedCategory!];
      if (categoryId != null) return categoryId;
    }

    // Default fallback to Music category
    return '94979e9f-4895-4cd7-8601-ad53d8099bf4';
  }

  void _updateDescriptionWordCount() {
    final text = _descriptionController.text.trim();
    setState(() {
      _descriptionWordCount =
          text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  void _updateTitleWordCount() {
    final text = _titleController.text.trim();
    setState(() {
      _titleWordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  // Location Services with proper permission handling
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = 'Getting location...';
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServicesDialog();
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
          _showLocationPermissionDialog();
          setState(() {
            _locationStatus = 'Location permissions are denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationPermissionDeniedForeverDialog();
        setState(() {
          _locationStatus = 'Location permissions are permanently denied';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
        _locationStatus =
            'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _isLoadingLocation = false;
      });

      _showSnackBar('Location obtained successfully', Colors.green);
    } catch (e) {
      setState(() {
        _locationStatus = 'Failed to get location: $e';
        _isLoadingLocation = false;
      });
      print('Location error: $e');
      _showSnackBar('Failed to get location', Colors.orange);
    }
  }

  // Show dialog when location services are disabled
  void _showLocationServicesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Location services are disabled on your device. Please enable location services in your device settings to add location information to your videos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  // Show dialog when location permission is denied
  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'This app needs location permission to add location information to your videos. This helps others discover content from your area.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not Now'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _getCurrentLocation(); // Retry
              },
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    );
  }

  // Show dialog when location permission is permanently denied
  void _showLocationPermissionDeniedForeverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Denied'),
          content: const Text(
            'Location permission has been permanently denied. To enable location for your videos, please go to app settings and grant location permission.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5), // 5 minute limit
      );

      if (video != null) {
        await _addVideoToList(video);
        _showSnackBar('Video recorded successfully!', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Error recording video: $e', Colors.red);
    }
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10), // 10 minute limit for gallery
      );

      if (video != null) {
        await _addVideoToList(video);
        _showSnackBar('Video selected successfully!', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Error selecting video: $e', Colors.red);
    }
  }

  Future<void> _addVideoToList(XFile video) async {
    if (_selectedVideos.length >= 3) {
      _showSnackBar('Maximum 3 videos allowed', Colors.orange);
      return;
    }

    try {
      // Get video file info
      final file = File(video.path);
      final sizeInBytes = await file.length();
      final sizeInMB = sizeInBytes / (1024 * 1024);

      // Check file size (limit to 100MB per video)
      if (sizeInMB > 100) {
        _showSnackBar('Video too large. Maximum 100MB per video', Colors.red);
        return;
      }

      setState(() {
        _selectedVideos.add(video);
        _videoSizes.add(sizeInBytes);
        _totalSize += sizeInMB;
        // Estimate duration (would need video_player package for accurate duration)
        _totalDuration += 30; // Placeholder - in real app, get actual duration
      });
    } catch (e) {
      _showSnackBar('Error processing video: $e', Colors.red);
    }
  }

  void _removeVideo(int index) {
    try {
      final sizeInBytes = _videoSizes[index];
      final sizeInMB = sizeInBytes / (1024 * 1024);

      setState(() {
        _selectedVideos.removeAt(index);
        _videoSizes.removeAt(index);
        _totalSize -= sizeInMB;
        _totalDuration -= 30; // Placeholder
      });

      _showSnackBar('Video removed', Colors.grey);
    } catch (e) {
      _showSnackBar('Error removing video: $e', Colors.red);
    }
  }

  // FIXED: Process videos with proper validation and API calls
  Future<void> _processVideos() async {
    if (_selectedVideos.isEmpty) {
      _showSnackBar('Please select at least one video', Colors.orange);
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Please enter a title', Colors.orange);
      return;
    }

    // Validate user authentication
    if (_userId == null || _userId!.isEmpty) {
      _showSnackBar('Please login to submit content', Colors.orange);
      return;
    }

    // Validate category ID
    final categoryId = _getCategoryId();
    if (categoryId.isEmpty) {
      _showSnackBar('Category is required', Colors.orange);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Calculate total file size for the largest video (as representative)
      final largestVideoIndex =
          _videoSizes.indexOf(_videoSizes.reduce((a, b) => a > b ? a : b));
      final largestVideoSize = _videoSizes[largestVideoIndex];

      // Create the record using the createRecord method with proper parameters
      final recordResult = await ApiService.createRecord(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: categoryId, // Use the validated category ID
        userId: _userId!, // Use the validated user ID
        mediaType: 'video',
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        fileName: _selectedVideos[largestVideoIndex].name,
        fileSize: largestVideoSize,
      );

      print('Create record result: $recordResult'); // Debug log

      if (recordResult['success']) {
        final recordData = recordResult['data'];
        print('Full record response: $recordData'); // Debug log

        // Log the full response for debugging
        print('Full record response data structure: $recordData'); // Debug log

        // Extract record ID - try all possible field names
        String? extractedId;

        // First try common ID field names
        final possibleIdFields = [
          'uid',
          'id',
          'record_id',
          '_id',
          'recordId',
          'uuid',
          'record_uid',
          'recordUid',
          'recordUUID',
          'record_uuid'
        ];

        // Try each possible field name
        for (final field in possibleIdFields) {
          if (recordData[field] != null) {
            extractedId = recordData[field].toString();
            print('Found ID in field: $field = $extractedId'); // Debug log
            break;
          }
        }

        // If still not found, try to find any field that might contain an ID
        if (extractedId == null) {
          recordData.forEach((key, value) {
            if ((key.toLowerCase().contains('id') ||
                    key.toLowerCase().contains('uid')) &&
                value != null &&
                value.toString().isNotEmpty) {
              extractedId = value.toString();
              print(
                  'Found potential ID in field: $key = $extractedId'); // Debug log
            }
          });
        }

        // Update state with the found ID
        setState(() {
          _createdRecordId = extractedId;
        });

        print('Extracted record ID: $_createdRecordId'); // Debug log

        if (_createdRecordId != null && _createdRecordId!.isNotEmpty) {
          _showSubmitDialog();
        } else {
          // If no ID found, provide detailed error with available fields
          final availableKeys = recordData.keys.join(', ');
          print('Available keys in response: $availableKeys'); // Debug log

          // Try to extract the record directly from the response if it's nested
          if (recordData['record'] != null && recordData['record'] is Map) {
            final nestedRecord = recordData['record'] as Map;
            print('Found nested record field, keys: ${nestedRecord.keys}');

            // Try to get ID from nested record
            for (final field in possibleIdFields) {
              if (nestedRecord[field] != null) {
                final nestedId = nestedRecord[field].toString();
                print('Found ID in nested record field: $field = $nestedId');
                setState(() {
                  _createdRecordId = nestedId;
                });
                _showSubmitDialog();
                return;
              }
            }
          }

          _showSnackBar(
              'Error: Could not get record ID from response. Available fields: $availableKeys',
              Colors.red);
        }
      } else {
        _showSnackBar(
            'Error creating record: ${recordResult['message'] ?? recordResult['error']}',
            Colors.red);
        print('Create record failed: $recordResult'); // Debug log
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
      print('Process videos error: $e'); // Debug log
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSubmitDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Submit Content'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${_titleController.text.trim()}'),
              Text('Videos: ${_selectedVideos.length}'),
              Text('Total size: ${_totalSize.toStringAsFixed(1)} MB'),
              Text('Estimated duration: ${_formatDuration(_totalDuration)}'),
              Text('Description words: $_descriptionWordCount'),
              Text('Language: $_selectedLanguage'),
              if (_effectiveCategory != null)
                Text('Category: $_effectiveCategory'),
              if (_currentLatitude != null && _currentLongitude != null)
                Text(
                    'Location: ${_currentLatitude!.toStringAsFixed(4)}, ${_currentLongitude!.toStringAsFixed(4)}'),
              const SizedBox(height: 16),
              const Text(
                  'Record created successfully! Ready to upload videos?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Editing'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _uploadVideos();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Upload Videos'),
            ),
          ],
        );
      },
    );
  }

  // FIXED: Upload videos with correct API method signature
  // FIXED: Upload videos with correct user ID handling
  Future<void> _uploadVideos() async {
    // Enhanced check for record ID
    if (_createdRecordId == null || _createdRecordId!.isEmpty) {
      print('ERROR: No record ID available for upload');

      // Try to recreate the record if missing
      _showSnackBar(
          'Record ID missing. Attempting to recreate record...', Colors.orange);

      // Attempt to recreate the record
      await _processVideos();

      // Check again after recreation attempt
      if (_createdRecordId == null || _createdRecordId!.isEmpty) {
        _showSnackBar(
            'Failed to create record ID. Cannot upload videos.', Colors.red);
        return;
      }
    }

    // Final authentication check - USE _userId instead of widget.userId
    if (_userId == null || _userId!.isEmpty) {
      _showSnackBar('Authentication required', Colors.red);
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _currentUploadIndex = 0;
    });

    try {
      int successfulUploads = 0;
      List<String> failedUploads = [];

      for (int i = 0; i < _selectedVideos.length; i++) {
        setState(() {
          _currentUploadIndex = i + 1;
          _uploadProgress = i / _selectedVideos.length;
        });

        final video = _selectedVideos[i];
        final file = File(video.path);

        // Verify file exists and is readable
        if (!await file.exists()) {
          failedUploads.add('Video ${i + 1}: File not found');
          continue;
        }

        // FIXED: Use _userId instead of widget.userId
        if (_userId == null || _userId!.isEmpty) {
          failedUploads.add('Video ${i + 1}: User ID is required');
          continue;
        }

        try {
          // FIXED: Use correct uploadRecord method signature with all required parameters
          final uploadResult = await ApiService.uploadRecord(
            recordId: _createdRecordId!,
            file: file,
            title: _titleController.text.trim(),
            categoryId:
                _getCategoryId(), // Use the helper method to get category ID
            userId: _userId!, // Use the authenticated user ID
            mediaType: 'video',
            description:
                '${_descriptionController.text.trim()} - Video ${i + 1}',
          );

          print('Upload result for video ${i + 1}: $uploadResult'); // Debug log

          if (uploadResult['success']) {
            successfulUploads++;
            _showSnackBar('Video ${i + 1} uploaded successfully', Colors.green);
          } else {
            final errorMessage = uploadResult['message'] ??
                uploadResult['error'] ??
                'Unknown error';
            failedUploads.add('Video ${i + 1}: $errorMessage');
            _showSnackBar(
                'Failed to upload video ${i + 1}: $errorMessage', Colors.red);
          }
        } catch (e) {
          failedUploads.add('Video ${i + 1}: $e');
          _showSnackBar('Error uploading video ${i + 1}: $e', Colors.red);
          print('Upload error for video ${i + 1}: $e'); // Debug log
        }

        // Small delay between uploads to prevent overwhelming the server
        await Future.delayed(const Duration(milliseconds: 500));
      }

      setState(() {
        _uploadProgress = 1.0;
      });

      // Show final result
      if (successfulUploads == _selectedVideos.length) {
        _showSuccessDialog();
      } else if (successfulUploads > 0) {
        _showPartialSuccessDialog(successfulUploads, failedUploads);
      } else {
        _showFailureDialog(failedUploads);
      }
    } catch (e) {
      _showSnackBar('Upload error: $e', Colors.red);
      print('General upload error: $e'); // Debug log
    } finally {
      setState(() {
        _isUploading = false;
        _currentUploadIndex = 0;
      });
    }
  }

  // Helper method to get uploaded records (for verification)
  Future<void> _getUploadedRecords() async {
    try {
      final result = await ApiService.getUserRecords(
        mediaType: 'video',
        limit: 10,
      );

      if (result['success']) {
        print('User records: ${result['data']}'); // Debug log
        _showSnackBar('Records retrieved successfully', Colors.green);
      } else {
        print('Failed to get records: ${result['error']}');
        _showSnackBar('Failed to get records: ${result['error']}', Colors.red);
      }
    } catch (e) {
      print('Error getting records: $e');
      _showSnackBar('Error getting records: $e', Colors.red);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              SizedBox(width: 8),
              Text('Success!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'All ${_selectedVideos.length} videos have been uploaded successfully!'),
              const SizedBox(height: 16),
              Text('Record ID: $_createdRecordId'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _getUploadedRecords(); // Optional: Show uploaded records
              },
              child: const Text('View Records'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true); // Return success to parent
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showPartialSuccessDialog(int successCount, List<String> failures) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 24),
              SizedBox(width: 8),
              Text('Partial Success'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '$successCount of ${_selectedVideos.length} videos uploaded successfully.'),
              const SizedBox(height: 12),
              if (failures.isNotEmpty) ...[
                const Text('Failed uploads:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...failures.take(3).map((failure) =>
                    Text('• $failure', style: const TextStyle(fontSize: 12))),
                if (failures.length > 3)
                  Text('... and ${failures.length - 3} more',
                      style: const TextStyle(fontSize: 12)),
              ],
              const SizedBox(height: 16),
              Text('Record ID: $_createdRecordId'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Retry only failed uploads (implement if needed)
              },
              child: const Text('Retry Failed'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showFailureDialog(List<String> failures) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('Upload Failed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('All video uploads failed:'),
              const SizedBox(height: 12),
              ...failures.take(3).map((failure) =>
                  Text('• $failure', style: const TextStyle(fontSize: 12))),
              if (failures.length > 3)
                Text('... and ${failures.length - 3} more',
                    style: const TextStyle(fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Retry all uploads
                _uploadVideos();
              },
              child: const Text('Retry'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveDraft() async {
    if (_titleController.text.trim().isEmpty && _selectedVideos.isEmpty) {
      _showSnackBar('Nothing to save', Colors.orange);
      return;
    }

    // For now, just show a message. In a real app, you might save to local storage
    _showSnackBar('Draft saved locally', Colors.green);
  }

  Future<void> _getLocationManually() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final latController =
            TextEditingController(text: _currentLatitude?.toString() ?? '');
        final lngController =
            TextEditingController(text: _currentLongitude?.toString() ?? '');

        return AlertDialog(
          title: const Text('Add Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  hintText: 'e.g., 17.3850',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: lngController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  hintText: 'e.g., 78.4867',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _currentLatitude = null;
                  _currentLongitude = null;
                  _locationStatus = 'Location not available';
                });
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final lat = double.tryParse(latController.text);
                final lng = double.tryParse(lngController.text);
                if (lat != null && lng != null) {
                  setState(() {
                    _currentLatitude = lat;
                    _currentLongitude = lng;
                    _locationStatus =
                        'Location: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
                  });
                  Navigator.pop(context);
                  _showSnackBar('Location set manually', Colors.green);
                } else {
                  _showSnackBar('Please enter valid coordinates', Colors.red);
                }
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes}m ${remainingSeconds}s';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Video Content'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isProcessing && !_isUploading)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _saveDraft,
                icon: const Icon(Icons.save_outlined,
                    color: Colors.white, size: 20),
                label: const Text('Save Draft',
                    style: TextStyle(color: Colors.white)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
        ],
      ),
      body: _isInitializing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Initializing...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Header gradient section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        children: [
                          // Category Display
                          if (_effectiveCategory != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.category,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    _effectiveCategory!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title Section
                        _buildSectionCard(
                          icon: Icons.title,
                          title: 'Title & Description',
                          child: Column(
                            children: [
                              // Title Input
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _titleController,
                                  maxLength: 100,
                                  decoration: InputDecoration(
                                    labelText: 'Title *',
                                    hintText:
                                        'Give your video an engaging title',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    counterText: '$_titleWordCount/20 words',
                                    counterStyle: TextStyle(
                                      color: _titleWordCount > 20
                                          ? Colors.red
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    errorText: _titleWordCount > 20
                                        ? 'Title exceeds word limit'
                                        : null,
                                    prefixIcon: const Icon(Icons.edit,
                                        color: kPrimaryColor),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Description Input
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _descriptionController,
                                  maxLines: 4,
                                  maxLength: 500,
                                  decoration: InputDecoration(
                                    labelText: 'Description',
                                    hintText:
                                        'Tell viewers what your video is about...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    alignLabelWithHint: true,
                                    counterText:
                                        '$_descriptionWordCount/100 words',
                                    counterStyle: TextStyle(
                                      color: _descriptionWordCount > 100
                                          ? Colors.red
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    errorText: _descriptionWordCount > 100
                                        ? 'Description exceeds word limit'
                                        : null,
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.only(bottom: 60),
                                      child: Icon(Icons.description,
                                          color: kPrimaryColor),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Language Selection
                        _buildSectionCard(
                          icon: Icons.language,
                          title: 'Language',
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedLanguage,
                              decoration: InputDecoration(
                                labelText: 'Select Language',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                prefixIcon: const Icon(Icons.translate,
                                    color: kPrimaryColor),
                              ),
                              items: [
                                'Telugu',
                                'Hindi',
                                'English',
                                'Tamil',
                                'Kannada'
                              ]
                                  .map((language) => DropdownMenuItem(
                                        value: language,
                                        child: Text(language),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedLanguage = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Location Section
                        _buildSectionCard(
                          icon: Icons.location_on,
                          title: 'Location',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: (_currentLatitude != null &&
                                          _currentLongitude != null)
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      (_currentLatitude != null &&
                                              _currentLongitude != null)
                                          ? Icons.location_on
                                          : Icons.location_off,
                                      color: (_currentLatitude != null &&
                                              _currentLongitude != null)
                                          ? Colors.green
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _locationStatus,
                                        style: TextStyle(
                                          color: (_currentLatitude != null &&
                                                  _currentLongitude != null)
                                              ? Colors.green[700]
                                              : Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _isLoadingLocation
                                          ? null
                                          : _getCurrentLocation,
                                      icon: _isLoadingLocation
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            )
                                          : const Icon(Icons.gps_fixed,
                                              size: 20),
                                      label: Text(_isLoadingLocation
                                          ? 'Locating...'
                                          : 'Auto Detect'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _getLocationManually,
                                      icon: const Icon(Icons.edit_location,
                                          size: 20),
                                      label: const Text('Manual Entry'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: kPrimaryColor,
                                        side: const BorderSide(
                                            color: kPrimaryColor),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Video Selection Section
                        _buildSectionCard(
                          icon: Icons.video_library,
                          title: 'Videos',
                          subtitle: '${_selectedVideos.length}/3 selected',
                          child: Column(
                            children: [
                              // Video selection buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _selectedVideos.length >= 3
                                          ? null
                                          : _recordVideo,
                                      icon:
                                          const Icon(Icons.videocam, size: 20),
                                      label: const Text('Record Video'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kPrimaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _selectedVideos.length >= 3
                                          ? null
                                          : _pickVideoFromGallery,
                                      icon: const Icon(Icons.photo_library,
                                          size: 20),
                                      label: const Text('From Gallery'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: kPrimaryColor,
                                        side: const BorderSide(
                                            color: kPrimaryColor),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Selected videos list
                              if (_selectedVideos.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.blue.withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.video_collection,
                                              color: Colors.blue[700]),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Selected Videos',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ...List.generate(_selectedVideos.length,
                                          (index) {
                                        final video = _selectedVideos[index];
                                        final sizeInMB =
                                            _videoSizes[index] / (1024 * 1024);
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 8),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 5,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.blue,
                                                    size: 20),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      video.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '${sizeInMB.toStringAsFixed(1)} MB',
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    _removeVideo(index),
                                                icon: const Icon(Icons.close,
                                                    color: Colors.red,
                                                    size: 20),
                                                style: IconButton.styleFrom(
                                                  backgroundColor: Colors.red
                                                      .withOpacity(0.1),
                                                  padding:
                                                      const EdgeInsets.all(6),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.data_usage,
                                                    size: 16,
                                                    color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Total: ${_totalSize.toStringAsFixed(1)} MB',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.schedule,
                                                    size: 16,
                                                    color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '~${_formatDuration(_totalDuration)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Upload Progress
                        if (_isUploading) ...[
                          _buildSectionCard(
                            icon: Icons.cloud_upload,
                            title: 'Upload Progress',
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.withOpacity(0.1),
                                        Colors.blue.withOpacity(0.05)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Video $_currentUploadIndex of ${_selectedVideos.length}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: _uploadProgress,
                                          minHeight: 8,
                                          backgroundColor: Colors.grey[300],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.blue[600]!),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_isProcessing ||
                                    _isUploading ||
                                    _selectedVideos.isEmpty)
                                ? null
                                : _processVideos,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[300],
                              elevation: _isProcessing || _isUploading ? 0 : 2,
                              shadowColor: kPrimaryColor.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isProcessing
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Text('Processing Videos...',
                                          style: TextStyle(fontSize: 16)),
                                    ],
                                  )
                                : Text(
                                    _isUploading
                                        ? 'Uploading Videos...'
                                        : _selectedVideos.isEmpty
                                            ? 'Please Select Videos'
                                            : 'Submit Videos',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Help Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[50]!, Colors.indigo[50]!],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.blue[200]!.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.lightbulb_outline,
                                        color: Colors.blue[700], size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Quick Tips',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTipItem(
                                  '📹', 'Maximum 3 videos per submission'),
                              _buildTipItem(
                                  '📦', 'Each video should be under 100MB'),
                              _buildTipItem('⏱️',
                                  'Recording: 5 min max, Gallery: 10 min max'),
                              _buildTipItem('📍',
                                  'Add location for better discoverability'),
                              _buildTipItem('✏️',
                                  'Use engaging titles and clear descriptions'),
                            ],
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

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: kPrimaryColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
