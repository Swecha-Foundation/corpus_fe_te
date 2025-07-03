// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../InputMethod/input_method_screen.dart';

class RecordingSection extends StatefulWidget {
  final String? selectedCategory;
  final bool isEnglish; // FIX: Added isEnglish parameter
  final bool showOptions;
  final VoidCallback onToggleOptions;
  
  const RecordingSection({
    Key? key,
    this.selectedCategory,
    required this.isEnglish, // FIX: Made it required
    required this.showOptions,
    required this.onToggleOptions,
  }) : super(key: key);

  @override
  State<RecordingSection> createState() => _RecordingSectionState();
}

class _RecordingSectionState extends State<RecordingSection> 
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _hasNavigated = false;
  String? _lastProcessedCategory;

  // Language content map
  static final Map<String, Map<String, String>> _languageContent = {
    'en': {
      'header_ready': '🚀 Ready to Choose Input Method',
      'header_select': '📂 Select Category First',
      'subtitle_ready': 'Tap below to choose how you want to share your content',
      'subtitle_select': 'Please select a category from above to continue',
      'prompt_header': 'Choose a category first',
      'prompt_body': 'Select from the categories above to proceed',
      'button_text': 'Choose Input Method',
      'category_prefix': 'Category',
    },
    'te': {
      'header_ready': '🚀 ఇన్‌పుట్ పద్ధతిని ఎంచుకోవడానికి సిద్ధంగా ఉంది',
      'header_select': '📂 ముందుగా వర్గాన్ని ఎంచుకోండి',
      'subtitle_ready': 'మీరు మీ కంటెంట్‌ను ఎలా పంచుకోవాలనుకుంటున్నారో ఎంచుకోవడానికి క్రింద నొక్కండి',
      'subtitle_select': 'కొనసాగించడానికి దయచేసి పైన ఉన్న వర్గాన్ని ఎంచుకోండి',
      'prompt_header': 'ముందుగా ఒక వర్గాన్ని ఎంచుకోండి',
      'prompt_body': 'కొనసాగించడానికి పైన ఉన్న వర్గాల నుండి ఎంచుకోండి',
      'button_text': 'ఇన్‌పుట్ పద్ధతిని ఎంచుకోండి',
      'category_prefix': 'వర్గం',
    },
  };

  String _getText(String key) {
    return _languageContent[widget.isEnglish ? 'en' : 'te']![key] ?? '';
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RecordingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _hasNavigated = false;
      _lastProcessedCategory = null;
    }
    
    if (widget.selectedCategory != null && !_hasNavigated && _lastProcessedCategory != widget.selectedCategory) {
      _hasNavigated = true;
      _lastProcessedCategory = widget.selectedCategory;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _navigateToInputMethod(context);
        }
      });
    }
  }

  void _navigateToInputMethod(BuildContext context) {
    if (widget.selectedCategory == null) return;
    
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => InputMethodScreen(
          selectedCategory: widget.selectedCategory!,
          isEnglish: widget.isEnglish, // FIX: Pass isEnglish to the next screen
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _hasNavigated = false;
        });
      }
    });
  }

  void _handleManualNavigation() {
    if (widget.selectedCategory != null) {
      _navigateToInputMethod(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canProceed = widget.selectedCategory != null;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeaderSection(canProceed),
          const SizedBox(height: 12),
          _buildSubtitleSection(canProceed),
          const SizedBox(height: 32),
          
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
            },
            child: !canProceed 
              ? _buildCategoryRequiredMessage()
              : _buildNavigationButton(),
          ),
          
          const SizedBox(height: 32),
          _buildProgressIndicator(canProceed),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(bool canProceed) {
    return Text(
      canProceed ? _getText('header_ready') : _getText('header_select'),
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: canProceed ? kPrimaryColor : Colors.orange.shade800,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitleSection(bool canProceed) {
    if (canProceed && widget.selectedCategory != null) {
      return Column(
        children: [
          Text(
            '${_getText('category_prefix')}: ${widget.selectedCategory}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getText('subtitle_ready'),
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    return Text(
      _getText('subtitle_select'),
      style: TextStyle(fontSize: 16, color: Colors.orange.shade700),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCategoryRequiredMessage() {
    return Column(
      key: const ValueKey('category_required'),
      children: [
        Icon(Icons.arrow_upward_rounded, color: Colors.orange.shade300, size: 48),
        const SizedBox(height: 16),
        Text(_getText('prompt_header'), style: TextStyle(fontSize: 16, color: Colors.orange.shade700, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(_getText('prompt_body'), style: TextStyle(fontSize: 14, color: Colors.orange.shade600)),
      ],
    );
  }

  Widget _buildNavigationButton() {
    return Column(
      key: const ValueKey('navigation_button'),
      children: [
        GestureDetector(
          onTap: _handleManualNavigation,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: kPrimaryColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 48),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _handleManualNavigation,
          child: Text(
            _getText('button_text'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kPrimaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(bool canProceed) {
    return Row(
      children: [
        _buildProgressStep(canProceed, Icons.check, '1'),
        _buildProgressConnector(canProceed),
        _buildProgressStep(canProceed, Icons.arrow_forward, '2'),
        _buildProgressConnector(false),
        _buildProgressStep(false, Icons.edit, '3'),
      ],
    );
  }

  Widget _buildProgressStep(bool isActive, IconData activeIcon, String inactiveText) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? kPrimaryColor : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isActive
            ? Icon(activeIcon, color: Colors.white, size: 18)
            : Text(inactiveText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProgressConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? kPrimaryColor : Colors.grey.shade300,
      ),
    );
  }
}
