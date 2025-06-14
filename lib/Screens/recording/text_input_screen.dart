// ignore_for_file: deprecated_member_use, use_build_context_synchronously

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
  bool _isUploading = false;
  int _wordCount = 0;
  int _characterCount = 0;
  String _selectedLanguage = 'Telugu';

  // API related variables
  File? _textFile;
  String _userId =
      'user123'; 

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
      _wordCount =
          text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    });
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

  Future<void> _handleSubmit() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Step 1: Create text file
      await _createTextFile();

      // Step 2: Create record
      final createResult = await ApiService.createRecord(
        title: 'Text Input - ${DateTime.now().toString()}',
        description:
            'Text content in $_selectedLanguage language ($_wordCount words)',
        categoryId: widget.selectedCategory ?? 'general',
        userId: _userId,
        mediaType: 'text',
      );

      if (createResult['success']) {
        final recordId = createResult['data']['id'];

        // Step 3: Upload text file if it exists
        if (_textFile != null && _textFile!.existsSync()) {
          final uploadResult = await ApiService.uploadRecord(
            recordId: recordId,
            file: _textFile!,
            description:
                'Text content in $_selectedLanguage ($_wordCount words, $_characterCount characters)',
          );

          if (!uploadResult['success']) {
            throw Exception(uploadResult['error']);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Text submitted successfully! ($_wordCount words)'),
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
                      Flexible(
                        child: Container(
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
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                    'Type your content below and submit when ready',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
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
                        Text(
                          'Words: $_wordCount | Characters: $_characterCount',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Language: $_selectedLanguage',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
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

            // Submit Button
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
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
            ),
          ],
        ),
      ),
    );
  }
}