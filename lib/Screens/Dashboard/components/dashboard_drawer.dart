import 'package:flutter/material.dart';
import '../../feedback/feedback_screen.dart';
import '../../profile/profile_screen.dart';
import '../../Welcome/welcome_screen.dart'; // Add this import
import '../../../constants.dart';
import '../../../services/token_storage_service.dart'; // Add this import

class DashboardDrawer extends StatefulWidget {
  final String userName;
  final String phoneNumber;

  const DashboardDrawer({
    Key? key,
    required this.userName,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<DashboardDrawer> createState() => _DashboardDrawerState();
}

class _DashboardDrawerState extends State<DashboardDrawer>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  String? selectedMenuItem;

  final List<DrawerMenuItem> menuItems = [
    DrawerMenuItem(
      icon: Icons.dashboard_rounded,
      title: 'Dashboard',
      id: 'dashboard',
      gradient: const LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      ),
    ),
    DrawerMenuItem(
      icon: Icons.person_rounded,
      title: 'Profile',
      id: 'profile',
      gradient: const LinearGradient(
        colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
      ),
    ),
    DrawerMenuItem(
      icon: Icons.feedback_rounded,
      title: 'Feedback',
      id: 'feedback',
      gradient: const LinearGradient(
        colors: [Color(0xFFfa709a), Color(0xFFfee140)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    selectedMenuItem = 'dashboard';
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToScreen(BuildContext context, String screenId) {
    Navigator.pop(context); // Close drawer first

    // Navigate to specific screens
    switch (screenId) {
      case 'feedback':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FeedbackScreen(),
          ),
        );
        break;
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              userName: widget.userName,
              phoneNumber: widget.phoneNumber,
            ),
          ),
        );
        break;
      default:
        _showComingSoonSnackBar(context, screenId);
    }
  }

  void _showComingSoonSnackBar(BuildContext context, String screenName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForScreen(screenName),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$screenName - Coming Soon!',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  IconData _getIconForScreen(String screenName) {
    switch (screenName.toLowerCase()) {
      case 'recordings':
        return Icons.mic_rounded;
      case 'profile':
        return Icons.person_rounded;
      case 'feedback':
        return Icons.feedback_rounded;
      default:
        return Icons.arrow_forward_rounded;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from your account?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog first
                Navigator.pop(context);
                
                // Show loading indicator
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          SizedBox(width: 16),
                          Text('Logging out...'),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }

                try {
                  // Use the same method as profile screen - clearAuthData instead of forceLogout
                  await TokenStorageService.clearAuthData();
                  
                  // Small delay to ensure data is cleared
                  await Future.delayed(const Duration(milliseconds: 200));
                  
                  // Navigate back to welcome screen and clear all previous routes
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                } catch (e) {
                  // Handle logout error
                  print('Logout error: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        ),
                      ),
                    );
                  }
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF5F7FA),
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            // Enhanced Header
            Container(
              height: 180,
              width: double.infinity,
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
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: kPrimaryColor.withOpacity(0.3),
                    offset: const Offset(0, 8),
                    blurRadius: 20,
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
                      Colors.white.withOpacity(0.1),
                      // ignore: deprecated_member_use
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.menu_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Menu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '✨ Navigation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Enhanced Menu Items
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _slideController,
                      builder: (context, child) {
                        final animationDelay = index * 0.1;
                        final slideAnimation = Tween<Offset>(
                          begin: const Offset(-1.0, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _slideController,
                            curve: Interval(
                              animationDelay,
                              1.0,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                        );

                        final fadeAnimation = Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(
                          CurvedAnimation(
                            parent: _fadeController,
                            curve: Interval(
                              animationDelay,
                              1.0,
                              curve: Curves.easeOut,
                            ),
                          ),
                        );

                        return SlideTransition(
                          position: slideAnimation,
                          child: FadeTransition(
                            opacity: fadeAnimation,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: _buildEnhancedMenuItem(
                                context,
                                menuItems[index],
                                selectedMenuItem == menuItems[index].id,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Enhanced User Info Section
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeController,
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(20),
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
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 10),
                          blurRadius: 30,
                        ),
                      ],
                      border: Border.all(
                        // ignore: deprecated_member_use
                        color: kPrimaryColor.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  // ignore: deprecated_member_use
                                  colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.7)],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: kPrimaryColor.withOpacity(0.3),
                                    offset: const Offset(0, 4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
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
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    widget.phoneNumber,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _showLogoutDialog,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  // ignore: deprecated_member_use
                                  Colors.red.withOpacity(0.1),
                                  // ignore: deprecated_member_use
                                  Colors.red.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedMenuItem(
    BuildContext context,
    DrawerMenuItem item,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMenuItem = item.id;
        });
        if (item.id == 'dashboard') {
          Navigator.pop(context);
        } else {
          _navigateToScreen(context, item.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // ignore: deprecated_member_use
                    kPrimaryColor.withOpacity(0.1),
                    // ignore: deprecated_member_use
                    kPrimaryColor.withOpacity(0.05),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: kPrimaryColor, width: 1)
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: kPrimaryColor.withOpacity(0.1),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isActive ? item.gradient : null,
                color: isActive ? null : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: item.gradient.colors.first.withOpacity(0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: isActive
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            // ignore: deprecated_member_use
                            Colors.white.withOpacity(0.2),
                            // ignore: deprecated_member_use
                            Colors.white.withOpacity(0.0),
                          ],
                        )
                      : null,
                ),
                child: Icon(
                  item.icon,
                  color: isActive ? Colors.white : Colors.grey.shade600,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: isActive ? kPrimaryColor : Colors.black87,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: kPrimaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class DrawerMenuItem {
  final IconData icon;
  final String title;
  final String id;
  final LinearGradient gradient;

  DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.id,
    required this.gradient,
  });
}
