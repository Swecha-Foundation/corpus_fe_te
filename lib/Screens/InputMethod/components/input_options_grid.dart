// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../constants.dart';

class InputOptionsGrid extends StatefulWidget {
  final VoidCallback onTextTap;
  final VoidCallback onAudioTap;
  final VoidCallback onVideoTap;
  final VoidCallback onPictureTap;

  const InputOptionsGrid({
    Key? key,
    required this.onTextTap,
    required this.onAudioTap,
    required this.onVideoTap,
    required this.onPictureTap,
  }) : super(key: key);

  @override
  State<InputOptionsGrid> createState() => _InputOptionsGridState();
}

class _InputOptionsGridState extends State<InputOptionsGrid>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    _fadeAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOut),
      );
    }).toList();

    // Start animations with staggered delays
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _animationControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75, // Reduced from 0.85 to give more height
          children: [
            _buildInputOption(
              index: 0,
              icon: Icons.text_fields_rounded,
              title: 'Text Input',
              subtitle: 'Type your content',
              color: const Color(0xFF4CAF50),
              onTap: widget.onTextTap,
            ),
            _buildInputOption(
              index: 1,
              icon: Icons.mic_rounded,
              title: 'Audio Recording',
              subtitle: 'Record your voice',
              color: const Color(0xFF2196F3),
              onTap: widget.onAudioTap,
            ),
            _buildInputOption(
              index: 2,
              icon: Icons.photo_camera_rounded,
              title: 'Picture Upload',
              subtitle: 'Add images',
              color: const Color(0xFFFF9800),
              onTap: widget.onPictureTap,
            ),
            _buildInputOption(
              index: 3,
              icon: Icons.videocam_rounded,
              title: 'Video Recording',
              subtitle: 'Record videos',
              color: const Color(0xFF9C27B0),
              onTap: widget.onVideoTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kPrimaryColor.withOpacity(0.1),
                  kPrimaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.touch_app_rounded,
              color: kPrimaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Input Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Choose how you want to add your content',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputOption({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _animationControllers[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimations[index].value,
          child: FadeTransition(
            opacity: _fadeAnimations[index],
            child: _InputOptionCard(
              icon: icon,
              title: title,
              subtitle: subtitle,
              color: color,
              onTap: onTap,
            ),
          ),
        );
      },
    );
  }
}

class _InputOptionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _InputOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_InputOptionCard> createState() => _InputOptionCardState();
}

class _InputOptionCardState extends State<_InputOptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _hoverController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _hoverController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _hoverAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed 
                        ? widget.color.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                    offset: Offset(0, _isPressed ? 4 : 8),
                    blurRadius: _isPressed ? 12 : 20,
                  ),
                  if (_isPressed)
                    BoxShadow(
                      color: widget.color.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                    ),
                ],
                border: Border.all(
                  color: _isPressed 
                      ? widget.color.withOpacity(0.3)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16), // Reduced from 20
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed from center
                    children: [
                      // Icon Container
                      Container(
                        width: 50, // Reduced from 60
                        height: 50, // Reduced from 60
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              widget.color,
                              widget.color.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14), // Reduced from 16
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 24, // Reduced from 28
                          ),
                        ),
                      ),
                      
                      // Text Section - More compact
                      Column(
                        children: [
                          // Title
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 14, // Reduced from 16
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 4), // Reduced from 6
                          
                          // Subtitle
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 11, // Reduced from 12
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      
                      // Action Indicator - More compact
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, // Reduced from 12
                          vertical: 4, // Reduced from 6
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.color.withOpacity(0.1),
                              widget.color.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16), // Reduced from 20
                          border: Border.all(
                            color: widget.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tap to select',
                              style: TextStyle(
                                fontSize: 9, // Reduced from 10
                                color: widget.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 3), // Reduced from 4
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: widget.color,
                              size: 10, // Reduced from 12
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}