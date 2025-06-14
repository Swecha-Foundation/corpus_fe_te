import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../constants.dart';
import '../../services/api_service.dart';

class TextInputScreen extends StatefulWidget {
  final String? selectedCategory;
  
  const TextInputScreen({
    Key? key,
    this.selectedCategory,
  }) : super(key: key);

  @override
  State<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isRecording = false;
  bool _isUploading = false;
  int _wordCount = 0;
  int _characterCount = 0;
  String _selectedLanguage = 'Telugu';
  
  // API related variables
  String? _currentRecordId;
  File? _textFile;
  String _userId = 'user123'; // Replace with actual user ID from your auth system
  DateTime? _recordingStartTime;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateCounts);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateCounts);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateCounts() {
    final text = _textController.text;
    setState(() {
      _characterCount = text.length;
      _wordCount = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    });
  }

  Future<void> _startRecording() async {
    if (_textController.text.trim().isNotEmpty) {
      // Ask user if they want to clear existing text
      final shouldClear = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Existing Text Found'),
            content: const Text('You have existing text. Do you want to clear it and start fresh?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep Text'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Clear & Start Fresh'),
              ),
            ],
          );
        },
      );
      
      if (shouldClear == true) {
        _textController.clear();
      }
    }

    setState(() {
      _isRecording = true;
      _recordingStartTime = DateTime.now();
      _currentRecordId = null;
    });
    
    // Focus on text field
    _focusNode.requestFocus();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Started text input session...'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _stopRecording() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text before stopping'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isRecording = false;
    });
    
    // Create text file
    await _createTextFile();
    
    _showSubmitDialog();
  }

  Future<void> _createTextFile() async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName = 'text_${DateTime.now().millisecondsSinceEpoch}.txt';
      _textFile = File('${directory.path}/$fileName');
      
      // Write text content to file
      await _textFile!.writeAsString(_textController.text);
    } catch (e) {
      print('Error creating text file: $e');
    }
  }

  void _showSubmitDialog() {
    final duration = _recordingStartTime != null 
        ? DateTime.now().difference(_recordingStartTime!)
        : Duration.zero;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Submit Text'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Word count: $_wordCount'),
              Text('Character count: $_characterCount'),
              Text('Language: $_selectedLanguage'),
              Text('Duration: ${_formatDuration(duration)}'),
              if (widget.selectedCategory != null)
                Text('Category: ${widget.selectedCategory}'),
              const SizedBox(height: 16),
              const Text('This will create a record and upload your text. Continue?'),
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
      final createResult = await ApiService.createRecord(
        title: 'Text Input - ${DateTime.now().toString()}',
        description: 'Text content in $_selectedLanguage language ($_wordCount words)',
        categoryId: widget.selectedCategory ?? 'general',
        userId: _userId,
        mediaType: 'text',
      );

      if (createResult['success']) {
        _currentRecordId = createResult['data']['id'];
        
        // Step 2: Upload text file if it exists
        if (_textFile != null && _textFile!.existsSync()) {
          final uploadResult = await ApiService.uploadRecord(
            recordId: _currentRecordId!,
            file: _textFile!,
            description: 'Text content in $_selectedLanguage ($_wordCount words, $_characterCount characters)',
          );

          if (!uploadResult['success']) {
            throw Exception(uploadResult['error']);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Text submitted successfully! ($_wordCount words)',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Navigate back to previous screen
        Navigator.pop(context);
      } else {
        throw Exception(createResult['error']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit text: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _createRecord() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Create text file first
      await _createTextFile();
      
      // Create record
      final createResult = await ApiService.createRecord(
        title: 'Text Input - ${DateTime.now().toString()}',
        description: 'Text content in $_selectedLanguage language',
        categoryId: widget.selectedCategory ?? 'general',
        userId: _userId,
        mediaType: 'text',
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

  Future<void> _uploadText() async {
    if (_textFile == null || _currentRecordId == null) {
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
        file: _textFile!,
        description: 'Text content in $_selectedLanguage ($_wordCount words)',
      );

      if (uploadResult['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(uploadResult['error']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload text: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _saveDraft() {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No text to save'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // TODO: Implement local storage for drafts
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved locally'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearText() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Text'),
          content: const Text('Are you sure you want to clear all text?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _textController.clear();
                  _isRecording = false;
                  _currentRecordId = null;
                  _recordingStartTime = null;
                });
                
                // Delete local file if it exists
                if (_textFile != null && _textFile!.existsSync()) {
                  _textFile!.deleteSync();
                }
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
          'Text Input',
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_textController.text.isNotEmpty)
            IconButton(
              onPressed: _clearText,
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
                    'Share your thoughts in text',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Type your content below and tap record when ready',
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

            // Text Input Area
            Expanded(
              child: Container(
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
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Words: $_wordCount',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Characters: $_characterCount',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
                                _isRecording ? Icons.fiber_manual_record : Icons.edit,
                                color: _isRecording ? Colors.red : Colors.grey,
                                size: 16,
                              ),
                            const SizedBox(width: 4),
                            Text(
                              _isRecording ? 'Recording...' : 'Ready to type',
                              style: TextStyle(
                                fontSize: 14,
                                color: _isRecording ? Colors.red : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Text Input Field
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: _selectedLanguage == 'Telugu' 
                              ? 'మీ ఆలోచనలను ఇక్కడ వ్రాయండి...'
                              : 'Start typing your thoughts here...',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(0),
                        ),
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
                  // Recording Button
                  GestureDetector(
                    onTap: _isUploading ? null : (_isRecording ? _stopRecording : _startRecording),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : kPrimaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.red : kPrimaryColor)
                                .withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isRecording ? 'Tap to stop & submit' : 'Tap to start recording',
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
                        icon: Icons.cloud_upload,
                        label: 'Create Record',
                        onTap: _currentRecordId == null ? _createRecord : null,
                        isEnabled: _currentRecordId == null && _textController.text.trim().isNotEmpty,
                      ),
                      _buildActionButton(
                        icon: Icons.upload_file,
                        label: 'Upload Text',
                        onTap: _currentRecordId != null && _textFile != null ? _uploadText : null,
                        isEnabled: _currentRecordId != null && _textFile != null,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Submit Button
                  if (_textController.text.trim().isNotEmpty && !_isRecording)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _handleSubmit,
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
                                'Submit Text',
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
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isEnabled ? Colors.grey[100] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnabled ? Colors.grey[300]! : Colors.grey[200]!,
              ),
            ),
            child: Icon(
              icon,
              color: isEnabled ? kPrimaryColor : Colors.grey[400],
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isEnabled ? Colors.grey : Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}