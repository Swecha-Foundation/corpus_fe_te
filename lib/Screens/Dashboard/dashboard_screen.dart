// ignore_for_file: deprecated_member_use

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
  String? _selectedCategory;
  bool _isEnglish = false; // Add language toggle state

  // Language content map
  final Map<String, Map<String, String>> _languageContent = {
    'en': {
      'title': 'Telugu Language Connect',
      'welcome': 'Welcome back,',
      'question': 'What do you want to speak about?',
      'description': 'Select a category to get topic ideas, then choose your input method to start sharing your thoughts.',
      'online': 'Online',
      'offline': 'Offline',
      'onlineMessage': 'You are now online',
      'offlineMessage': 'You are now offline',
      'fontSize': 'Font size',

    },
    'te': {
      'title': 'తెలుగు భాష సంపర్కే',
      'welcome': 'మళ్లీ స్వాగతం,',
      'question': 'మీరు దేని గురించి మాట్లాడాలనుకుంటున్నారు?',
      'description': 'విషయ ఆలోచనలను పొందడానికి ఒక వర్గాన్ని ఎంచుకోండి, ఆపై మీ ఆలోచనలను పంచుకోవడానికి మీ ఇన్‌పుట్ పద్ధతిని ఎంచుకోండి.',
      'online': 'ఆన్‌లైన్',
      'offline': 'ఆఫ్‌లైన్',
      'onlineMessage': 'మీరు ఇప్పుడు ఆన్‌లైన్‌లో ఉన్నారు',
      'offlineMessage': 'మీరు ఇప్పుడు ఆఫ్‌లైన్‌లో ఉన్నారు',
      'fontSize': 'ఫాంట్ పరిమాణం',
  
    },
  };

  String _getText(String key) {
    return _languageContent[_isEnglish ? 'en' : 'te']![key] ?? '';
  }

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
    
    // FIXED: Initialize the animations properly
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

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
      if (_showOptions && category == null) {
        _showOptions = false;
      }
    });
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
              _isOnline ? _getText('onlineMessage') : _getText('offlineMessage'),
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

  // ignore: unused_element
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
              '${_getText('fontSize')}: ${(_fontSize * 100).round()}%',
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

  void _toggleLanguage() {
    setState(() {
      _isEnglish = !_isEnglish;
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
                Icons.language,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _isEnglish ? 'Switched to English' : 'తెలుగుకు మార్చబడింది',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: kPrimaryColor,
        duration: const Duration(seconds: 2),
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
            // Fixed Top App Bar
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
                            color: Colors.black.withOpacity(0.08),
                            offset: const Offset(0, 8),
                            blurRadius: 20,
                          ),
                          BoxShadow(
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
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.7),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            // Menu Button
                            GestureDetector(
                              onTap: () {
                                _scaffoldKey.currentState?.openDrawer();
                                HapticFeedback.lightImpact();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      kPrimaryColor.withOpacity(0.1),
                                      kPrimaryColor.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: kPrimaryColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.menu_rounded,
                                  color: kPrimaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Title - Flexible to prevent overflow
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      kPrimaryColor.withOpacity(0.1),
                                      kPrimaryColor.withOpacity(0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: kPrimaryColor.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _getText('title'),
                                  style: TextStyle(
                                    fontSize: (14 * _fontSize).clamp(12.0, 16.0), // Clamp font size
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Control Buttons Row
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Online Status Button
                                GestureDetector(
                                  onTap: _toggleOnlineStatus,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: _isOnline
                                          ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)]
                                          : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _isOnline 
                                          ? Colors.green.withOpacity(0.3)
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
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getText(_isOnline ? 'online' : 'offline'),
                                          style: TextStyle(
                                            color: _isOnline ? Colors.green : Colors.grey,
                                            fontSize: (10 * _fontSize).clamp(8.0, 12.0),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: 6),
                                
                                // Language Toggle Button (A)
                                GestureDetector(
                                  onTap: _toggleLanguage,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          kPrimaryColor.withOpacity(0.1),
                                          kPrimaryColor.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: kPrimaryColor.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      _isEnglish ? 'తె' : 'A',
                                      style: TextStyle(
                                        fontSize: (14 * _fontSize).clamp(12.0, 16.0),
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
            
            // Main Content
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
                            // Welcome Section
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
                                  padding: const EdgeInsets.all(28),
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
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
                                                    Colors.white.withOpacity(0.2),
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
                                                  _getText('welcome'),
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
                                              kPrimaryColor.withOpacity(0.05),
                                              kPrimaryColor.withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: kPrimaryColor.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _getText('question'),
                                              style: TextStyle(
                                                fontSize: 18 * _fontSize,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _getText('description'),
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
                            
                            // Category Grid
                          CategoryGrid(
                          selectedCategory: _selectedCategory,
                          onCategorySelected: _onCategorySelected,
                          isEnglish: _isEnglish, // Pass the language state here
                        ),
                            const SizedBox(height: 40),
                            
                            // Recording Section
                            RecordingSection(
                              showOptions: _showOptions,
                              onToggleOptions: _toggleOptions,
                              selectedCategory: _selectedCategory,
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