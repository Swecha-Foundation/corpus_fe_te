// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../constants.dart';

class InputOptionsGrid extends StatefulWidget {
  final VoidCallback onTextTap;
  final VoidCallback onAudioTap;
  final VoidCallback onVideoTap;
  final VoidCallback onPictureTap;
  final bool isEnglish; // Add language state

  const InputOptionsGrid({
    Key? key,
    required this.onTextTap,
    required this.onAudioTap,
    required this.onVideoTap,
    required this.onPictureTap,
    required this.isEnglish, // Require language state
  }) : super(key: key);

  @override
  State<InputOptionsGrid> createState() => _InputOptionsGridState();
}

class _InputOptionsGridState extends State<InputOptionsGrid>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late final List<Map<String, dynamic>> _inputOptions;

  @override
  void initState() {
    super.initState();

    // The data now includes English and Telugu text.
    _inputOptions = [
      {
        'title_en': 'Text Input',
        'title_te': 'టెక్స్ట్ ఇన్‌పుట్',
        'subtitle_en': 'Type your content',
        'subtitle_te': 'మీ కంటెంట్‌ను టైప్ చేయండి',
        'icon': Icons.text_fields_rounded,
        'color': const Color(0xFF4CAF50),
        'onTap': widget.onTextTap,
      },
      {
        'title_en': 'Audio Recording',
        'title_te': 'ఆడియో రికార్డింగ్',
        'subtitle_en': 'Record your voice',
        'subtitle_te': 'మీ వాయిస్‌ని రికార్డ్ చేయండి',
        'icon': Icons.mic_rounded,
        'color': const Color(0xFF2196F3),
        'onTap': widget.onAudioTap,
      },
      {
        'title_en': 'Picture Upload',
        'title_te': 'చిత్రం అప్‌లోడ్',
        'subtitle_en': 'Add images',
        'subtitle_te': 'చిత్రాలను జోడించండి',
        'icon': Icons.photo_camera_rounded,
        'color': const Color(0xFFFF9800),
        'onTap': widget.onPictureTap,
      },
      {
        'title_en': 'Video Recording',
        'title_te': 'వీడియో రికార్డింగ్',
        'subtitle_en': 'Record a clip',
        'subtitle_te': 'ఒక క్లిప్ రికార్డ్ చేయండి',
        'icon': Icons.videocam_rounded,
        'color': const Color(0xFF9C27B0),
        'onTap': widget.onVideoTap,
      },
    ];

    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      _inputOptions.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAnimations();
    });
  }

  void _runAnimations() {
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * (i + 1)), () {
        if (mounted) {
          _animationControllers[i].forward(from: 0.0);
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
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double breakpoint = 700.0;

          if (constraints.maxWidth < breakpoint) {
            return _buildListLayout();
          } else {
            return _buildGridLayout();
          }
        },
      ),
    );
  }

  Widget _buildGridLayout() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: _inputOptions.length,
        itemBuilder: (context, index) {
          return _buildAnimatedTile(
            index: index,
            child: _buildGridTile(option: _inputOptions[index]),
          );
        },
      ),
    );
  }

  Widget _buildListLayout() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        children: _inputOptions.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildAnimatedTile(
              index: entry.key,
              child: _buildListTile(option: entry.value),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnimatedTile({required int index, required Widget child}) {
    final animation = CurvedAnimation(
      parent: _animationControllers[index],
      curve: Curves.easeOutBack,
    );
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
        child: child,
      ),
    );
  }

  Widget _buildGridTile({required Map<String, dynamic> option}) {
    return GestureDetector(
      onTap: option['onTap'],
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: _tileDecoration(),
        child: Column(
          children: [
            const Spacer(),
            _buildIcon(option),
            const SizedBox(height: 16),
            _buildTitleText(widget.isEnglish ? option['title_en'] : option['title_te']),
            const SizedBox(height: 4),
            _buildSubtitleText(widget.isEnglish ? option['subtitle_en'] : option['subtitle_te']),
            const Spacer(),
            _buildTapToAction(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({required Map<String, dynamic> option}) {
    return GestureDetector(
      onTap: option['onTap'],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: _tileDecoration(),
        child: Row(
          children: [
            _buildIcon(option),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTitleText(widget.isEnglish ? option['title_en'] : option['title_te']),
                  const SizedBox(height: 2),
                  _buildSubtitleText(widget.isEnglish ? option['subtitle_en'] : option['subtitle_te']),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildTapToAction(),
          ],
        ),
      ),
    );
  }

  // --- Reusable Component Widgets ---

  BoxDecoration _tileDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          offset: const Offset(0, 4),
          blurRadius: 12,
        )
      ],
      border: Border.all(color: Colors.grey.shade200, width: 1),
    );
  }

  Widget _buildIcon(Map<String, dynamic> option) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (option['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(option['icon'], color: option['color'], size: 28),
    );
  }

  Widget _buildTitleText(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSubtitleText(String subtitle) {
    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildTapToAction() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.isEnglish ? 'Tap to select' : 'ఎంచుకోవడానికి నొక్కండి',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.touch_app_outlined,
            color: Colors.grey.shade700,
            size: 12,
          ),
        ],
      ),
    );
  }
}