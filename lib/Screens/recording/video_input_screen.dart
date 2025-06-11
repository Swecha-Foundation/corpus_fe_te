// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../constants.dart';

class VideoInputScreen extends StatefulWidget {
  final String? selectedCategory;
  
  const VideoInputScreen({
    Key? key,
    this.selectedCategory,
  }) : super(key: key);

  @override
  State<VideoInputScreen> createState() => _VideoInputScreenState();
}

class _VideoInputScreenState extends State<VideoInputScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedVideos = [];
  bool _isProcessing = false;
  String _selectedLanguage = 'Telugu';
  int _descriptionWordCount = 0;
  double _totalDuration = 0.0; // In seconds
  double _totalSize = 0.0; // In MB

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_updateDescriptionWordCount);
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_updateDescriptionWordCount);
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateDescriptionWordCount() {
    final text = _descriptionController.text.trim();
    setState(() {
      _descriptionWordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
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
      _totalSize += sizeInMB;
      // Estimate duration (would need video_player package for accurate duration)
      _totalDuration += 30; // Placeholder - in real app, get actual duration
    });
  }

  void _removeVideo(int index) {
    final file = File(_selectedVideos[index].path);
    file.length().then((sizeInBytes) {
      final sizeInMB = sizeInBytes / (1024 * 1024);
      setState(() {
        _selectedVideos.removeAt(index);
        _totalSize -= sizeInMB;
        _totalDuration -= 30; // Placeholder
      });
    });
    _showSnackBar('Video removed', Colors.grey);
  }

  void _processVideos() {
    if (_selectedVideos.isEmpty) {
      _showSnackBar('Please select at least one video', Colors.orange);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate processing time (longer for videos)
    Future.delayed(const Duration(seconds: 4), () {
      setState(() {
        _isProcessing = false;
      });
      _showSubmitDialog();
    });
  }

  void _showSubmitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Submit Content'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Videos: ${_selectedVideos.length}'),
              Text('Total size: ${_totalSize.toStringAsFixed(1)} MB'),
              Text('Estimated duration: ${_formatDuration(_totalDuration)}'),
              Text('Description words: $_descriptionWordCount'),
              Text('Language: $_selectedLanguage'),
              if (widget.selectedCategory != null)
                Text('Category: ${widget.selectedCategory}'),
              const SizedBox(height: 16),
              const Text('Are you ready to submit your content?'),
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
                _submitContent();
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

  void _submitContent() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Content submitted successfully! (${_selectedVideos.length} videos)'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
    
    Navigator.pop(context);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All'),
          content: const Text('Are you sure you want to clear all videos and description?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedVideos.clear();
                  _descriptionController.clear();
                  _totalDuration = 0.0;
                  _totalSize = 0.0;
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

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = (seconds % 60).floor();
    return '${minutes}m ${remainingSeconds}s';
  }

  String _formatFileSize(double sizeInMB) {
    if (sizeInMB < 1) {
      return '${(sizeInMB * 1024).toStringAsFixed(0)} KB';
    }
    return '${sizeInMB.toStringAsFixed(1)} MB';
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
          'Video Input',
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_selectedVideos.isNotEmpty || _descriptionController.text.isNotEmpty)
            IconButton(
              onPressed: _clearAll,
              icon: const Icon(Icons.clear, color: Colors.red),
            ),
        ],
      ),
      body: SafeArea(
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
                    'Share your video story',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Record or select videos and add descriptions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Video Selection Buttons
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildVideoSourceButton(
                              icon: Icons.videocam,
                              label: 'Record Video',
                              subtitle: 'Max 5 min',
                              onTap: _recordVideo,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildVideoSourceButton(
                              icon: Icons.video_library,
                              label: 'Choose from Gallery',
                              subtitle: 'Max 10 min',
                              onTap: _pickVideoFromGallery,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Storage Info Bar
                    if (_selectedVideos.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              kPrimaryColor.withOpacity(0.1),
                              kPrimaryColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoItem(
                              icon: Icons.video_collection,
                              value: '${_selectedVideos.length}/3',
                              label: 'Videos',
                            ),
                            _buildInfoItem(
                              icon: Icons.storage,
                              value: _formatFileSize(_totalSize),
                              label: 'Total Size',
                            ),
                            _buildInfoItem(
                              icon: Icons.timer,
                              value: _formatDuration(_totalDuration),
                              label: 'Duration',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Selected Videos List
                    if (_selectedVideos.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
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
                                const Icon(Icons.video_file, color: kPrimaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Selected Videos (${_selectedVideos.length}/3)',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _selectedVideos.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildVideoItem(index);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Description Input
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                              const Icon(Icons.description, color: kPrimaryColor),
                              const SizedBox(width: 8),
                              const Text(
                                'Add Description',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Words: $_descriptionWordCount',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 5,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: _selectedLanguage == 'Telugu' 
                                  ? 'మీ వీడియోలకు వివరణ రాయండి...'
                                  : 'Write a description for your videos...',
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: kPrimaryColor),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Controls
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Process Button
                  GestureDetector(
                    onTap: _isProcessing ? null : _processVideos,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isProcessing ? Colors.grey : kPrimaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isProcessing ? Colors.grey : kPrimaryColor)
                                .withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            )
                          : const Icon(
                              Icons.cloud_upload,
                              color: Colors.white,
                              size: 36,
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isProcessing ? 'Processing videos...' : 'Tap to process & submit',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.save_outlined,
                        label: 'Save Draft',
                        onTap: () => _showSnackBar('Draft saved successfully', Colors.green),
                      ),
                      _buildActionButton(
                        icon: Icons.auto_awesome,
                        label: 'Auto Subtitle',
                        onTap: () => _showSnackBar('Auto subtitle feature coming soon', Colors.blue),
                      ),
                      _buildActionButton(
                        icon: Icons.tune,
                        label: 'Edit Video',
                        onTap: () => _showSnackBar('Video editing feature coming soon', Colors.purple),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSourceButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: kPrimaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: kPrimaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoItem(int index) {
    final video = _selectedVideos[index];
    final file = File(video.path);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Video Thumbnail Placeholder
          Container(
            width: 60,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.play_circle_filled,
              color: kPrimaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Video Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Video ${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                FutureBuilder<int>(
                  future: file.length(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final sizeInMB = snapshot.data! / (1024 * 1024);
                      return Text(
                        '${_formatFileSize(sizeInMB)} • 30s', // Placeholder duration
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      );
                    }
                    return const Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Remove Button
          GestureDetector(
            onTap: () => _removeVideo(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
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
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Icon(
              icon,
              color: kPrimaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
           style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}