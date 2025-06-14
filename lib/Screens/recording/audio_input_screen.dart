// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants.dart';
import '../../services/api_service.dart';

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
  
  // API related variables
  String? _currentRecordId;
  File? _audioFile;
  String _userId = 'user123'; // Replace with actual user ID from your auth system
  
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkPermissions();
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

  Future<void> _checkPermissions() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    // Check microphone permission
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required for recording'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create audio file
    final directory = await getTemporaryDirectory();
    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _audioFile = File('${directory.path}/$fileName');

    setState(() {
      _isRecording = true;
      _isPaused = false;
      _recordingDuration = Duration.zero;
      _hasRecording = false;
      _currentRecordId = null;
    });
    
    _waveController.repeat();
    
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = Duration(seconds: timer.tick);
        // Simulate audio level changes
        _audioLevel = (timer.tick % 3) * 0.3 + 0.2;
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recording started...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _pauseRecording() {
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
  }

  void _resumeRecording() {
    setState(() {
      _isPaused = false;
    });
    
    _waveController.repeat();
    
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration = _recordingDuration + const Duration(seconds: 1);
        _audioLevel = (timer.tick % 3) * 0.3 + 0.2;
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recording resumed'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _hasRecording = true;
      _audioLevel = 0.0;
    });
    
    _recordingTimer?.cancel();
    _waveController.stop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recording stopped'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _playRecording() {
    if (!_hasRecording) return;
    
    setState(() {
      _isPlaying = true;
      _playbackPosition = Duration.zero;
    });
    
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _playbackPosition = Duration(seconds: timer.tick);
        if (_playbackPosition >= _recordingDuration) {
          _stopPlayback();
        }
      });
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Playing recording...'),
        backgroundColor: Colors.purple,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _stopPlayback() {
    setState(() {
      _isPlaying = false;
      _playbackPosition = Duration.zero;
    });
    _playbackTimer?.cancel();
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

  Future<void> _createRecord() async {
    if (!_hasRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please record audio first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Create record first
      final createResult = await ApiService.createRecord(
        title: 'Audio Recording - ${DateTime.now().toString()}',
        description: 'Audio recording in $_selectedLanguage language',
        categoryId: widget.selectedCategory ?? 'general',
        userId: _userId,
        mediaType: 'audio',
      );

      if (createResult['success']) {
        _currentRecordId = createResult['data']['id'];
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(createResult['error']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create record: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _uploadAudio() async {
    if (!_hasRecording || _audioFile == null || _currentRecordId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a record first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final uploadResult = await ApiService.uploadRecord(
        recordId: _currentRecordId!,
        file: _audioFile!,
        description: 'Audio recording in $_selectedLanguage',
      );

      if (uploadResult['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(uploadResult['error']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _submitRecording() async {
    if (!_hasRecording) {
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
      // Step 1: Create record
      if (_currentRecordId == null) {
        final createResult = await ApiService.createRecord(
          title: 'Audio Recording - ${DateTime.now().toString()}',
          description: 'Audio recording in $_selectedLanguage language',
          categoryId: widget.selectedCategory ?? 'general',
          userId: _userId,
          mediaType: 'audio',
        );

        if (createResult['success']) {
          _currentRecordId = createResult['data']['id'];
        } else {
          throw Exception(createResult['error']);
        }
      }

      // Step 2: Upload audio file
      if (_audioFile != null && _audioFile!.existsSync()) {
        final uploadResult = await ApiService.uploadRecord(
          recordId: _currentRecordId!,
          file: _audioFile!,
          description: 'Audio recording in $_selectedLanguage',
        );

        if (!uploadResult['success']) {
          throw Exception(uploadResult['error']);
        }
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
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit recording: $e'),
          backgroundColor: Colors.red,
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
                                Text(
                                  'Record ID: $_currentRecordId',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
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
                          Container(
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
                              if (_hasRecording && !_isRecording) ...[
                                IconButton(
                                  onPressed: _currentRecordId == null ? _createRecord : null,
                                  icon: const Icon(Icons.cloud_upload),
                                  style: IconButton.styleFrom(
                                    backgroundColor: _currentRecordId == null 
                                        ? Colors.blue.shade100 
                                        : Colors.grey.shade100,
                                    foregroundColor: _currentRecordId == null 
                                        ? Colors.blue 
                                        : Colors.grey,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _currentRecordId != null && _audioFile != null ? _uploadAudio : null,
                                  icon: const Icon(Icons.upload_file),
                                  style: IconButton.styleFrom(
                                    backgroundColor: _currentRecordId != null && _audioFile != null
                                        ? Colors.green.shade100
                                        : Colors.grey.shade100,
                                    foregroundColor: _currentRecordId != null && _audioFile != null
                                        ? Colors.green
                                        : Colors.grey,
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
                                  Text('Submitting...'),
                                ],
                              )
                            : const Text(
                                'Submit Recording',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
}

// Custom painter for audio wave visualization
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
      ..color = kPrimaryColor.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final waveCount = 5;
    
    for (int i = 0; i < waveCount; i++) {
      final progress = (animationValue + i * 0.2) % 1.0;
      final amplitude = isRecording ? (audioLevel * 30 + 10) * (1 - progress) : 5;
      final radius = progress * size.width / 2;
      
      paint.color = kPrimaryColor.withOpacity((1 - progress) * 0.5);
      
      canvas.drawCircle(center, radius, paint);
      
      // Draw vertical bars
      if (isRecording) {
        for (int j = 0; j < 20; j++) {
          final x = (j / 19) * size.width;
          final barHeight = amplitude * (0.5 + 0.5 * (j % 3)) * (1 - progress);
          final y1 = center.dy - barHeight / 2;
          final y2 = center.dy + barHeight / 2;
          
          canvas.drawLine(
            Offset(x, y1),
            Offset(x, y2),
            Paint()
              ..color = kPrimaryColor.withOpacity((1 - progress) * 0.7)
              ..strokeWidth = 1,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}