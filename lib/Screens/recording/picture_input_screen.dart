// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../../constants.dart';
import '../../services/api_service.dart';
import '../../services/token_storage_service.dart'; // Add this import

class PictureInputScreen extends StatefulWidget {
  final String? selectedCategory;
  final String? categoryId;
  final String? userId;
  
  const PictureInputScreen({
    Key? key,
    this.selectedCategory,
    this.categoryId,
    this.userId,
  }) : super(key: key);

  @override
  State<PictureInputScreen> createState() => _PictureInputScreenState();
}

class _PictureInputScreenState extends State<PictureInputScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  List<XFile> _selectedImages = [];
  bool _isProcessing = false;
  bool _isUploading = false;
  bool _isLoadingLocation = false;
  String _selectedLanguage = 'Telugu';
  int _captionWordCount = 0;
  String? _createdRecordId;
  String? _currentUserId;
  
  // Location variables
  double? _currentLatitude;
  double? _currentLongitude;
  String _locationStatus = 'Location not available';

  @override
  void initState() {
    super.initState();
    _captionController.addListener(_updateCaptionWordCount);
    _getCurrentLocation();
    _loadUserData();
  }

  @override
  void dispose() {
    _captionController.removeListener(_updateCaptionWordCount);
    _captionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // Load user data from storage
  Future<void> _loadUserData() async {
    try {
      _currentUserId = await TokenStorageService.getUserId();
      if (_currentUserId == null) {
        _showSnackBar('User not authenticated. Please login again.', Colors.red);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void _updateCaptionWordCount() {
    final text = _captionController.text.trim();
    setState(() {
      _captionWordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  // Location Services
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = 'Getting location...';
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
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
          setState(() {
            _locationStatus = 'Location permissions are denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'Location permissions are permanently denied';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
        _locationStatus = 'Location: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _isLoadingLocation = false;
      });

      _showSnackBar('Location obtained successfully', Colors.green);
    } catch (e) {
      setState(() {
        _locationStatus = 'Failed to get location: $e';
        _isLoadingLocation = false;
      });
      _showSnackBar('Failed to get location: $e', Colors.red);
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (photo != null) {
        setState(() {
          _selectedImages.add(photo);
        });
        _showSnackBar('Photo captured successfully!', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Error capturing photo: $e', Colors.red);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
          // Limit to 10 images
          if (_selectedImages.length > 10) {
            _selectedImages = _selectedImages.take(10).toList();
            _showSnackBar('Maximum 10 images allowed', Colors.orange);
          }
        });
        _showSnackBar('${images.length} image(s) selected', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Error selecting images: $e', Colors.red);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    _showSnackBar('Image removed', Colors.grey);
  }

  Future<void> _processImages() async {
    if (_selectedImages.isEmpty) {
      _showSnackBar('Please select at least one image', Colors.orange);
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showSnackBar('Please enter a title', Colors.orange);
      return;
    }

    // Check authentication
    final isAuthenticated = await TokenStorageService.isAuthenticated();
    if (!isAuthenticated) {
      _showSnackBar('Please login again to continue', Colors.red);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Get file info from first image for the record
      final firstImage = File(_selectedImages.first.path);
      final fileSize = await firstImage.length();
      final fileName = _selectedImages.first.name;

      // Use the stored user ID or fallback to widget parameter
      final userId = _currentUserId ?? widget.userId ?? 'default_user';

      // Create a record with proper schema
      final recordResponse = await ApiService.createRecord(
        title: _titleController.text.trim(),
        description: _captionController.text.trim(),
        categoryId: widget.categoryId ?? '1',
        userId: userId,
        mediaType: 'image',
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        fileName: fileName,
        fileSize: fileSize,
      );

      if (recordResponse['success'] == true) {
        // Extract record ID from response
        final responseData = recordResponse['data'];
        _createdRecordId = responseData['id']?.toString() ?? 
                          responseData['record_id']?.toString();
        
        setState(() {
          _isProcessing = false;
        });
        _showSubmitDialog();
      } else {
        setState(() {
          _isProcessing = false;
        });
        
        // Handle authentication errors specifically
        if (recordResponse['error']?.toString().toLowerCase().contains('authenticated') == true) {
          _showSnackBar('Session expired. Please login again.', Colors.red);
        } else {
          _showSnackBar(
            recordResponse['message'] ?? 'Failed to create record',
            Colors.red,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showSnackBar('Error processing: $e', Colors.red);
    }
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
              Text('Title: ${_titleController.text.trim()}'),
              Text('Images: ${_selectedImages.length}'),
              Text('Caption words: $_captionWordCount'),
              Text('Language: $_selectedLanguage'),
              if (widget.selectedCategory != null)
                Text('Category: ${widget.selectedCategory}'),
              if (_currentLatitude != null && _currentLongitude != null)
                Text('Location: ${_currentLatitude!.toStringAsFixed(4)}, ${_currentLongitude!.toStringAsFixed(4)}'),
              const SizedBox(height: 16),
              const Text('Are you ready to upload your images?'),
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
                _uploadImages();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadImages() async {
    if (_createdRecordId == null) {
      _showSnackBar('No record created. Please try again.', Colors.red);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    int successCount = 0;
    int failureCount = 0;

    for (int i = 0; i < _selectedImages.length; i++) {
      try {
        final file = File(_selectedImages[i].path);
        final uploadResponse = await ApiService.uploadRecord(
          recordId: _createdRecordId!,
          file: file,
          description: 'Image ${i + 1} - ${_captionController.text.trim()}',
        );

        if (uploadResponse['success'] == true) {
          successCount++;
        } else {
          failureCount++;
          print('Upload failed for image $i: ${uploadResponse['message']}');
        }
      } catch (e) {
        failureCount++;
        print('Upload error for image $i: $e');
      }
    }

    setState(() {
      _isUploading = false;
    });

    if (successCount > 0) {
      _showSnackBar(
        'Successfully uploaded $successCount/${_selectedImages.length} images',
        failureCount > 0 ? Colors.orange : Colors.green,
      );
      
      if (failureCount == 0) {
        // All images uploaded successfully, navigate back
        Future.delayed(const Duration(seconds: 2), () {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        });
      }
    } else {
      _showSnackBar('Failed to upload images. Please try again.', Colors.red);
    }
  }

  Future<void> _saveDraft() async {
    if (_titleController.text.trim().isEmpty && 
        _captionController.text.trim().isEmpty && 
        _selectedImages.isEmpty) {
      _showSnackBar('Nothing to save', Colors.orange);
      return;
    }

    // Check authentication
    final isAuthenticated = await TokenStorageService.isAuthenticated();
    if (!isAuthenticated) {
      _showSnackBar('Please login again to save draft', Colors.red);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Use the stored user ID or fallback to widget parameter
      final userId = _currentUserId ?? widget.userId ?? 'default_user';
      
      final recordResponse = await ApiService.createRecord(
        title: _titleController.text.trim().isEmpty 
            ? 'Draft - ${DateTime.now().toString().substring(0, 16)}' 
            : 'Draft - ${_titleController.text.trim()}',
        description: _captionController.text.trim(),
        categoryId: widget.categoryId ?? '1',
        userId: userId,
        mediaType: 'image',
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        fileName: 'draft',
        fileSize: 0,
      );

      setState(() {
        _isProcessing = false;
      });

      if (recordResponse['success'] == true) {
        _showSnackBar('Draft saved successfully', Colors.green);
      } else {
        _showSnackBar('Failed to save draft', Colors.red);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showSnackBar('Error saving draft: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _clearAll() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All'),
          content: const Text('Are you sure you want to clear all content?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedImages.clear();
                  _captionController.clear();
                  _titleController.clear();
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
          'Picture Input',
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_selectedImages.isNotEmpty || 
              _captionController.text.isNotEmpty ||
              _titleController.text.isNotEmpty)
            IconButton(
              onPressed: _clearAll,
              icon: const Icon(Icons.clear, color: Colors.red),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Info with Location
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
                    'Share your visual story',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _isLoadingLocation 
                            ? Icons.location_searching 
                            : (_currentLatitude != null 
                                ? Icons.location_on 
                                : Icons.location_off),
                        size: 16,
                        color: _isLoadingLocation 
                            ? Colors.orange 
                            : (_currentLatitude != null 
                                ? Colors.green 
                                : Colors.red),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _locationStatus,
                          style: TextStyle(
                            fontSize: 12,
                            color: _isLoadingLocation 
                                ? Colors.orange 
                                : (_currentLatitude != null 
                                    ? Colors.green 
                                    : Colors.red),
                          ),
                        ),
                      ),
                      if (_isLoadingLocation)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                          ),
                        )
                      else if (_currentLatitude == null)
                        IconButton(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.refresh, size: 16),
                          color: kPrimaryColor,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Input
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter a catchy title for your post',
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        maxLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),

                    // Image Selection Section
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                              const Icon(Icons.photo_camera, 
                                  color: kPrimaryColor, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Add Images',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_selectedImages.length}/10',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Image Selection Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _pickImageFromCamera,
                                  icon: const Icon(Icons.camera_alt),
                                  label: const Text('Camera'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPrimaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickImageFromGallery,
                                  icon: const Icon(Icons.photo_library),
                                  label: const Text('Gallery'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: kPrimaryColor,
                                    side: const BorderSide(color: kPrimaryColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Selected Images Grid
                          if (_selectedImages.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            Text(
                              'Selected Images (${_selectedImages.length})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(File(_selectedImages[index].path)),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Caption Input
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                              const Icon(Icons.edit_note, 
                                  color: kPrimaryColor, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Caption',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$_captionWordCount words',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _captionController,
                            decoration: const InputDecoration(
                              hintText: 'Share your thoughts, story, or context...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            maxLines: 6,
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
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
              child: Row(
                children: [
                  // Save Draft Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isProcessing || _isUploading ? null : _saveDraft,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryColor,
                        side: const BorderSide(color: kPrimaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isProcessing && !_isUploading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                              ),
                            )
                          : const Text('Save Draft'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Process/Upload Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isProcessing || _isUploading 
                          ? null 
                          : (_createdRecordId != null ? _uploadImages : _processImages),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                                SizedBox(width: 8),
                                Text('Uploading...'),
                              ],
                            )
                          : _isProcessing
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
                                    SizedBox(width: 8),
                                    Text('Processing...'),
                                  ],
                                )
                              : Text(_createdRecordId != null ? 'Upload Images' : 'Process & Upload'),
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
}