// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:org.swecha.telugu_corpus_collection/Screens/recording/video_input_screen.dart';
import '../../constants.dart';
import '../recording/text_input_screen.dart';
import '../recording/audio_input_screen.dart';
import 'components/input_options_grid.dart';
import '../recording/picture_input_screen.dart';

class InputMethodScreen extends StatefulWidget {
  final String selectedCategory;
  final bool isEnglish; // Add language state

  const InputMethodScreen({
    super.key,
    required this.selectedCategory,
    required this.isEnglish, // Require language state
  });

  @override
  State<InputMethodScreen> createState() => _InputMethodScreenState();
}

class _InputMethodScreenState extends State<InputMethodScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // --- Navigation Handlers ---

  void _handleTextInput() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => TextInputScreen(
          selectedCategory: widget.selectedCategory,
          isEnglish: widget.isEnglish, 
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    );
  }

  void _handleAudioInput() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AudioInputScreen(
          selectedCategory: widget.selectedCategory,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    );
  }

  void _handleVideoInput() {
    final String message = widget.isEnglish
        ? 'Opening video recording for ${widget.selectedCategory}...'
        : 'వీడియో రికార్డింగ్ తెరువబడుతోంది ${widget.selectedCategory}...';
    _showSnackBar(message, Icons.videocam, const Color(0xFF9C27B0));

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            VideoInputScreen(
          selectedCategory: widget.selectedCategory,
          userId: '',
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    );
  }

  void _handlePictureInput() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PictureInputScreen(
          selectedCategory: widget.selectedCategory,
          // isEnglish: widget.isEnglish, // Add this line
   

        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    );
  }

  void _showSnackBar(String message, IconData icon, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // Custom App Bar
                    _buildCustomAppBar(),

                    // Main Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Category Display Section
                            _buildCategorySection(),

                            const SizedBox(height: 30),

                            // Input Options Grid
                            // Note: InputOptionsGrid component would also need the isEnglish flag passed to it.
                            InputOptionsGrid(
                              onTextTap: _handleTextInput,
                              onAudioTap: _handleAudioInput,
                              onVideoTap: _handleVideoInput,
                              onPictureTap: _handlePictureInput,
                               isEnglish: widget.isEnglish,
                            ),

                            const SizedBox(height: 30),

                            // Tips Section
                            _buildTipsSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Localized Build Widgets ---

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.black87,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEnglish
                      ? 'Choose Input Method'
                      : 'ఇన్‌పుట్ పద్ధతిని ఎంచుకోండి',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  widget.isEnglish
                      ? 'How would you like to share your content?'
                      : 'మీరు మీ కంటెంట్‌ను ఎలా పంచుకోవాలనుకుంటున్నారు?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor.withOpacity(0.1),
            kPrimaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isEnglish ? 'Selected Category' : 'ఎంచుకున్న వర్గం',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: kPrimaryColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Text(
              widget.selectedCategory,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    final List<Map<String, dynamic>> tips = [
      {
        'icon': Icons.text_fields_rounded,
        'title_en': 'Text Input',
        'title_te': 'టెక్స్ట్ ఇన్‌పుట్',
        'desc_en': 'Perfect for detailed stories and structured content',
        'desc_te': 'వివరణాత్మక కథలు మరియు నిర్మాణాత్మక కంటెంట్ కోసం పరిపూర్ణమైనది',
        'color': const Color(0xFF4CAF50),
      },
      {
        'icon': Icons.mic_rounded,
        'title_en': 'Audio Recording',
        'title_te': 'ఆడియో రికార్డింగ్',
        'desc_en': 'Capture natural speech and ambient sounds',
        'desc_te': 'సహజమైన ప్రసంగం మరియు పరిసర శబ్దాలను సంగ్రహించండి',
        'color': const Color(0xFF2196F3),
      },
      {
        'icon': Icons.photo_camera_rounded,
        'title_en': 'Picture Upload',
        'title_te': 'చిత్రం అప్‌లోడ్',
        'desc_en': 'Visual content with automatic descriptions',
        'desc_te': 'ఆటోమేటిక్ వివరణలతో కూడిన దృశ్య కంటెంట్',
        'color': const Color(0xFFFF9800),
      },
      {
        'icon': Icons.videocam_rounded,
        'title_en': 'Video Recording',
        'title_te': 'వీడియో రికార్డింగ్',
        'desc_en': 'Dynamic content with audio and visuals',
        'desc_te': 'ఆడియో మరియు విజువల్స్‌తో డైనమిక్ కంటెంట్',
        'color': const Color(0xFF9C27B0),
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                widget.isEnglish ? 'Quick Tips' : 'త్వరిత చిట్కాలు',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildTipItem(
                icon: tip['icon'],
                title: widget.isEnglish ? tip['title_en'] : tip['title_te'],
                description:
                    widget.isEnglish ? tip['desc_en'] : tip['desc_te'],
                color: tip['color'],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}