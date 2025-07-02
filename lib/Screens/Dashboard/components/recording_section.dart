// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../InputMethod/input_method_screen.dart';

class RecordingSection extends StatefulWidget {
  final String? selectedCategory;
  final bool showOptions;
  final VoidCallback onToggleOptions;
  final bool isEnglish; // Added to receive language state

  const RecordingSection({
    Key? key,
    this.selectedCategory,
    required this.showOptions,
    required this.onToggleOptions,
    required this.isEnglish, // Make it required
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

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

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

    if (widget.selectedCategory != null &&
        !_hasNavigated &&
        _lastProcessedCategory != widget.selectedCategory) {
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
    if (widget.selectedCategory == null) {
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            InputMethodScreen(
          selectedCategory: widget.selectedCategory!,
           isEnglish: widget.isEnglish, // This will be passed to the InputMethodScreen
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
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 20),
            blurRadius: 40,
          ),
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.1),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            children: [
              _buildHeaderSection(canProceed),
              const SizedBox(height: 16),
              _buildSubtitleSection(canProceed),
              const SizedBox(height: 40),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: !canProceed
                    ? _buildCategoryRequiredMessage()
                    : _buildNavigationButton(),
              ),
              const SizedBox(height: 40),
              _buildProgressIndicator(canProceed),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(bool canProceed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: canProceed
              ? [kPrimaryColor.withOpacity(0.1), kPrimaryColor.withOpacity(0.05)]
              : [
                  Colors.orange.withOpacity(0.1),
                  Colors.orange.withOpacity(0.05)
                ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        canProceed
            ? (widget.isEnglish
                ? '🚀 Ready to Choose Input Method'
                : '🚀 ఇన్‌పుట్ పద్ధతిని ఎంచుకోవడానికి సిద్ధంగా ఉంది')
            : (widget.isEnglish
                ? '📂 Select Category First'
                : '📂 ముందుగా వర్గాన్ని ఎంచుకోండి'),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: canProceed ? kPrimaryColor : Colors.orange.shade700,
        ),
      ),
    );
  }

  Widget _buildSubtitleSection(bool canProceed) {
    if (canProceed && widget.selectedCategory != null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor.withOpacity(0.1),
                  kPrimaryColor.withOpacity(0.05)
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kPrimaryColor.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: kPrimaryColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  widget.isEnglish
                      ? 'Category: ${widget.selectedCategory}'
                      : 'వర్గం: ${widget.selectedCategory}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.isEnglish
                ? 'Tap below to choose how you want to share your content'
                : 'మీరు మీ కంటెంట్‌ను ఎలా భాగస్వామ్యం చేయాలనుకుంటున్నారో ఎంచుకోవడానికి దిగువన నొక్కండి',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Text(
      widget.isEnglish
          ? 'Please select a category from above to continue'
          : 'కొనసాగించడానికి దయచేసి ఎగువ నుండి ఒక వర్గాన్ని ఎంచుకోండి',
      style: TextStyle(
        fontSize: 16,
        color: Colors.orange.shade600,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildCategoryRequiredMessage() {
    return Column(
      key: const ValueKey('category_required'),
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade300,
                Colors.orange.shade400,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                offset: const Offset(0, 15),
                blurRadius: 30,
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.transparent,
                ],
              ),
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.shade200, width: 1),
          ),
          child: Column(
            children: [
              Text(
                widget.isEnglish
                    ? 'Choose a category first'
                    : 'ముందుగా ఒక వర్గాన్ని ఎంచుకోండి',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isEnglish
                    ? 'Select from the categories above to proceed'
                    : 'కొనసాగించడానికి ఎగువ వర్గాల నుండి ఎంచుకోండి',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange.shade600,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        kPrimaryColor,
                        kPrimaryColor.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.4),
                        offset: const Offset(0, 15),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _handleManualNavigation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor.withOpacity(0.1),
                  kPrimaryColor.withOpacity(0.05)
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: kPrimaryColor.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.touch_app_rounded,
                  color: kPrimaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  widget.isEnglish
                      ? 'Choose Input Method'
                      : 'ఇన్‌పుట్ పద్ధతిని ఎంచుకోండి',
                  style: const TextStyle(
                    fontSize: 16,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(bool canProceed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: canProceed ? kPrimaryColor : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              canProceed ? Icons.check : Icons.looks_one,
              color: Colors.white,
              size: 18,
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: canProceed ? kPrimaryColor : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: canProceed ? kPrimaryColor : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              canProceed ? Icons.arrow_forward : Icons.looks_two,
              color: Colors.white,
              size: 18,
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.looks_3,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}