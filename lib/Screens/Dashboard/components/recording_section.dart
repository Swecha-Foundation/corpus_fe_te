// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../InputMethod/input_method_screen.dart';

class RecordingSection extends StatefulWidget {
  final String? selectedCategory;
  final bool showOptions; // Keep for compatibility but not used for input methods
  final VoidCallback onToggleOptions; // Keep for compatibility
  
  const RecordingSection({
    Key? key,
    this.selectedCategory,
    required this.showOptions,
    required this.onToggleOptions,
  }) : super(key: key);

  @override
  State<RecordingSection> createState() => _RecordingSectionState();
}

class _RecordingSectionState extends State<RecordingSection> 
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation; // This was declared but never initialized
  bool _hasNavigated = false; // Track navigation state
  String? _lastProcessedCategory; // Track the last category we processed for auto-navigation

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // FIX: Initialize the _pulseAnimation properly
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
    
    // Only reset navigation flag when category actually changes
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      _hasNavigated = false;
      _lastProcessedCategory = null; // Reset processed category tracking
    }
    
    // Auto-navigate only when:
    // 1. Category is selected
    // 2. We haven't navigated yet
    // 3. This is a new category (different from last processed)
    if (widget.selectedCategory != null && 
        !_hasNavigated && 
        _lastProcessedCategory != widget.selectedCategory) {
      
      _hasNavigated = true; // Set flag immediately to prevent multiple navigations
      _lastProcessedCategory = widget.selectedCategory; // Remember this category
      
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
        pageBuilder: (context, animation, secondaryAnimation) => InputMethodScreen(
          selectedCategory: widget.selectedCategory!,
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
      // Reset navigation flag when returning from InputMethodScreen
      // but keep the _lastProcessedCategory to prevent re-navigation
      if (mounted) {
        setState(() {
          _hasNavigated = false;
        });
      }
    });
  }

  // Add manual navigation method for tap gesture
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
              // Header Section
              _buildHeaderSection(canProceed),
              const SizedBox(height: 16),
              _buildSubtitleSection(canProceed),
              const SizedBox(height: 40),
              
              // Main Content - Show category selection prompt or navigation button
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
              
              // Progress indicator
              _buildProgressIndicator(canProceed),
              
              const SizedBox(height: 32),
              
              // Stats Section
              // _buildStatsSection(),
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
            : [Colors.orange.withOpacity(0.1), Colors.orange.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        canProceed 
          ? '🚀 Ready to Choose Input Method'
          : '📂 Select Category First',
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
                colors: [kPrimaryColor.withOpacity(0.1), kPrimaryColor.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kPrimaryColor.withOpacity(0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: kPrimaryColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Category: ${widget.selectedCategory}',
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
            'Tap below to choose how you want to share your content',
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
      'Please select a category from above to continue',
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
                'Choose a category first',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select from the categories above to proceed',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange.shade600,
                  fontWeight: FontWeight.w400,
                ),
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
                colors: [kPrimaryColor.withOpacity(0.1), kPrimaryColor.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kPrimaryColor.withOpacity(0.3), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: kPrimaryColor,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Choose Input Method',
                  style: TextStyle(
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
          // Step 1 - Category Selection
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
          
          // Step 2 - Input Method Selection (Now Active)
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
          
          // Step 3 - Content Creation
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

  Widget _buildStatsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kPrimaryColor.withOpacity(0.05),
            kPrimaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.record_voice_over_rounded,
              value: '23',
              label: 'Hours of voice',
              color: const Color(0xFF4CAF50),
            ),
          ),
          Container(
            width: 2,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey,
                  Colors.grey.withOpacity(0.5),
                  Colors.grey,
                ],
              ),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.stars_rounded,
              value: '234',
              label: 'Credit score',
              color: const Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}