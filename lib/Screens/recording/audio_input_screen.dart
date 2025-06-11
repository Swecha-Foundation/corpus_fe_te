import 'package:flutter/material.dart';
import 'dart:async';
import '../../constants.dart';

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
  
  Duration _recordingDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  Timer? _recordingTimer;
  Timer? _playbackTimer;
  
  String _selectedLanguage = 'Telugu';
  double _audioLevel = 0.0;
  
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isPaused = false;
      _recordingDuration = Duration.zero;
      _hasRecording = false;
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
                });
                _playbackTimer?.cancel();
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

  void _submitRecording() {
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
              const Text('Are you ready to submit your recording?'),
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

  void _handleSubmit() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Recording submitted successfully! (${_formatDuration(_recordingDuration)})',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Navigate back to dashboard
    Navigator.pop(context);
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
        child: SingleChildScrollView( // SOLUTION 1: Wrap in SingleChildScrollView
          child: ConstrainedBox( // SOLUTION 2: Use ConstrainedBox to ensure minimum height
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                        MediaQuery.of(context).padding.top - 
                        kToolbarHeight - 
                        MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight( // SOLUTION 3: Use IntrinsicHeight for proper layout
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
                          // ignore: deprecated_member_use
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
                                // ignore: deprecated_member_use
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
                            // ignore: deprecated_member_use
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
                                  Icon(
                                    _isRecording 
                                        ? (_isPaused ? Icons.pause : Icons.fiber_manual_record)
                                        : (_hasRecording ? Icons.check_circle : Icons.mic),
                                    color: _isRecording 
                                        ? (_isPaused ? Colors.orange : Colors.red)
                                        : (_hasRecording ? Colors.green : Colors.grey),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isRecording 
                                        ? (_isPaused ? 'Paused' : 'Recording...')
                                        : (_hasRecording ? 'Recorded' : 'Ready'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _isRecording 
                                          ? (_isPaused ? Colors.orange : Colors.red)
                                          : (_hasRecording ? Colors.green : Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20), // Reduced spacing
                          
                          // Visual Audio Indicator
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Animated microphone icon
                                  AnimatedBuilder(
                                    animation: _pulseAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _isRecording && !_isPaused 
                                            ? _pulseAnimation.value 
                                            : 1.0,
                                        child: Container(
                                          width: 100, // Reduced size
                                          height: 100, // Reduced size
                                          decoration: BoxDecoration(
                                            color: _isRecording 
                                                ? (_isPaused ? Colors.orange : Colors.red)
                                                : (_hasRecording ? Colors.green : kPrimaryColor),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: (_isRecording 
                                                    ? (_isPaused ? Colors.orange : Colors.red)
                                                    : (_hasRecording ? Colors.green : kPrimaryColor))
                                                    // ignore: deprecated_member_use
                                                    .withOpacity(0.3),
                                                offset: const Offset(0, 4),
                                                blurRadius: 20,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            _hasRecording ? Icons.audiotrack : Icons.mic,
                                            color: Colors.white,
                                            size: 40, // Reduced size
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  
                                  const SizedBox(height: 20), // Reduced spacing
                                  
                                  // Audio level visualization
                                  if (_isRecording && !_isPaused)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(5, (index) {
                                        return AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                          width: 4,
                                          height: 20 + (_audioLevel * 40 * (index + 1) / 5),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        );
                                      }),
                                    ),
                                  
                                  const SizedBox(height: 16), // Reduced spacing
                                  
                                  // Status text
                                  Text(
                                    _isRecording 
                                        ? (_isPaused ? 'Recording paused' : 'Recording in progress...')
                                        : (_hasRecording ? 'Recording completed' : 'Ready to record'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  
                                  // Playback progress for recorded audio
                                  if (_hasRecording && !_isRecording)
                                    Column(
                                      children: [
                                        const SizedBox(height: 16), // Reduced spacing
                                        LinearProgressIndicator(
                                          value: _recordingDuration.inSeconds > 0
                                              ? _playbackPosition.inSeconds / _recordingDuration.inSeconds
                                              : 0.0,
                                          backgroundColor: Colors.grey[300],
                                          valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${_formatDuration(_playbackPosition)} / ${_formatDuration(_recordingDuration)}',
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
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Controls - Made more compact
                  Container(
                    padding: const EdgeInsets.all(12), // Reduced padding
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // SOLUTION 4: Use MainAxisSize.min
                      children: [
                        // Main Control Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Record/Stop Button
                            if (!_hasRecording || _isRecording)
                              GestureDetector(
                                onTap: _isRecording ? _stopRecording : _startRecording,
                                child: Container(
                                  width: 70, // Slightly reduced size
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: _isRecording ? Colors.red : kPrimaryColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_isRecording ? Colors.red : kPrimaryColor)
                                            // ignore: deprecated_member_use
                                            .withOpacity(0.3),
                                        offset: const Offset(0, 4),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isRecording ? Icons.stop : Icons.mic,
                                    color: Colors.white,
                                    size: 32, // Slightly reduced size
                                  ),
                                ),
                              ),
                            
                            // Pause/Resume Button (only during recording)
                            if (_isRecording)
                              GestureDetector(
                                onTap: _isPaused ? _resumeRecording : _pauseRecording,
                                child: Container(
                                  width: 55, // Slightly reduced size
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: _isPaused ? Colors.green : Colors.orange,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_isPaused ? Colors.green : Colors.orange)
                                            // ignore: deprecated_member_use
                                            .withOpacity(0.3),
                                        offset: const Offset(0, 4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isPaused ? Icons.play_arrow : Icons.pause,
                                    color: Colors.white,
                                    size: 26, // Slightly reduced size
                                  ),
                                ),
                              ),
                            
                            // Play/Stop Button (only when recording exists)
                            if (_hasRecording && !_isRecording)
                              GestureDetector(
                                onTap: _isPlaying ? _stopPlayback : _playRecording,
                                child: Container(
                                  width: 70, // Slightly reduced size
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: _isPlaying ? Colors.red : Colors.green,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: (_isPlaying ? Colors.red : Colors.green)
                                            // ignore: deprecated_member_use
                                            .withOpacity(0.3),
                                        offset: const Offset(0, 4),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isPlaying ? Icons.stop : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 32, // Slightly reduced size
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 8), // Reduced spacing
                        
                        // Button Labels
                        Text(
                          _isRecording 
                              ? 'Recording • Tap to stop'
                              : (_hasRecording 
                                  ? (_isPlaying ? 'Playing • Tap to stop' : 'Tap to play recording')
                                  : 'Tap to start recording'),
                          style: const TextStyle(
                            fontSize: 14, // Slightly smaller font
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16), // Reduced spacing
                        
                        // Action Buttons Row - Made more compact
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: Icons.save_outlined,
                              label: 'Save Draft',
                              onTap: () {
                                if (!_hasRecording) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No recording to save'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Recording saved as draft'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                            _buildActionButton(
                              icon: Icons.send,
                              label: 'Submit',
                              onTap: _submitRecording,
                            ),
                            _buildActionButton(
                              icon: Icons.translate,
                              label: 'Transcribe',
                              onTap: () {
                                if (!_hasRecording) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please record audio first'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Transcription feature coming soon'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min, // SOLUTION 5: Use MainAxisSize.min for buttons
        children: [
          Container(
            width: 45, // Slightly smaller
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(
              icon,
              color: kPrimaryColor,
              size: 22, // Slightly smaller
            ),
          ),
          const SizedBox(height: 6), // Reduced spacing
          Text(
            label,
            style: const TextStyle(
              fontSize: 11, // Slightly smaller font
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}