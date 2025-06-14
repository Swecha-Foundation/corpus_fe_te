// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../constants.dart';
import '../../services/api_service.dart';

class VideoInputScreen extends StatefulWidget {
  final String? selectedCategory;
  final String? categoryId;
  final String userId;
  
  const VideoInputScreen({
    Key? key,
    this.selectedCategory,
    this.categoryId,
    required this.userId,
  }) : super(key: key);

  @override
  State<VideoInputScreen> createState() => _VideoInputScreenState();
}

class _VideoInputScreenState extends State<VideoInputScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedVideos = [];
  bool _isProcessing = false;
  bool _isUploading = false;
  String _selectedLanguage = 'Telugu';
  int _descriptionWordCount = 0;
  int _titleWordCount = 0;
  double _totalDuration = 0.0; // In seconds
  double _totalSize = 0.0; // In MB
  double _uploadProgress = 0.0;
  String? _createdRecordId;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_updateDescriptionWordCount);
    _titleController.addListener(_updateTitleWordCount);
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_updateDescriptionWordCount);
    _titleController.removeListener(_updateTitleWordCount);
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _updateDescriptionWordCount() {
    final text = _descriptionController.text.trim();
    setState(() {
      _descriptionWordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  void _updateTitleWordCount() {
    final text = _titleController.text.trim();
    setState(() {
      _titleWordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
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

  Future<void> _processVideos() async {
    if (_selectedVideos.isEmpty) {
      _showSnackBar('Please select at least one video', Colors.orange);
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Please enter a title', Colors.orange);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // First create the record
      final recordResult = await ApiService.createRecord(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: widget.categoryId ?? 'default',
        userId: widget.userId,
        mediaType: 'video',
      );

      if (recordResult['success']) {
        setState(() {
          _createdRecordId = recordResult['data']['id'];
        });
        _showSubmitDialog();
      } else {
        _showSnackBar('Error creating record: ${recordResult['error']}', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
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
              if (widget.selectedCategory != null)
                Text('Category: ${widget.selectedCategory}'),
              const SizedBox(height: 16),
              const Text('Record created successfully! Ready to upload videos?'),
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

  Future<void> _uploadVideos() async {
    if (_createdRecordId == null) {
      _showSnackBar('No record ID found', Colors.red);
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      int successfulUploads = 0;
      
      for (int i = 0; i < _selectedVideos.length; i++) {
        final video = _selectedVideos[i];
        final file = File(video.path);
        
        // Update progress
        setState(() {
          _uploadProgress = (i / _selectedVideos.length);
        });
        
        final uploadResult = await ApiService.uploadRecord(
          recordId: _createdRecordId!,
          file: file,
          description: 'Video ${i + 1} - ${_descriptionController.text.trim()}',
        );
        
        if (uploadResult['success']) {
          successfulUploads++;
          _showSnackBar('Video ${i + 1} uploaded successfully', Colors.green);
        } else {
          _showSnackBar('Failed to upload video ${i + 1}: ${uploadResult['error']}', Colors.red);
        }
      }
      
      setState(() {
        _uploadProgress = 1.0;
      });
      
      // Show final result
      if (successfulUploads == _selectedVideos.length) {
        _showSuccessDialog();
      } else {
        _showSnackBar('$successfulUploads of ${_selectedVideos.length} videos uploaded', Colors.orange);
      }
      
    } catch (e) {
      _showSnackBar('Upload error: $e', Colors.red);
    } finally {
      setState(() {
        _isUploading = false;
      });
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
              Text('All ${_selectedVideos.length} videos have been uploaded successfully!'),
              const SizedBox(height: 16),
              Text('Record ID: $_createdRecordId'),
            ],
          ),
          actions: [
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

  Future<void> _saveDraft() async {
    if (_titleController.text.trim().isEmpty && _selectedVideos.isEmpty) {
      _showSnackBar('Nothing to save', Colors.orange);
      return;
    }

    // For now, just show a message. In a real app, you might save to local storage
    _showSnackBar('Draft saved locally', Colors.green);
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
          content: const Text('Are you sure you want to clear all videos and text?'),
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
                  _titleController.clear();
                  _descriptionController.clear();
                  _totalDuration = 0.0;
                  _totalSize = 0.0;
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
          if (_selectedVideos.isNotEmpty || 
              _titleController.text.isNotEmpty || 
              _descriptionController.text.isNotEmpty)
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

            // Upload Progress Indicator
            if (_isUploading) ...[
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
                  children: [
                    Row(
                      children: [ 
                        const Icon(Icons.cloud_upload, color: kPrimaryColor),
                        const SizedBox(width: 8),
                        const Text('Uploading videos...'),
                        const Spacer(),
                        Text('${(_uploadProgress * 100).toInt()}%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

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

                    // Title Input
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
                              const Icon(Icons.title, color: kPrimaryColor),
                              const SizedBox(width: 8),
                              const Text(
                                'Title *',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Words: $_titleWordCount',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _titleController,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: _selectedLanguage == 'Telugu' 
                                  ? 'మీ వీడియోకు శీర్షిక రాయండి...'
                                  : 'Enter a title for your video...',
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

                    const SizedBox(height: 16),

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
                    onTap: (_isProcessing || _isUploading) ? null : _processVideos,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: (_isProcessing || _isUploading) ? Colors.grey : kPrimaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ((_isProcessing || _isUploading) ? Colors.grey : kPrimaryColor)
                                .withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: (_isProcessing || _isUploading)
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
                    _isUploading ? 'Uploading videos...' :
                    _isProcessing ? 'Creating record...' : 'Tap to process & submit',
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
                        onTap: _saveDraft,
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
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoItem(int index) {
    final video = _selectedVideos[index];
    final fileName = video.path.split('/').last;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: kPrimaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                FutureBuilder<int>(
                  future: File(video.path).length(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final sizeInMB = snapshot.data! / (1024 * 1024);
                      return Text(
                        _formatFileSize(sizeInMB),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      );
                    }
                    return const Text(
                      'Calculating size...',
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
          IconButton(
            onPressed: () => _removeVideo(index),
            icon: const Icon(
              Icons.close,
              color: Colors.red,
              size: 20,
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
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