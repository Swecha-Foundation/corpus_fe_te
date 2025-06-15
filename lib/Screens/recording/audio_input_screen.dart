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
  
  const AudioInputScreen({
    Key? key,
    this.selectedCategory,
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

  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _setupAnimations();
    _initializeUser();
    _getCurrentLocation();
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

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Failed to get location: $e');
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

  Future<void> _handleSubmit() async {
    setState(() {
      _isUploading = true;
    });

    try {
      if (_audioFile == null || !_audioFile!.existsSync()) {
        throw Exception('Audio file not found');
      }

      // Get file info
      final fileSize = await _audioFile!.length();
      final fileName = _audioFile!.path.split('/').last;

      // Step 1: Create record with all required information
      final createResult = await ApiService.createRecord(
        title: 'Audio Recording - ${DateTime.now().toString().split('.')[0]}',
        description: 'Audio recording in $_selectedLanguage language (${_formatDuration(_recordingDuration)})',
        categoryId: widget.selectedCategory ?? 'general',
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
      _currentRecordId = recordData['id']?.toString();

      if (_currentRecordId == null) {
        throw Exception('No record ID returned from server');
      }

      // Step 2: Upload audio file
      final uploadResult = await ApiService.uploadRecord(
        recordId: _currentRecordId!,
        file: _audioFile!,
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            DropdownButton<String>(
                              value: _selectedLanguage,
                              underline: Container(),
                              items: ['Telugu', 'English', 'Hindi', 'Tamil'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null && !_isRecording) {
                                  setState(() {
                                    _selectedLanguage = newValue;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Record your voice',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap the record button to start capturing your audio',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        if (_currentRecordId != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'Record ID: $_currentRecordId',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Recording Area
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(20),
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
                        children: [
                          // Status and Duration
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_recordingDuration),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                              Row(
                                children: [
                                  if (_isUploading)
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  else
                                    Icon(
                                      _isRecording 
                                          ? (_isPaused ? Icons.pause : Icons.fiber_manual_record)
                                          : (_hasRecording ? Icons.check_circle : Icons.mic),
                                      color: _isRecording 
                                          ? (_isPaused ? Colors.orange : Colors.red)
                                          : (_hasRecording ? Colors.green : Colors.grey),
                                      size: 16,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isRecording 
                                        ? (_isPaused ? 'Paused' : 'Recording')
                                        : (_hasRecording ? 'Recorded' : 'Ready'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _isRecording 
                                          ? (_isPaused ? Colors.orange : Colors.red)
                                          : (_hasRecording ? Colors.green : Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Audio Visualization
                          SizedBox(
                            height: 100,
                            child: AnimatedBuilder(
                              animation: _waveController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: AudioWavePainter(
                                    animationValue: _waveController.value,
                                    audioLevel: _audioLevel,
                                    isRecording: _isRecording && !_isPaused,
                                  ),
                                  child: Container(),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Playback Controls
                          if (_hasRecording) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: _isPlaying ? _stopPlayback : _playRecording,
                                  icon: Icon(
                                    _isPlaying ? Icons.stop : Icons.play_arrow,
                                    size: 24,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.grey.shade100,
                                    foregroundColor: kPrimaryColor,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    children: [
                                      LinearProgressIndicator(
                                        value: _recordingDuration.inSeconds > 0
                                            ? _playbackPosition.inSeconds / _recordingDuration.inSeconds
                                            : 0.0,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatDuration(_playbackPosition),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            _formatDuration(_recordingDuration),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                          ],
                          
                          const Spacer(),
                          
                          // Main Record Button
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isRecording && !_isPaused ? _pulseAnimation.value : 1.0,
                                child: GestureDetector(
                                  onTap: () {
                                    if (!_isRecording) {
                                      _startRecording();
                                    } else {
                                      _stopRecording();
                                    }
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _isRecording ? Colors.red : kPrimaryColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: (_isRecording ? Colors.red : kPrimaryColor).withOpacity(0.3),
                                          spreadRadius: _isRecording ? 5 : 0,
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _isRecording ? Icons.stop : Icons.mic,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Control Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (_isRecording) ...[
                                IconButton(
                                  onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                                  icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.orange.shade100,
                                    foregroundColor: Colors.orange,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Submit Button
                  if (_hasRecording && !_isRecording)
                    Container(
                      margin: const EdgeInsets.all(16),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _submitRecording,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: kPrimaryColor,
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(8),
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
                                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                   ),
                                 ),
                                 SizedBox(width: 12),
                                 Text('Uploading...'),
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
                 
                 const SizedBox(height: 16),
               ],
             ),
           ),
         ),
       ),
     ),
   );
 }
}

class AudioWavePainter extends CustomPainter {
 final double animationValue;
 final double audioLevel;
 final bool isRecording;

 AudioWavePainter({
   required this.animationValue,
   required this.audioLevel,
   required this.isRecording,
 });

 @override
 void paint(Canvas canvas, Size size) {
   final paint = Paint()
     ..color = isRecording ? kPrimaryColor.withOpacity(0.6) : Colors.grey.withOpacity(0.3)
     ..strokeWidth = 2
     ..style = PaintingStyle.stroke;

   final centerY = size.height / 2;
   final width = size.width;
   const  waveCount = 50;
   
   for (int i = 0; i < waveCount; i++) {
     final x = (width / waveCount) * i;
     final normalizedX = x / width;
     
     // Create wave effect
     final waveOffset = sin((normalizedX * 4 * math.pi) + (animationValue * 2 * math.pi));
     final amplitude = isRecording ? (audioLevel * 30 + 10) : 5;
     final y1 = centerY - (waveOffset * amplitude);
     final y2 = centerY + (waveOffset * amplitude);
     
     // Draw wave line
     canvas.drawLine(
       Offset(x, y1),
       Offset(x, y2),
       paint,
     );
   }
 }

 @override
 bool shouldRepaint(AudioWavePainter oldDelegate) {
   return oldDelegate.animationValue != animationValue ||
          oldDelegate.audioLevel != audioLevel ||
          oldDelegate.isRecording != isRecording;
 }
}
