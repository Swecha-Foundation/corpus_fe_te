// ignore_for_file: deprecated_member_use, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import '../../constants.dart';
import '../../services/api_service.dart';
import '../../services/token_storage_service.dart';
import '../../services/uuid_service.dart';

double cos(double radians) {
  return math.cos(radians);
}

double sin(double radians) {
  return math.sin(radians);
}

class AudioInputScreen extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedCategoryId;
  final String? categoryId;
  final String? userId;

  const AudioInputScreen({
    Key? key,
    this.selectedCategory,
    this.selectedCategoryId,
    this.categoryId,
    this.userId,
  }) : super(key: key);

  @override
  State<AudioInputScreen> createState() => _AudioInputScreenState();
}

class _AudioInputScreenState extends State<AudioInputScreen>
    with TickerProviderStateMixin {
  
  // Add title controller
  final TextEditingController _titleController = TextEditingController();
  
  bool _isRecording = false;
  bool _isPaused = false;
  bool _hasRecording = false;
  bool _isPlaying = false;
  bool _isUploading = false;
  bool _isInitializing = false;
  bool _locationPermissionGranted = false;
  bool _locationEnabled = false;
  Duration _recordingDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  Timer? _recordingTimer;
  Timer? _playbackTimer;
  String _selectedLanguage = 'Telugu';
  double _audioLevel = 0.0;
  
  // Add title word count
  int _titleWordCount = 0;

  // Audio components
  AudioRecorder? _audioRecorder;
  late AudioPlayer _audioPlayer;

  // API related variables
  String? _currentRecordId;
  File? _audioFile;
  String? _userId;
  Position? _currentPosition;

  // Category management
  String? _effectiveCategory;
  String? _categoryId;
  List<String> _availableCategories = [];

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  // Location variables
  double? _currentLatitude;
  double? _currentLongitude;
  String _locationStatus = 'Location not available';

  // Fallback categories map
  static const Map<String, String> fallbackCategories = {
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
    // Add title listener
    _titleController.addListener(_updateTitleWordCount);
    _initializeData();
    _initializeAudio();
    _setupAnimations();
  }

  @override
  void dispose() {
    // Dispose title controller
    _titleController.removeListener(_updateTitleWordCount);
    _titleController.dispose();
    
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _audioRecorder?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Add title word count method
  void _updateTitleWordCount() {
    final text = _titleController.text.trim();
    setState(() {
      _titleWordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
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
          _showError('Please login to submit content');
        }
      } else {
        print('DEBUG: User is authenticated with ID: $_userId');
      }

      // Get location in parallel
      _initializeLocation();
    } catch (e) {
      print('Error initializing data: $e');
      if (mounted) {
        _showError('Error loading data: ${e.toString()}');
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
      // Check if token exists
      final token = await TokenStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        print('DEBUG: No token found');
        return false;
      }

      // Check token expiry
      final isValid = await TokenStorageService.isTokenValid();
      if (!isValid) {
        print('DEBUG: Token expired');
        return false;
      }

      // Test token with API call
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
        // If it's a network error, we might still have a valid token
        if (e.toString().contains('network') ||
            e.toString().contains('connection')) {
          print(
              'DEBUG: Network error during token validation, assuming token is valid');
          return true;
        }
        return false;
      }
    } catch (e) {
      print('DEBUG: Token validation error: $e');
      return false;
    }
  }

  void _initializeAudio() async {
    try {
      _audioRecorder = AudioRecorder();
      _audioPlayer = AudioPlayer();

      // Check if recording is supported
      bool isSupported =
          await _audioRecorder!.isEncoderSupported(AudioEncoder.aacLc);
      if (!isSupported) {
        print('Audio recording is not supported on this platform');
        _showError('Audio recording is not supported on this device');
        return;
      }

      // Listen to player state changes
      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
          if (state == PlayerState.completed) {
            _stopPlayback();
          }
        }
      });

      // Listen to position changes during playback
      _audioPlayer.onPositionChanged.listen((Duration position) {
        if (mounted) {
          setState(() {
            _playbackPosition = position;
          });
        }
      });
    } catch (e) {
      print('Error initializing audio: $e');
      _showError('Failed to initialize audio recording: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _initializeLocation() async {
    try {
      // Check and request location permissions
      await _checkLocationPermissions();
      // If permissions are granted, get current location
      if (_locationPermissionGranted && _locationEnabled) {
        await _getCurrentLocation();
      }
    } catch (e) {
      print('Failed to initialize location: $e');
    }
  }

  Future<void> _checkLocationPermissions() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      setState(() {
        _locationEnabled = serviceEnabled;
      });

      if (!serviceEnabled) {
        print('Location services are disabled');
        return;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
      }

      // Update permission status
      setState(() {
        _locationPermissionGranted =
            permission == LocationPermission.whileInUse ||
                permission == LocationPermission.always;
      });

      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        _showLocationPermissionDialog();
        return;
      }

      if (!_locationPermissionGranted) {
        print('Location permission denied');
        return;
      }

      print('Location permission granted');
    } catch (e) {
      print('Error checking location permissions: $e');
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission'),
          content: const Text(
            'Location permission is required to add location data to your recordings. '
            'You can enable it in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestLocationPermission() async {
    try {
      if (!_locationEnabled) {
        // Show dialog to enable location services
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Enable Location Services'),
              content: const Text(
                'Please enable location services in your device settings to use location features.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
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
        return;
      }

      // Request location permission
      LocationPermission permission = await Geolocator.requestPermission();
      setState(() {
        _locationPermissionGranted =
            permission == LocationPermission.whileInUse ||
                permission == LocationPermission.always;
      });

      if (_locationPermissionGranted) {
        _showSuccess('Location permission granted');
        await _getCurrentLocation();
      } else if (permission == LocationPermission.deniedForever) {
        _showLocationPermissionDialog();
      } else {
        _showError('Location permission denied');
      }
    } catch (e) {
      print('Error requesting location permission: $e');
      _showError('Failed to request location permission');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (!_locationPermissionGranted || !_locationEnabled) {
        print('Location permission not granted or services disabled');
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Getting location...'),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.blue,
        ),
      );

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted && _currentPosition != null) {
        setState(() {
          _currentLatitude = _currentPosition!.latitude;
          _currentLongitude = _currentPosition!.longitude;
          _locationStatus = 'Location obtained';
        });

        print(
            'Location obtained: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
        _showSuccess('Location updated successfully');
      }
    } catch (e) {
      print('Failed to get location: $e');
      setState(() {
        _locationStatus = 'Location failed';
      });
      _showError('Failed to get current location');
    }
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  // Enhanced permission handling method
  Future<bool> _requestPermissions() async {
    try {
      // Check current microphone permission status
      PermissionStatus microphoneStatus = await Permission.microphone.status;
      if (microphoneStatus.isDenied) {
        // Request microphone permission
        microphoneStatus = await Permission.microphone.request();
      }

      if (microphoneStatus.isPermanentlyDenied) {
        // Show dialog to open app settings
        _showPermissionDialog(
          'Microphone Permission Required',
          'Please enable microphone permission in app settings to record audio.',
        );
        return false;
      }

      if (microphoneStatus.isGranted) {
        // For Android, also check storage permission
        if (Platform.isAndroid) {
          PermissionStatus storageStatus = await Permission.storage.status;
          if (storageStatus.isDenied) {
            storageStatus = await Permission.storage.request();
          }

          // For Android 11+ (API 30+), may need MANAGE_EXTERNAL_STORAGE
          if (storageStatus.isPermanentlyDenied) {
            await Permission.manageExternalStorage.request();
          }
        }
        return true;
      }

      _showError('Microphone permission is required for recording');
      return false;
    } catch (e) {
      print('Error requesting permissions: $e');
      _showError('Failed to request permissions: $e');
      return false;
    }
  }

  // Enhanced permission dialog
  void _showPermissionDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startRecording() async {
    try {
      if (_audioRecorder == null) {
        _showError('Audio recorder not initialized');
        return;
      }

      // Request permissions first
      bool hasPermissions = await _requestPermissions();
      if (!hasPermissions) {
        return;
      }

      // Check if recorder has permission
      bool hasPermission = await _audioRecorder!.hasPermission();
      if (!hasPermission) {
        _showError('Microphone permission denied');
        return;
      }

      // Try to get location before recording if permission is granted
      if (_locationPermissionGranted && _locationEnabled) {
        await _getCurrentLocation();
      }

      // Create audio file path
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final filePath = '${directory.path}/$fileName';
      _audioFile = File(filePath);

      // Start recording with proper configuration
      await _audioRecorder!.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: filePath,
      );

      setState(() {
        _isRecording = true;
        _isPaused = false;
        _recordingDuration = Duration.zero;
        _hasRecording = false;
        _currentRecordId = null;
      });

      _waveController.repeat();

      // Start recording timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration = Duration(seconds: timer.tick);
            // Simulate audio level changes - in real app you'd get actual levels
            _audioLevel = (timer.tick % 3) * 0.3 + 0.2;
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording started...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error starting recording: $e');
      _showError('Failed to start recording: $e');
    }
  }

  Future<void> _pauseRecording() async {
    try {
      if (_audioRecorder == null) return;

      await _audioRecorder!.pause();
      setState(() {
        _isPaused = true;
      });
      _recordingTimer?.cancel();
      _waveController.stop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording paused'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error pausing recording: $e');
      _showError('Failed to pause recording: $e');
    }
  }

  Future<void> _resumeRecording() async {
    try {
      if (_audioRecorder == null) return;

      await _audioRecorder!.resume();
      setState(() {
        _isPaused = false;
      });
      _waveController.repeat();

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingDuration =
                _recordingDuration + const Duration(seconds: 1);
            _audioLevel = (timer.tick % 3) * 0.3 + 0.2;
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording resumed'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error resuming recording: $e');
      _showError('Failed to resume recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (_audioRecorder == null) return;

      final path = await _audioRecorder!.stop();
      setState(() {
        _isRecording = false;
        _isPaused = false;
        _hasRecording = true;
        _audioLevel = 0.0;
      });

      _recordingTimer?.cancel();
      _waveController.stop();

      if (path != null) {
        _audioFile = File(path);
        print('Recording saved to: $path');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording stopped'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error stopping recording: $e');
      _showError('Failed to stop recording: $e');
    }
  }

  Future<void> _playRecording() async {
    if (!_hasRecording || _audioFile == null) return;

    try {
      await _audioPlayer.play(DeviceFileSource(_audioFile!.path));
      setState(() {
        _isPlaying = true;
        _playbackPosition = Duration.zero;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Playing recording...'),
          backgroundColor: Colors.purple,
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      print('Error playing recording: $e');
      _showError('Failed to play recording: $e');
    }
  }

  Future<void> _stopPlayback() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _playbackPosition = Duration.zero;
      });
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  void _deleteRecording() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recording'),
          content:
              const Text('Are you sure you want to delete this recording?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _hasRecording = false;
                  _recordingDuration = Duration.zero;
                  _playbackPosition = Duration.zero;
                  _isPlaying = false;
                  _currentRecordId = null;
                });
                _playbackTimer?.cancel();

                // Delete local file
                if (_audioFile != null && _audioFile!.existsSync()) {
                  _audioFile!.deleteSync();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Recording deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRecording() async {
    // Check if title is provided
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for your recording'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_hasRecording || _audioFile == null || _userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please record audio first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Submit Recording'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${_titleController.text.trim()}'),
              Text('Duration: ${_formatDuration(_recordingDuration)}'),
              Text('Language: $_selectedLanguage'),
              if (_effectiveCategory != null)
                Text('Category: $_effectiveCategory'),
              if (_currentPosition != null)
                Text(
                    'Location: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}')
              else
                const Text('Location: Not available'),
              const SizedBox(height: 16),
              const Text(
                  'This will create a record and upload your audio. Continue?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _handleSubmit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to get category ID
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
      final categoryId = fallbackCategories[widget.selectedCategory!];
      if (categoryId != null) return categoryId;
    }

    // Default fallback to Music category
    return fallbackCategories['Music']!;
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isUploading = true;
    });

    try {
      // Step 1: Validate preconditions
      if (_audioFile == null || !_audioFile!.existsSync()) {
        throw Exception('Audio file not found');
      }

      if (_userId == null || _userId!.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Step 2: Validate token
      bool isTokenValid = await _validateToken();
      if (!isTokenValid) {
        throw Exception('Authentication expired. Please login again.');
      }

      // Step 3: Prepare file information
      final fileSize = await _audioFile!.length();
      final fileName = _audioFile!.path.split('/').last;
      final categoryId = _getCategoryId();

      print('DEBUG: Starting submit process');
      print('DEBUG: User ID: $_userId');
      print('DEBUG: Category ID: $categoryId');
      print('DEBUG: File size: $fileSize bytes');

      // Step 4: Create record with title
      final createResult = await ApiService.createRecord(
        title: _titleController.text.trim(), // Use the title from input
        description:
            'Audio recording in $_selectedLanguage language (${_formatDuration(_recordingDuration)})',
        categoryId: categoryId,
        userId: _userId!,
        mediaType: 'audio',
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        fileName: fileName,
        fileSize: fileSize,
      );

      print('DEBUG: Create record result: $createResult');

      if (!createResult['success']) {
        throw Exception(createResult['error'] ?? 'Failed to create record');
      }

      // Step 5: Extract record ID (handle different response formats)
      final recordData = createResult['data'];
      _currentRecordId = _extractRecordId(recordData);

      if (_currentRecordId == null) {
        throw Exception('No record ID returned from server');
      }

      print('DEBUG: Created record with ID: $_currentRecordId');

      // Step 6: Upload file
      final uploadResult = await ApiService.uploadRecord(
        recordId: _currentRecordId!,
        file: _audioFile!,
        title: _titleController.text.trim(), // Use the title from input
        categoryId: categoryId,
        userId: _userId!,
        mediaType: 'audio',
        description:
            'Audio recording in $_selectedLanguage (${_formatDuration(_recordingDuration)})',
      );

      print('DEBUG: Upload result: $uploadResult');

      if (!uploadResult['success']) {
        throw Exception(uploadResult['error'] ?? 'Failed to upload audio file');
      }

      // Step 7: Success handling
      _showSuccess(
          'Recording submitted successfully! (${_formatDuration(_recordingDuration)})');

      // Navigate back with success data
      Navigator.pop(context, {
        'success': true,
        'recordId': _currentRecordId,
        'duration': _recordingDuration.inSeconds,
        'category': _effectiveCategory,
        'title': _titleController.text.trim(),
      });
    } catch (e) {
      print('Submit error: $e');
      String errorMessage = e.toString();

      // Handle specific error types
      if (errorMessage.contains('Authentication')) {
        errorMessage = 'Please login again to submit recordings';
      } else if (errorMessage.contains('network') ||
          errorMessage.contains('connection')) {
        errorMessage =
            'Network error. Please check your connection and try again';
      } else if (errorMessage.contains('file')) {
        errorMessage = 'Audio file error. Please record again';
      }

      _showError('Failed to submit recording: $errorMessage');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  String? _extractRecordId(dynamic recordData) {
    if (recordData == null) return null;

    // Try different possible field names
    final possibleFields = ['uid', 'id', 'recordId', 'record_id'];
    for (String field in possibleFields) {
      if (recordData[field] != null) {
        return recordData[field].toString();
      }
    }
    return null;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  Widget _buildLocationStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _locationPermissionGranted && _locationEnabled
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _locationPermissionGranted && _locationEnabled
              ? Colors.green
              : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _locationPermissionGranted && _locationEnabled
                ? Icons.location_on
                : Icons.location_off,
            size: 14,
            color: _locationPermissionGranted && _locationEnabled
                ? Colors.green
                : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            _locationPermissionGranted && _locationEnabled
                ? 'Location enabled'
                : 'Location disabled',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _locationPermissionGranted && _locationEnabled
                  ? Colors.green
                  : Colors.orange,
            ),
          ),
          if (!_locationPermissionGranted || !_locationEnabled) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _requestLocationPermission,
              child: const Icon(
                Icons.settings,
                size: 14,
                color: Colors.orange,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Add title section widget
  Widget _buildTitleSection() {
    return Container(
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
        maxLength: 100,
        decoration: InputDecoration(
          labelText: 'Recording Title *',
          hintText: 'Give your recording a descriptive title',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          counterText: '$_titleWordCount/20 words',
          counterStyle: TextStyle(
            color: _titleWordCount > 20 ? Colors.red : Colors.grey[600],
            fontSize: 12,
          ),
          errorText: _titleWordCount > 20 ? 'Title exceeds word limit' : null,
          prefixIcon: const Icon(Icons.title, color: kPrimaryColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Audio Recording',
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_hasRecording)
            IconButton(
              onPressed: _deleteRecording,
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  MediaQuery.of(context).padding.bottom,
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
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            _buildLocationStatus(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.language,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Language: $_selectedLanguage',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _showLanguageSelector(),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: kPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Title Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.title,
                                color: kPrimaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Recording Title',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTitleSection(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Recording Visualization
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Audio Visualizer
                          Container(
                            height: 200,
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(vertical: 32),
                            child: _buildAudioVisualizer(),
                          ),

                          // Duration Display
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(0, 2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              _formatDuration(
                                _isPlaying
                                    ? _playbackPosition
                                    : _recordingDuration,
                              ),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Control Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Play/Pause Button (only show if has recording)
                              if (_hasRecording)
                                _buildControlButton(
                                  onPressed: _isPlaying
                                      ? _stopPlayback
                                      : _playRecording,
                                  icon: _isPlaying
                                      ? Icons.stop
                                      : Icons.play_arrow,
                                  color: Colors.purple,
                                  size: 60,
                                ),

                              // Main Record Button
                              _buildMainRecordButton(),

                              // Delete Button (only show if has recording)
                              if (_hasRecording)
                                _buildControlButton(
                                  onPressed: _deleteRecording,
                                  icon: Icons.delete,
                                  color: Colors.red,
                                  size: 60,
                                ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Additional Controls Row
                          if (_isRecording) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildControlButton(
                                  onPressed: _isPaused
                                      ? _resumeRecording
                                      : _pauseRecording,
                                  icon: _isPaused
                                      ? Icons.play_arrow
                                      : Icons.pause,
                                  color: Colors.orange,
                                  size: 50,
                                ),
                                const SizedBox(width: 20),
                                _buildControlButton(
                                  onPressed: _stopRecording,
                                  icon: Icons.stop,
                                  color: Colors.red,
                                  size: 50,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Submit Button
                  if (_hasRecording && !_isRecording)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _submitRecording,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Uploading...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Submit Recording',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainRecordButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isRecording && !_isPaused ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () async {
              if (_isRecording) {
                // If recording, stop it
                await _stopRecording();
              } else {
                // If not recording, start recording
                await _startRecording();
              }
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording
                    ? (_isPaused ? Colors.orange : Colors.red)
                    : kPrimaryColor,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording
                            ? (_isPaused ? Colors.orange : Colors.red)
                            : kPrimaryColor)
                        .withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: _isRecording && !_isPaused ? 4 : 0,
                  ),
                ],
              ),
              child: Icon(
                _isRecording
                    ? (_isPaused ? Icons.play_arrow : Icons.stop)
                    : Icons.mic,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required double size,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.4,
        ),
      ),
    );
  }

  Widget _buildAudioVisualizer() {
    if (_isRecording && !_isPaused) {
      return AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(
            painter: AudioWavePainter(
              animationValue: _waveController.value,
              audioLevel: _audioLevel,
            ),
            size: const Size(double.infinity, 200),
          );
        },
      );
    } else if (_hasRecording) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isPlaying ? Icons.volume_up : Icons.audiotrack,
              size: 64,
              color: _isPlaying ? Colors.purple : kPrimaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              _isPlaying ? 'Playing...' : 'Recording Ready',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _isPlaying ? Colors.purple : kPrimaryColor,
              ),
            ),
            if (_isPlaying && _recordingDuration.inSeconds > 0) ...[
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: LinearProgressIndicator(
                  value: _playbackPosition.inSeconds /
                      _recordingDuration.inSeconds,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor:
                      const AlwaysStoppedAnimation(Colors.purple),
                ),
              ),
            ],
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic_none,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Tap to start recording',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...['Telugu', 'English', 'Hindi', 'Tamil', 'Kannada', 'Malayalam']
                  .map((language) => ListTile(
                        title: Text(language),
                        trailing: _selectedLanguage == language
                            ? const Icon(Icons.check, color: kPrimaryColor)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedLanguage = language;
                          });
                          Navigator.pop(context);
                        },
                      )),
            ],
          ),
        );
      },
    );
  }
}

// Custom painter for audio wave visualization
class AudioWavePainter extends CustomPainter {
  final double animationValue;
  final double audioLevel;

  AudioWavePainter({
    required this.animationValue,
    required this.audioLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kPrimaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;
    final waveWidth = size.width;
    const waveCount = 5;

    for (int i = 0; i < waveCount; i++) {
      final path = Path();
      final amplitude = (audioLevel * 50) * (1 - i * 0.2);
      final frequency = 0.02 * (i + 1);
      final phase = animationValue * 2 * math.pi * (i + 1);

      path.moveTo(0, centerY);

      for (double x = 0; x <= waveWidth; x += 2) {
        final y = centerY + amplitude * sin((x * frequency) + phase);
        path.lineTo(x, y);
      }

      paint.color = kPrimaryColor.withOpacity(1 - i * 0.2);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(AudioWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.audioLevel != audioLevel;
  }
}
