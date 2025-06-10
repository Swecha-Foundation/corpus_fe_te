import 'package:flutter/material.dart';
import 'package:flutter_auth/main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../constants.dart';

class PictureInputScreen extends StatefulWidget {
  final String? selectedCategory;

  const PictureInputScreen({
    Key? key,
    this.selectedCategory,
  }) : super(key: key);

  @override
  State<PictureInputScreen> createState() => _PictureInputScreenState();
}

class _PictureInputScreenState extends State<PictureInputScreen> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  bool _isProcessing = false;
  String _selectedLanguage = 'Telugu';
  int _captionWordCount = 0;

  @override
  void initState() {
    super.initState();
    _captionController.addListener(_updateCaptionWordCount);
  }

  @override
  void dispose() {
    _captionController.removeListener(_updateCaptionWordCount);
    _captionController.dispose();
    super.dispose();
  }

  void _updateCaptionWordCount() {
    final text = _captionController.text.trim();
    setState(() {
      _captionWordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  Future<void> _pickImageFromCamera() async {
    try {
      if (cameras.isNotEmpty) {
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

  void _processImages() {
    if (_selectedImages.isEmpty) {
      _showSnackBar('Please select at least one image', Colors.orange);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate processing time
    Future.delayed(const Duration(seconds: 2), () {
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
              Text('Images: ${_selectedImages.length}'),
              Text('Caption words: $_captionWordCount'),
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
        content: Text(
            'Content submitted successfully! (${_selectedImages.length} images)'),
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
          content: const Text(
              'Are you sure you want to clear all images and caption?'),
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
          if (_selectedImages.isNotEmpty || _captionController.text.isNotEmpty)
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
                        items:
                            ['Telugu', 'English', 'Hindi'].map((String value) {
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
                  const SizedBox(height: 4),
                  const Text(
                    'Select images and add captions to tell your story',
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
                    // Image Selection Buttons
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildImageSourceButton(
                              icon: Icons.camera_alt,
                              label: 'Take Photo',
                              onTap: _pickImageFromCamera,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildImageSourceButton(
                              icon: Icons.photo_library,
                              label: 'Choose from Gallery',
                              onTap: _pickImageFromGallery,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Selected Images Grid
                    if (_selectedImages.isNotEmpty) ...[
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
                                const Icon(Icons.photo, color: kPrimaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Selected Images (${_selectedImages.length}/10)',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, index) {
                                return Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(File(
                                              _selectedImages[index].path)),
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
                                          padding: const EdgeInsets.all(4),
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
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Caption Input
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
                              const Icon(Icons.edit, color: kPrimaryColor),
                              const SizedBox(width: 8),
                              const Text(
                                'Add Caption',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Words: $_captionWordCount',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _captionController,
                            maxLines: 4,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: _selectedLanguage == 'Telugu'
                                  ? 'మీ చిత్రాలకు వివరణ రాయండి...'
                                  : 'Write a caption for your images...',
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: kPrimaryColor),
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
                    onTap: _isProcessing ? null : _processImages,
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
                    _isProcessing
                        ? 'Processing images...'
                        : 'Tap to process & submit',
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
                        onTap: () => _showSnackBar(
                            'Draft saved successfully', Colors.green),
                      ),
                      _buildActionButton(
                        icon: Icons.auto_fix_high,
                        label: 'Auto Caption',
                        onTap: () => _showSnackBar(
                            'Auto caption feature coming soon', Colors.blue),
                      ),
                      _buildActionButton(
                        icon: Icons.palette,
                        label: 'Add Filter',
                        onTap: () => _showSnackBar(
                            'Filter feature coming soon', Colors.purple),
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

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
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
          ],
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
