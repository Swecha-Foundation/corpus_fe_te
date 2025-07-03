// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants.dart';
import '../../services/api_service.dart';
import '../../services/uuid_service.dart';
import '../../services/token_storage_service.dart';

class TextInputScreen extends StatefulWidget {
  final String? selectedCategory;
  final String? selectedCategoryId;
  final bool isEnglish;

  const TextInputScreen({
    Key? key,
    this.selectedCategory,
    this.selectedCategoryId,
    required this.isEnglish,
  }) : super(key: key);

  @override
  State<TextInputScreen> createState() => _TextInputScreenState();
}

class _TextInputScreenState extends State<TextInputScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _textFocusNode = FocusNode();

  bool _isUploading = false;
  bool _isInitializing = true;
  int _wordCount = 0;
  int _characterCount = 0;
  int _titleWordCount = 0;
  String _selectedLanguage = 'Telugu';

  File? _textFile;
  String? _userId;
  String? _categoryId;
  String _effectiveCategory = 'General';
  List<String> _availableCategories = [];

  double? _latitude;
  double? _longitude;
  bool _isLocationEnabled = false;
  bool _isLocationLoading = false;
  String _locationStatus = 'Location not available';
  bool _locationPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateTitleWordCount);
    _textController.addListener(_updateCounts);

    // Safely call methods that use BuildContext after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeData();
        _checkLocationPermission();
      }
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateTitleWordCount);
    _textController.removeListener(_updateCounts);
    _titleController.dispose();
    _textController.dispose();
    _titleFocusNode.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  // --- DATA INITIALIZATION ---
  Future<void> _initializeData() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      await UuidService.initialize();
      _userId = await _getCurrentUserId();
      final categories = await UuidService.getCategories();
      _availableCategories = categories.keys.toList();
      if (_availableCategories.isEmpty) _availableCategories = ['General'];

      if (widget.selectedCategoryId != null && UuidService.isValidUuid(widget.selectedCategoryId!)) {
        _categoryId = widget.selectedCategoryId;
        _effectiveCategory = await UuidService.getCategoryName(_categoryId!) ?? widget.selectedCategory ?? 'General';
      } else if (widget.selectedCategory != null) {
        _effectiveCategory = widget.selectedCategory!;
        _categoryId = await UuidService.getCategoryUuid(_effectiveCategory);
      } else {
        _effectiveCategory = _availableCategories.isNotEmpty ? _availableCategories[0] : 'General';
        _categoryId = await UuidService.getCategoryUuid(_effectiveCategory);
      }

      if (_userId == null || _userId!.isEmpty) {
        _showErrorSnackBar(widget.isEnglish ? 'Please login to submit content' : 'సమర్పించడానికి దయచేసి లాగిన్ చేయండి');
      }
    } catch (e) {
      print('Error initializing data: $e');
      _showErrorSnackBar(widget.isEnglish ? 'Error loading data: ${e.toString()}' : 'డేటాను లోడ్ చేయడంలో లోపం: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  // --- LOCATION HANDLING ---
  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationStatus = 'Location services disabled');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _locationStatus = 'Location permission denied');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _locationStatus = 'Location permission permanently denied');
        return;
      }
      setState(() {
        _locationPermissionGranted = permission == LocationPermission.whileInUse || permission == LocationPermission.always;
      });
      if (_locationPermissionGranted) await _getCurrentLocation();
    } catch (e) {
      print('Error checking location permission: $e');
      setState(() => _locationStatus = 'Location error: ${e.toString()}');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationStatus = 'Getting location...';
    });

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, timeLimit: const Duration(seconds: 10));
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLocationEnabled = true;
        _locationStatus = 'Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        _isLocationLoading = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLocationLoading = false;
        _locationStatus = 'Failed to get location: ${e.toString()}';
      });
    }
  }

  // --- EVENT HANDLERS & HELPERS ---
  void _updateTitleWordCount() {
    final text = _titleController.text.trim();
    setState(() => _titleWordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length);
  }

  void _updateCounts() {
    final text = _textController.text;
    setState(() {
      _characterCount = text.length;
      _wordCount = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    });
  }
  
  void _showErrorSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final String noTextError = widget.isEnglish ? 'Please enter some text before submitting' : 'సమర్పించే ముందు దయచేసి కొంత వచనాన్ని నమోదు చేయండి';
    final String noTitleError = widget.isEnglish ? 'Please enter a title for your text' : 'దయచేసి మీ వచనానికి శీర్షికను నమోదు చేయండి';
    final String loginError = widget.isEnglish ? 'Please login to submit content' : 'సమర్పించడానికి దయచేసి లాగిన్ చేయండి';
    final String sessionError = widget.isEnglish ? 'Session expired. Please login again.' : 'సెషన్ గడువు ముగిసింది. దయచేసి మళ్లీ లాగిన్ చేయండి.';

    if (_textController.text.trim().isEmpty) {
      _showErrorSnackBar(noTextError);
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar(noTitleError);
      return;
    }

    final currentUserId = await _getCurrentUserId();
    if (currentUserId == null || currentUserId.isEmpty) {
      _showErrorSnackBar(loginError);
      return;
    }

    if (!await TokenStorageService.isTokenValid()) {
      _showErrorSnackBar(sessionError);
      return;
    }

    setState(() => _isUploading = true);

    try {
      final directory = await getTemporaryDirectory();
      _textFile = File('${directory.path}/text_${DateTime.now().millisecondsSinceEpoch}.txt');
      String fileContent = 'Title: ${_titleController.text.trim()}\n\n${_textController.text}';
      await _textFile!.writeAsString(fileContent);

      if (_categoryId == null || _categoryId!.isEmpty) {
        throw Exception("Category ID is null at submit");
      }
      
      String description = widget.isEnglish ? 'Text content in $_selectedLanguage language ($_wordCount words)' : '$_selectedLanguage భాషలో వచన కంటెంట్ ($_wordCount పదాలు)';
      if (_isLocationEnabled && _latitude != null) {
        description += widget.isEnglish ? ' - Location: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}' : ' - స్థానం: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}';
      }

      final result = await ApiService.createAndUploadRecord(
        title: _titleController.text.trim(),
        description: description,
        userId: currentUserId,
        mediaType: 'text',
        categoryId: _categoryId!,
        file: _textFile!,
        latitude: _isLocationEnabled ? _latitude : null,
        longitude: _isLocationEnabled ? _longitude : null,
      );

      if (result['success']) {
        String successMsg = widget.isEnglish ? 'Text submitted successfully! ($_wordCount words)' : 'వచనం విజయవంతంగా సమర్పించబడింది! ($_wordCount పదాలు)';
        _showErrorSnackBar(successMsg, isSuccess: true);
        Navigator.pop(context, true);
      } else {
        throw Exception(result['error'] ?? 'Unknown error occurred');
      }
    } catch (e) {
      print('Submit error: $e');
      _showErrorSnackBar(widget.isEnglish ? 'Failed to submit text: ${e.toString()}' : 'వచనాన్ని సమర్పించడంలో విఫలమైంది: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<String?> _getCurrentUserId() async {
    String? userId = await UuidService.getCurrentUserId();
    if (userId != null && userId.isNotEmpty) return userId;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // All other methods like _clearText, _changeCategory etc. should be here as they were in your original file.

  // --- UI BUILD METHODS ---
  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.isEnglish ? 'Text Input' : 'టెక్స్ట్ ఇన్‌పుట్')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: kPrimaryColor),
              const SizedBox(height: 16),
              Text(widget.isEnglish ? 'Loading...' : 'లోడ్ అవుతోంది...'),
            ],
          ),
        ),
      );
    }

    // Localized strings for the main build method
    final String appBarTitle = widget.isEnglish ? 'Text Input' : 'టెక్స్ట్ ఇన్‌పుట్';
    final String locationEnabledText = widget.isEnglish ? 'Location enabled' : 'స్థానం ప్రారంభించబడింది';
    final String locationDisabledText = widget.isEnglish ? 'Location disabled' : 'స్థానం నిలిపివేయబడింది';
    final String languageLabel = widget.isEnglish ? 'Language' : 'భాష';
    final String textTitleLabel = widget.isEnglish ? 'Text Title' : 'వచన శీర్షిక';
    final String titleHint = widget.isEnglish ? 'Give your text a descriptive title' : 'మీ వచనానికి వివరణాత్మక శీర్షిక ఇవ్వండి';
    final String wordsSuffix = widget.isEnglish ? 'words' : 'పదాలు';
    final String titleError = widget.isEnglish ? 'Title exceeds word limit' : 'శీర్షిక పదాల పరిమితిని మించిపోయింది';
    final String enterTextLabel = widget.isEnglish ? 'Enter your text' : 'మీ వచనాన్ని నమోదు చేయండి';
    final String typingHint = widget.isEnglish ? 'Start typing your text here...' : 'మీ వచనాన్ని ఇక్కడ టైప్ చేయడం ప్రారంభించండి...';
    final String wordsStat = widget.isEnglish ? 'Words' : 'పదాలు';
    final String charactersStat = widget.isEnglish ? 'Characters' : 'అక్షరాలు';
    final String submittingText = widget.isEnglish ? 'Submitting...' : 'సమర్పిస్తోంది...';
    final String submitButtonText = widget.isEnglish ? 'Submit Text' : 'వచనాన్ని సమర్పించండి';
    final String withLocationText = widget.isEnglish ? ' with Location' : ' స్థానంతో';
    final String enableSubmissionTitle = widget.isEnglish ? 'Enter a title to enable submission' : 'సమర్పణను ప్రారంభించడానికి శీర్షికను నమోదు చేయండి';
    final String enableSubmissionText = widget.isEnglish ? 'Enter some text to enable submission' : 'సమర్పణను ప్రారంభించడానికి కొంత వచనాన్ని నమోదు చేయండి';
    final String clearTextTitle = widget.isEnglish ? 'Clear All' : 'అన్నీ తొలగించు';
    final String clearTextContent = widget.isEnglish ? 'Are you sure you want to clear both title and text?' : 'మీరు శీర్షిక మరియు వచనం రెండింటినీ తొలగించాలనుకుంటున్నారని ఖಚಿತంగా ఉన్నారా?';
    final String cancelText = widget.isEnglish ? 'Cancel' : 'రద్దు చేయి';
    final String clearText = widget.isEnglish ? 'Clear' : 'తొలగించు';


    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
        ),
        title: Text(appBarTitle, style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
        actions: [
          if (_textController.text.isNotEmpty || _titleController.text.isNotEmpty)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(clearTextTitle),
                    content: Text(clearTextContent),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text(cancelText)),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _titleController.clear();
                            _textController.clear();
                          });
                        },
                        child: Text(clearText, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.clear, color: Colors.red),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Using Expanded to make the content area scrollable, pushing the button to the bottom.
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // --- Header Info ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _buildCardDecoration(),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(_effectiveCategory, style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 12)),
                          ),
                          const Spacer(),
                          // Location Status
                          _buildLocationStatus(locationEnabledText, locationDisabledText),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // --- Title Section ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _buildCardDecoration(),
                      child: TextField(
                        controller: _titleController,
                        maxLength: 100,
                        decoration: InputDecoration(
                          labelText: '$textTitleLabel *',
                          hintText: titleHint,
                          border: InputBorder.none,
                          counterText: '$_titleWordCount/20 $wordsSuffix',
                          counterStyle: TextStyle(color: _titleWordCount > 20 ? Colors.red : Colors.grey[600], fontSize: 12),
                          errorText: _titleWordCount > 20 ? titleError : null,
                          prefixIcon: const Icon(Icons.title, color: kPrimaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // --- Text Input Area ---
                    Container(
                      height: 250, // Giving the text area a fixed height
                      decoration: _buildCardDecoration(),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.edit, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(enterTextLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Text('$_wordCount $wordsSuffix', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextField(
                                controller: _textController,
                                focusNode: _textFocusNode,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                style: const TextStyle(fontSize: 16, height: 1.5),
                                decoration: InputDecoration(
                                  hintText: typingHint,
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
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
            ),
            // --- Bottom Stats and Submit Button ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 10)
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('$_wordCount', wordsStat),
                      _buildStatItem('$_characterCount', charactersStat),
                      _buildStatItem(_selectedLanguage, languageLabel),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isUploading || _textController.text.trim().isEmpty || _titleController.text.trim().isEmpty ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: _isUploading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                                const SizedBox(width: 12),
                                Text(submittingText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.send, size: 20),
                                const SizedBox(width: 8),
                                Text('$submitButtonText${_isLocationEnabled ? withLocationText : ''}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                  ),
                  if (_textController.text.trim().isEmpty || _titleController.text.trim().isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _titleController.text.trim().isEmpty ? enableSubmissionTitle : enableSubmissionText,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
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

  // Helper method for cards
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          offset: const Offset(0, 2),
          blurRadius: 8,
        ),
      ],
    );
  }

  // Helper method for location status to keep build method clean
  Widget _buildLocationStatus(String enabledText, String disabledText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isLocationEnabled ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _isLocationEnabled ? Colors.green : Colors.orange, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isLocationEnabled ? Icons.location_on : Icons.location_off,
            size: 14,
            color: _isLocationEnabled ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            _isLocationEnabled ? enabledText : disabledText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _isLocationEnabled ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper for stat items
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}