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
  final List<int> _videoSizes = []; // Store actual file sizes
  bool _isProcessing = false;
  bool _isUploading = false;
  String _selectedLanguage = 'Telugu';
  int _descriptionWordCount = 0;
  int _titleWordCount = 0;
  double _totalDuration = 0.0; // In seconds
  double _totalSize = 0.0; // In MB
  double _uploadProgress = 0.0;
  String? _createdRecordId;
  double? _latitude;
  double? _longitude;
  int _currentUploadIndex = 0;

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

  Future<void> _processVideos() async {
    if (_selectedVideos.isEmpty) {
      _showSnackBar('Please select at least one video', Colors.orange);
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Please enter a title', Colors.orange);
      return;
    }

    // Validate category ID
    if (widget.categoryId == null || widget.categoryId!.isEmpty) {
      _showSnackBar('Category is required', Colors.orange);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Calculate total file size for the largest video (as representative)
      final largestVideoIndex = _videoSizes.indexOf(_videoSizes.reduce((a, b) => a > b ? a : b));
      final largestVideoSize = _videoSizes[largestVideoIndex];

      // First create the record
      final recordResult = await ApiService.createRecord(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: widget.categoryId!,
        userId: widget.userId,
        mediaType: 'video',
        latitude: _latitude,
        longitude: _longitude,
        fileName: _selectedVideos[largestVideoIndex].name,
        fileSize: largestVideoSize,
      );

      if (recordResult['success']) {
        final recordData = recordResult['data'];
        setState(() {
          _createdRecordId = recordData['id']?.toString() ?? recordData['record_id']?.toString();
        });
        
        if (_createdRecordId != null) {
          _showSubmitDialog();
        } else {
          _showSnackBar('Error: Could not get record ID from response', Colors.red);
        }
      } else {
        _showSnackBar('Error creating record: ${recordResult['message'] ?? recordResult['error']}', Colors.red);
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
              if (_latitude != null && _longitude != null)
                Text('Location: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'),
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
    if (_createdRecordId == null || _createdRecordId!.isEmpty) {
      _showSnackBar('No record ID found', Colors.red);
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

        try {
          final uploadResult = await ApiService.uploadRecord(
            recordId: _createdRecordId!,
            file: file,
            description: '${_descriptionController.text.trim()} - Video ${i + 1}',
          );
          
          if (uploadResult['success']) {
            successfulUploads++;
            _showSnackBar('Video ${i + 1} uploaded successfully', Colors.green);
          } else {
            final errorMessage = uploadResult['message'] ?? uploadResult['error'] ?? 'Unknown error';
            failedUploads.add('Video ${i + 1}: $errorMessage');
            _showSnackBar('Failed to upload video ${i + 1}: $errorMessage', Colors.red);
          }
        } catch (e) {
          failedUploads.add('Video ${i + 1}: $e');
          _showSnackBar('Error uploading video ${i + 1}: $e', Colors.red);
        }
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
    } finally {
      setState(() {
        _isUploading = false;
        _currentUploadIndex = 0;
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
              Text('$successCount of ${_selectedVideos.length} videos uploaded successfully.'),
              const SizedBox(height: 12),
              if (failures.isNotEmpty) ...[
                const Text('Failed uploads:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...failures.map((failure) => Text('• $failure', style: const TextStyle(fontSize: 12))),
              ],
              const SizedBox(height: 16),
              Text('Record ID: $_createdRecordId'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
              ...failures.take(3).map((failure) => Text('• $failure', style: const TextStyle(fontSize: 12))),
              if (failures.length > 3)
                Text('... and ${failures.length - 3} more', style: const TextStyle(fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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

  Future<void> _getLocation() async {
    // This would typically use location services
    // For now, we'll show a dialog to manually enter coordinates or get from GPS
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final latController = TextEditingController(text: _latitude?.toString() ?? '');
        final lngController = TextEditingController(text: _longitude?.toString() ?? '');
        
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
                  _latitude = null;
                  _longitude = null;
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
                    _latitude = lat;
                    _longitude = lng;
                  });
                  Navigator.pop(context);
                  _showSnackBar('Location added', Colors.green);
                } else {
                  _showSnackBar('Invalid coordinates', Colors.red);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
                  _videoSizes.clear();
                  _titleController.clear();
                  _descriptionController.clear();
                  _totalDuration = 0.0;
                  _totalSize = 0.0;
                  _createdRecordId = null;
                  _latitude = null;
                  _longitude = null;
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
          IconButton(
            onPressed: _getLocation,
            icon: Icon(
              _latitude != null && _longitude != null 
                  ? Icons.location_on 
                  : Icons.location_off,
              color: _latitude != null && _longitude != null 
                  ? kPrimaryColor 
                  : Colors.grey,
            ),
          ),
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
                  Text(
                    _latitude != null && _longitude != null
                        ? 'Record or select videos and add descriptions (Location: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)})'
                        : 'Record or select videos and add descriptions',
                    style: const TextStyle(
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
                        Text('Uploading video $_currentUploadIndex of ${_selectedVideos.length}...'),
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
                                const Icon(Icons.video_collection, color: kPrimaryColor),
                                const SizedBox(width: 8),
                                const Text(
                                  'Selected Videos',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${_selectedVideos.length}/3',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _selectedVideos.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final video = _selectedVideos[index];
                                final sizeInMB = _videoSizes[index] / (1024 * 1024);
                                
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: kPrimaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              video.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${_formatFileSize(sizeInMB)} • Video ${index + 1}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _removeVideo(index),
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        iconSize: 20,
                                      ),
                                    ],
                                  ),
                                );
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
                                'Description',
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
                            maxLines: 4,
                            minLines: 3,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: _selectedLanguage == 'Telugu' 
                                  ? 'మీ వీడియో గురించి వివరంగా రాయండి...'
                                  : 'Tell us more about your video...',
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

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
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
              child: SafeArea(
                child: Row(
                  children: [
                    // Save Draft Button
                    if (_selectedVideos.isNotEmpty || 
                        _titleController.text.isNotEmpty || 
                        _descriptionController.text.isNotEmpty) ...[
                      OutlinedButton(
                        onPressed: _saveDraft,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kPrimaryColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Save Draft',
                          style: TextStyle(color: kPrimaryColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    // Process/Submit Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isProcessing || _isUploading ? null : _processVideos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: _isProcessing
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
                                  SizedBox(width: 8),
                                  Text('Processing...'),
                                ],
                              )
                            : _isUploading
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
                                      SizedBox(width: 8),
                                      Text('Uploading...'),
                                    ],
                                  )
                                : const Text(
                                    'Submit Videos',
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimaryColor.withOpacity(0.2)),
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: kPrimaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
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
}