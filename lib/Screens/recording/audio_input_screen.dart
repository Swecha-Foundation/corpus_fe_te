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

double cos(double radians) {
  return math.cos(radians);
}

double sin(double radians) {
  return math.sin(radians);
}

class AudioInputScreen extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedCategoryId; // Add this property
  
  const AudioInputScreen({
    Key? key,
    this.selectedCategory,
    this.selectedCategoryId, // Add this parameter
  }) : super(key: key);

  @override
  State<AudioInputScreen> createState() => _AudioInputScreenState();
}

class _AudioInputScreenState extends State<AudioInputScreen>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  bool _isPaused = false;
  bool _hasRecording = false;
  bool _isPlaying = false;
  bool _isUploading = false;
  bool _locationPermissionGranted = false;
  bool _locationEnabled = false;
  
  Duration _recordingDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  Timer? _recordingTimer;
  Timer? _playbackTimer;
  
  String _selectedLanguage = 'Telugu';
  double _audioLevel = 0.0;
  
  // FIXED: Use AudioRecorder instead of Record
  AudioRecorder? _audioRecorder;
  late AudioPlayer _audioPlayer;
  
  // API related variables
  String? _currentRecordId;
  File? _audioFile;
  String? _userId;
  Position? _currentPosition;
  
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  // Add fallback categories map
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
    _initializeAudio();
    _setupAnimations();
    _initializeUser();
    _initializeLocation();
  }

  void _initializeAudio() async {
    try {
      // FIXED: Initialize AudioRecorder properly
      _audioRecorder = AudioRecorder();
      _audioPlayer = AudioPlayer();
      
      // Check if recording is supported
      bool isSupported = await _audioRecorder!.isEncoderSupported(AudioEncoder.aacLc);
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

  Future<void> _initializeUser() async {
    try {
      // Get user ID from token storage or your auth system
      final userData = await TokenStorageService.getUserData();
      // ignore: unnecessary_null_comparison
      if (userData != null && userData['id'] != null) {
        _userId = userData['id'].toString();
      } else {
        // Fallback - you might want to redirect to login instead
        _userId = 'anonymous_user';
      }
    } catch (e) {
      print('Failed to get user data: $e');
      _userId = 'anonymous_user';
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
        _locationPermissionGranted = permission == LocationPermission.whileInUse || 
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
        _locationPermissionGranted = permission == LocationPermission.whileInUse || 
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
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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

      if (mounted) {
        setState(() {});
        print('Location obtained: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
        _showSuccess('Location updated successfully');
      }
    } catch (e) {
      print('Failed to get location: $e');
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

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _audioRecorder?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
    try {
      // Request microphone permission
      PermissionStatus microphoneStatus = await Permission.microphone.request();
      
      if (microphoneStatus != PermissionStatus.granted) {
        _showError('Microphone permission is required for recording');
        return false;
      }

      // For Android, also request storage permission if needed
      if (Platform.isAndroid) {
        PermissionStatus storageStatus = await Permission.storage.request();
        if (storageStatus != PermissionStatus.granted) {
          // Try with manage external storage for Android 11+
          await Permission.manageExternalStorage.request();
        }
      }

      return true;
    } catch (e) {
      print('Error requesting permissions: $e');
      _showError('Failed to request permissions: $e');
      return false;
    }
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

      // FIXED: Start recording with proper configuration
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
            _recordingDuration = _recordingDuration + const Duration(seconds: 1);
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
          content: const Text('Are you sure you want to delete this recording?'),
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
              Text('Duration: ${_formatDuration(_recordingDuration)}'),
              Text('Language: $_selectedLanguage'),
              if (widget.selectedCategory != null)
                Text('Category: ${widget.selectedCategory}'),
              if (_currentPosition != null)
                Text('Location: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}')
              else
                const Text('Location: Not available'),
              const SizedBox(height: 16),
              const Text('This will create a record and upload your audio. Continue?'),
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
    // If selectedCategoryId is provided, use it
    if (widget.selectedCategoryId != null) {
      return widget.selectedCategoryId!;
    }
    
    // If selectedCategory is provided, try to find matching ID
    if (widget.selectedCategory != null) {
      return fallbackCategories[widget.selectedCategory] ?? 
             fallbackCategories['Music']!; // Default to Music
    }
    
    // Default fallback
    return fallbackCategories['Music']!;
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isUploading = true;
    });

    try {
      if (_audioFile == null || !_audioFile!.existsSync()) {
        throw Exception('Audio file not found');
      }

      // FIXED: Get current user ID from TokenStorageService instead of UuidService
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // Get file info
      final fileSize = await _audioFile!.length();
      final fileName = _audioFile!.path.split('/').last;
      final categoryId = _getCategoryId();

      // Step 1: Create record with all required information
      final createResult = await ApiService.createRecord(
        title: 'Audio Recording - ${DateTime.now().toString().split('.')[0]}',
        description: 'Audio recording in $_selectedLanguage language (${_formatDuration(_recordingDuration)})',
        categoryId: categoryId,
        userId: _userId!,
        mediaType: 'audio',
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
        fileName: fileName,
        fileSize: fileSize,
      );

      if (!createResult['success']) {
        throw Exception(createResult['error'] ?? 'Failed to create record');
      }

      final recordData = createResult['data'];
      _currentRecordId = recordData['uid']?.toString(); // NOTE: API returns 'uid', not 'id'

      if (_currentRecordId == null) {
        throw Exception('No record ID returned from server');
      }

      // Step 2: Upload audio file with ALL required parameters
      final uploadResult = await ApiService.uploadRecord(
        recordId: _currentRecordId!,
        file: _audioFile!,
        title: 'Audio Recording - ${DateTime.now().toString().split('.')[0]}', // REQUIRED
        categoryId: categoryId, // REQUIRED
        userId: _userId!, // REQUIRED
        mediaType: 'audio', // REQUIRED
        description: 'Audio recording in $_selectedLanguage (${_formatDuration(_recordingDuration)})',
      );

      if (!uploadResult['success']) {
        throw Exception(uploadResult['error'] ?? 'Failed to upload audio file');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recording submitted successfully! (${_formatDuration(_recordingDuration)})',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back to previous screen
      Navigator.pop(context, {
        'success': true,
        'recordId': _currentRecordId,
        'duration': _recordingDuration.inSeconds,
      });
    } catch (e) {
      print('Submit error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit recording: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
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
                            const Icon(Icons.language, size: 16, color: Colors.grey),
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
                                _isPlaying ? _playbackPosition : _recordingDuration,
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
                                  onPressed: _isPlaying ? _stopPlayback : _playRecording,
                                  icon: _isPlaying ? Icons.stop : Icons.play_arrow,
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
                                  onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                                  icon: _isPaused ? Icons.play_arrow : Icons.pause,
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
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                  value: _playbackPosition.inSeconds / _recordingDuration.inSeconds,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
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