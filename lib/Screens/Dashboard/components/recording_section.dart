import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../recording/text_input_screen.dart';
import '../../recording/audio_input_screen.dart';

class RecordingSection extends StatefulWidget {
  final bool showOptions;
  final VoidCallback onToggleOptions;
  
  const RecordingSection({
    Key? key,
    required this.showOptions,
    required this.onToggleOptions,
  }) : super(key: key);

  @override
  State<RecordingSection> createState() => _RecordingSectionState();
}

class _RecordingSectionState extends State<RecordingSection> 
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _expandController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.elasticOut,
    );
    
    _pulseController.repeat(reverse: true);
    if (widget.showOptions) {
      _expandController.forward();
    }
  }

  @override
  void didUpdateWidget(RecordingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showOptions != oldWidget.showOptions) {
      if (widget.showOptions) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _handleAudioInput(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AudioInputScreen(
          selectedCategory: 'Your Selected Category',
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

  void _handleVideoInput(BuildContext context) {
    _showSnackBar(context, 'Opening video recording...', Icons.videocam, const Color(0xFF9C27B0));
  }

  void _handlePictureInput(BuildContext context) {
    _showSnackBar(context, 'Opening picture selection...', Icons.photo, const Color(0xFFFF9800));
  }

  void _handleTextInput(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const TextInputScreen(
          selectedCategory: 'Your Selected Category',
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

  void _showSnackBar(BuildContext context, String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 20),
            blurRadius: 40,
          ),
          BoxShadow(
            // ignore: deprecated_member_use
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
                // ignore: deprecated_member_use
                Colors.white.withOpacity(0.9),
                // ignore: deprecated_member_use
                Colors.white.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // ignore: deprecated_member_use
                    colors: [kPrimaryColor.withOpacity(0.1), kPrimaryColor.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🎙️ Choose your input method',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select how you want to share your content',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: !widget.showOptions 
                  ? _buildMainButton() 
                  : _buildOptionsGrid(),
              ),
              
              const SizedBox(height: 40),
              
              // Enhanced Stats Section
              _buildStatsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton() {
    return Column(
      key: const ValueKey('main_button'),
      children: [
        GestureDetector(
          onTap: widget.onToggleOptions,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        kPrimaryColor,
                        // ignore: deprecated_member_use
                        kPrimaryColor.withOpacity(0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: kPrimaryColor.withOpacity(0.4),
                        offset: const Offset(0, 15),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          // ignore: deprecated_member_use
                          Colors.white.withOpacity(0.2),
                          // ignore: deprecated_member_use
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Tap to choose input method',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionsGrid() {
    return Column(
      key: const ValueKey('options_grid'),
      children: [
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _expandAnimation.value,
              child: Opacity(
                opacity: _expandAnimation.value,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildOptionButton(
                          icon: Icons.text_fields_rounded,
                          label: 'Text',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF45a049)],
                          ),
                          onTap: () => _handleTextInput(context),
                        ),
                        _buildOptionButton(
                          icon: Icons.mic_rounded,
                          label: 'Audio',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                          ),
                          onTap: () => _handleAudioInput(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildOptionButton(
                          icon: Icons.photo_camera_rounded,
                          label: 'Pictures',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFf57c00)],
                          ),
                          onTap: () => _handlePictureInput(context),
                        ),
                        _buildOptionButton(
                          icon: Icons.videocam_rounded,
                          label: 'Videos',
                          gradient: const LinearGradient(
                            colors: [Color(0xFF9C27B0), Color(0xFF7b1fa2)],
                          ),
                          onTap: () => _handleVideoInput(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: widget.onToggleOptions,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // ignore: deprecated_member_use
                colors: [kPrimaryColor.withOpacity(0.1), kPrimaryColor.withOpacity(0.2)],
              ),
              borderRadius: BorderRadius.circular(25),
              // ignore: deprecated_member_use
              border: Border.all(color: kPrimaryColor.withOpacity(0.3), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_rounded, color: kPrimaryColor, size: 20),
                 SizedBox(width: 8),
                 Text(
                  'Back',
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 16,
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

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: gradient.colors.first.withOpacity(0.3),
              offset: const Offset(0, 10),
              blurRadius: 20,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // ignore: deprecated_member_use
                Colors.white.withOpacity(0.2),
                // ignore: deprecated_member_use
                Colors.white.withOpacity(0.0),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
            // ignore: deprecated_member_use
            kPrimaryColor.withOpacity(0.05),
            // ignore: deprecated_member_use
            kPrimaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        border: Border.all(color: kPrimaryColor.withOpacity(0.2), width: 1),
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
                  // ignore: deprecated_member_use
                  Colors.grey.withOpacity(0.2),
                  // ignore: deprecated_member_use
                  Colors.grey.withOpacity(0.5),
                  // ignore: deprecated_member_use
                  Colors.grey.withOpacity(0.2),
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
            // ignore: deprecated_member_use
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