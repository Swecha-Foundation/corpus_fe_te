// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants.dart';
import '../../services/api_service.dart';
import '../../services/uuid_service.dart';
import '../../services/token_storage_service.dart';

class TextInputScreen extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedCategoryId; // UUID if already available

  const TextInputScreen({
    Key? key,
    this.selectedCategory,
    this.selectedCategoryId,
  }) : super(key: key);

  @override
  State<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isUploading = false;
  bool _isInitializing = true;
  int _wordCount = 0;
  int _characterCount = 0;
  String _selectedLanguage = 'Telugu';

  // API related variables
  File? _textFile;
  String? _userId;
  String? _categoryId;
  String _effectiveCategory = 'General';

  // Available categories loaded from API
  List<String> _availableCategories = [];

  // Location related variables
  double? _latitude;
  double? _longitude;
  bool _isLocationEnabled = false;
  bool _isLocationLoading = false;
  String _locationStatus = 'Location not available';

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateCounts);
    _initializeData();
    _checkLocationPermission();
  }

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login to submit content'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        print('DEBUG: User is authenticated with ID: $_userId');
      }
    } catch (e) {
      print('Error initializing data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  // Location permission and fetching methods
  Future<void> _checkLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = 'Location services disabled';
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = 'Location permission denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'Location permission permanently denied';
        });
        return;
      }

      // If we have permission, get location
      await _getCurrentLocation();
    } catch (e) {
      print('Error checking location permission: $e');
      setState(() {
        _locationStatus = 'Location error: ${e.toString()}';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationStatus = 'Getting location...';
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLocationEnabled = true;
        _locationStatus = 'Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        _isLocationLoading = false;
      });

      print('DEBUG: Location obtained - Lat: $_latitude, Lng: $_longitude');
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLocationLoading = false;
        _locationStatus = 'Failed to get location: ${e.toString()}';
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    // First check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    if (!serviceEnabled) {
      // Show dialog to enable location services
      _showLocationServiceDialog();
      return;
    }

    // Request location permission
    LocationPermission permission = await Geolocator.requestPermission();
    
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await _getCurrentLocation();
    } else if (permission == LocationPermission.deniedForever) {
      _showPermissionSettingsDialog();
    } else {
      setState(() {
        _locationStatus = 'Location permission denied';
      });
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: const Text(
            'Location services are disabled. Please enable them in your device settings to use this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'Location permission is permanently denied. Please enable it in app settings to use this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _toggleLocation() {
    if (_isLocationEnabled) {
      // Disable location
      setState(() {
        _isLocationEnabled = false;
        _latitude = null;
        _longitude = null;
        _locationStatus = 'Location disabled';
      });
    } else {
      // Enable location
      _requestLocationPermission();
    }
  }

  // Helper method to validate token
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

  Future<String?> _getCurrentUserId() async {
    try {
      // First try UUID service
      String? userId = await UuidService.getCurrentUserId();
      if (userId != null && userId.isNotEmpty) {
        print('DEBUG: Got user ID from UUID service: $userId');
        return userId;
      }

      // If UUID service fails, try SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId');
      if (userId != null && userId.isNotEmpty) {
        print('DEBUG: Got user ID from SharedPreferences: $userId');
        return userId;
      }

      // Try other possible keys
      userId = prefs.getString('user_id');
      if (userId != null && userId.isNotEmpty) {
        print('DEBUG: Got user ID from SharedPreferences (user_id): $userId');
        return userId;
      }

      print('DEBUG: No user ID found in any storage');
      return null;
    } catch (e) {
      print('DEBUG: Error getting user ID: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_updateCounts);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateCounts() {
    final text = _textController.text;
    setState(() {
      _characterCount = text.length;
      _wordCount =
          text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    });
  }

  Future<void> _createTextFile() async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName = 'text_${DateTime.now().millisecondsSinceEpoch}.txt';
      _textFile = File('${directory.path}/$fileName');

      // Write text content to file
      await _textFile!.writeAsString(_textController.text);
    } catch (e) {
      print('Error creating text file: $e');
      throw Exception('Failed to create text file: $e');
    }
  }

  Future<void> _handleSubmit() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Re-check user authentication before submit
    final currentUserId = await _getCurrentUserId();
    if (currentUserId == null || currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to submit content'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate token before proceeding
    final tokenValid = await _validateToken();
    if (!tokenValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Step 1: Create text file first
      await _createTextFile();

      // Step 2: Use the new createAndUploadRecord method with location data
      if (_categoryId == null || _categoryId!.isEmpty) {
        print("Category ID is null at submit text");
        return;
      }

      // Prepare description with location info if available
      String description = 'Text content in $_selectedLanguage language ($_wordCount words)';
      if (_isLocationEnabled && _latitude != null && _longitude != null) {
        description += ' - Location: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}';
      }

      final result = await ApiService.createAndUploadRecord(
        title: 'Text Input - ${DateTime.now().toString().split('.')[0]}',
        description: description,
        userId: currentUserId,
        mediaType: 'text',
        categoryId: _categoryId!,
        file: _textFile!,
        latitude: _isLocationEnabled ? _latitude : null,
        longitude: _isLocationEnabled ? _longitude : null,
      );

      // Clean up temporary file
      await _cleanupTempFile();

      if (result['success']) {
        if (mounted) {
          String successMessage = 'Text submitted successfully! ($_wordCount words)';
          if (_isLocationEnabled) {
            successMessage += ' with location data';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate back to previous screen
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(result['error'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      print('Submit error: $e');
      await _cleanupTempFile(); // Clean up on error too

      // Handle specific authentication errors
      String errorMessage = 'Failed to submit text: ${e.toString()}';
      if (e.toString().contains('User not authenticated') ||
          e.toString().contains('401') ||
          e.toString().contains('422')) {
        errorMessage = 'Authentication failed. Please login again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _cleanupTempFile() async {
    if (_textFile != null && _textFile!.existsSync()) {
      try {
        await _textFile!.delete();
        _textFile = null;
      } catch (e) {
        print('Error deleting temporary file: $e');
      }
    }
  }

  void _clearText() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Text'),
          content: const Text('Are you sure you want to clear all text?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  _textController.clear();
                });
                await _cleanupTempFile();
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

  void _changeCategory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Category'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableCategories.length,
              itemBuilder: (context, index) {
                final category = _availableCategories[index];
                return ListTile(
                  title: Text(category),
                  leading: Radio<String>(
                    value: category,
                    groupValue: _effectiveCategory,
                    onChanged: (String? value) {
                      Navigator.pop(context, value);
                    },
                  ),
                  onTap: () {
                    Navigator.pop(context, category);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    ).then((selectedCategory) async {
      if (selectedCategory != null && selectedCategory != _effectiveCategory) {
        final newCategoryId =
            await UuidService.getCategoryUuid(selectedCategory);
        setState(() {
          _effectiveCategory = selectedCategory;
          _categoryId = newCategoryId;
        });
      }
    });
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isLocationEnabled ? Icons.location_on : Icons.location_off,
                color: _isLocationEnabled ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Location',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                ),
              ),
              const Spacer(),
              if (_isLocationLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kPrimaryColor,
                  ),
                ),
              Switch(
                value: _isLocationEnabled,
                onChanged: (_) => _toggleLocation(),
                activeColor: kPrimaryColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _locationStatus,
            style: TextStyle(
              fontSize: 12,
              color: _isLocationEnabled ? Colors.green : Colors.grey,
            ),
          ),
          if (_isLocationEnabled && _latitude != null && _longitude != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Coordinates will be included with your submission',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
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
            'Text Input',
            style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: kPrimaryColor),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      resizeToAvoidBottomInset: true, // This helps with keyboard handling
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
        ),
        title: const Text(
          'Text Input',
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_textController.text.isNotEmpty)
            IconButton(
              onPressed: _clearText,
              icon: const Icon(Icons.clear, color: Colors.red),
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Header Info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.category,
                                    color: kPrimaryColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Category: $_effectiveCategory',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: kPrimaryColor,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: _changeCategory,
                                  child: const Text('Change'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.language,
                                    color: kPrimaryColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Language: $_selectedLanguage',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: kPrimaryColor,
                                  ),
                                ),
                                const Spacer(),
                                DropdownButton<String>(
                                  value: _selectedLanguage,
                                  underline: Container(),
                                  items: ['Telugu', 'English']
                                      .map((lang) => DropdownMenuItem(
                                            value: lang,
                                            child: Text(lang),
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
                              ],
                            ),
                            // Debug info (remove in production)
                            if (_userId != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person,
                                        color: Colors.green, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'User: ${_userId!.substring(0, 8)}...',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Location Card
                      _buildLocationCard(),

                      // Text Input Area - Made flexible instead of Expanded
                      Flexible(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          constraints: const BoxConstraints(
                            minHeight: 300, // Minimum height for text area
                            maxHeight:
                                500, // Maximum height to prevent overflow
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit,
                                        color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Enter your text',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '$_wordCount words',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: TextField(
                                    controller: _textController,
                                    focusNode: _focusNode,
                                    maxLines: null,
                                    expands: true,
                                    textAlignVertical: TextAlignVertical.top,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText:
                                          'Start typing your text here...',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Stats and Submit Button
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Statistics
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '$_wordCount',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                    const Text(
                                      'Words',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.grey.shade300,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '$_characterCount',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                    const Text(
                                      'Characters',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.grey.shade300,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      _selectedLanguage,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                    const Text(
                                      'Language',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Submit Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isUploading || _textController.text.trim().isEmpty
                                    ? null
                                    : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: _isUploading
                                    ? const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Submitting...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.send, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Submit Text${_isLocationEnabled ? ' with Location' : ''}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            
                            // Helper text
                            if (_textController.text.trim().isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Enter some text to enable submission',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            
                            if (_userId == null || _userId!.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Please login to submit content',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}