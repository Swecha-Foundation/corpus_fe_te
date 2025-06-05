import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';
import 'components/dashboard_drawer.dart';
import 'components/category_grid.dart';
import 'components/recording_section.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  
  const DashboardScreen({
    Key? key,
    required this.userName,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> 
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _appBarController;
  late AnimationController _contentController;
  late Animation<double> _appBarAnimation;
  late Animation<double> _contentAnimation;
  
  bool _showOptions = false;
  bool _isOnline = true;
  double _fontSize = 1.0;

  @override
  void initState() {
    super.initState();
    
    _appBarController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _appBarAnimation = CurvedAnimation(
      parent: _appBarController,
      curve: Curves.easeOutCubic,
    );
    
    _contentAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    );
    
    // Start animations
    _appBarController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _appBarController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _toggleOptions() {
    setState(() {
      _showOptions = !_showOptions;
    });
    HapticFeedback.lightImpact();
  }

  void _toggleOnlineStatus() {
    setState(() {
      _isOnline = !_isOnline;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _isOnline ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isOnline ? Icons.cloud : Icons.cloud_off,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _isOnline ? 'You are now online' : 'You are now offline',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: _isOnline ? Colors.green : Colors.grey,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _adjustFontSize() {
    setState(() {
      _fontSize = _fontSize >= 1.4 ? 1.0 : _fontSize + 0.2;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.text_fields,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Font size: ${(_fontSize * 100).round()}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: kPrimaryColor,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: DashboardDrawer(
        userName: widget.userName,
        phoneNumber: widget.phoneNumber,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Top App Bar
            AnimatedBuilder(
              animation: _appBarAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(_appBarAnimation),
                  child: FadeTransition(
                    opacity: _appBarAnimation,
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
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.08),
                            offset: const Offset(0, 8),
                            blurRadius: 20,
                          ),
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: kPrimaryColor.withOpacity(0.1),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Container(
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            // Enhanced Menu Button
                            GestureDetector(
                              onTap: () {
                                _scaffoldKey.currentState?.openDrawer();
                                HapticFeedback.lightImpact();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      // ignore: deprecated_member_use
                                      kPrimaryColor.withOpacity(0.1),
                                      // ignore: deprecated_member_use
                                      kPrimaryColor.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    // ignore: deprecated_member_use
                                    color: kPrimaryColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.menu_rounded,
                                  color: kPrimaryColor,
                                  size: 24,
                                ),
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Enhanced Title
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    // ignore: deprecated_member_use
                                    kPrimaryColor.withOpacity(0.1),
                                    // ignore: deprecated_member_use
                                    kPrimaryColor.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  // ignore: deprecated_member_use
                                  color: kPrimaryColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'తెలుగు భాష సంపర్కే',
                                style: TextStyle(
                                  fontSize: 16 * _fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Enhanced Control Buttons
                            Row(
                              children: [
                                // Online Status Button
                                GestureDetector(
                                  onTap: _toggleOnlineStatus,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: _isOnline
                                          // ignore: deprecated_member_use
                                          ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)]
                                          // ignore: deprecated_member_use
                                          : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _isOnline 
                                          // ignore: deprecated_member_use
                                          ? Colors.green.withOpacity(0.3)
                                          // ignore: deprecated_member_use
                                          : Colors.grey.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _isOnline ? Icons.cloud : Icons.cloud_off,
                                          color: _isOnline ? Colors.green : Colors.grey,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _isOnline ? 'Online' : 'Offline',
                                          style: TextStyle(
                                            color: _isOnline ? Colors.green : Colors.grey,
                                            fontSize: 12 * _fontSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: 8),
                                
                                // Font Size Button
                                GestureDetector(
                                  onTap: _adjustFontSize,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          // ignore: deprecated_member_use
                                          kPrimaryColor.withOpacity(0.1),
                                          // ignore: deprecated_member_use
                                          kPrimaryColor.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        // ignore: deprecated_member_use
                                        color: kPrimaryColor.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'A',
                                      style: TextStyle(
                                        fontSize: 16 * _fontSize,
                                        fontWeight: FontWeight.bold,
                                        color: kPrimaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Enhanced Main Content
            Expanded(
              child: AnimatedBuilder(
                animation: _contentAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _contentAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Enhanced Welcome Section
                            Container(
                              width: double.infinity,
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
                                  padding: const EdgeInsets.all(28),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                // ignore: deprecated_member_use
                                                colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  // ignore: deprecated_member_use
                                                  color: kPrimaryColor.withOpacity(0.3),
                                                  offset: const Offset(0, 8),
                                                  blurRadius: 16,
                                                ),
                                              ],
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(16),
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
                                                Icons.waving_hand,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Welcome back,',
                                                  style: TextStyle(
                                                    fontSize: 16 * _fontSize,
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  widget.userName,
                                                  style: TextStyle(
                                                    fontSize: 24 * _fontSize,
                                                    fontWeight: FontWeight.bold,
                                                    color: kPrimaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              // ignore: deprecated_member_use
                                              kPrimaryColor.withOpacity(0.05),
                                              // ignore: deprecated_member_use
                                              kPrimaryColor.withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            // ignore: deprecated_member_use
                                            color: kPrimaryColor.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'What do you want to speak about?',
                                              style: TextStyle(
                                                fontSize: 18 * _fontSize,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Select a category to get topic ideas, then choose your input method to start sharing your thoughts.',
                                              style: TextStyle(
                                                fontSize: 14 * _fontSize,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Category Grid with enhanced spacing
                            const CategoryGrid(),
                            
                            const SizedBox(height: 40),
                            
                            // Recording Section with enhanced spacing
                            RecordingSection(
                              showOptions: _showOptions,
                              onToggleOptions: _toggleOptions,
                            ),
                            
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}