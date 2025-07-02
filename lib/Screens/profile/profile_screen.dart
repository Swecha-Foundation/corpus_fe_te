// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../Welcome/welcome_screen.dart';
import '../../../services/token_storage_service.dart';
import '../../../services/user_api_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String phoneNumber;

  const ProfileScreen({
    Key? key,
    required this.userName,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  // Profile data
  String displayName = '';
  String email = '';
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  bool biometricEnabled = false;
  int totalContributions = 0;
  String totalStorageUsed = '0 B';
  int daysActive = 0;
  bool isLoadingStats = true;
  String userPhone = '';
  String userGender = '';
  String userDateOfBirth = '';
  String userPlace = '';
  String userId = '';
  bool isUserActive = false;
  bool hasGivenConsent = false;
  DateTime? consentGivenAt;
  DateTime? lastLoginAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool isLoadingProfile = true;

  bool _isEmailRevealed = false;
  bool _isPhoneRevealed = false;
  late AnimationController _revealController;
  late Animation<double> _revealAnimation;

  @override
  void initState() {
    super.initState();
    displayName = widget.userName;
    email = '${widget.userName.toLowerCase().replaceAll(' ', '')}@example.com';

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeInOut,
    );

    // Add a small delay before starting animations and fetching data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
        _fetchUserProfile();
        _fetchUserContributions(); // Fetch dynamic data
      }
    });
  }

  @override
  void dispose() {
    // Properly dispose animation controllers
    _fadeController.dispose();
    _slideController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: kPrimaryColor,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    kPrimaryColor,
                    kPrimaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: FlexibleSpaceBar(
                title: const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _showEditProfileDialog(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Profile Header Card
                  _buildProfileHeaderCard(),
                  const SizedBox(height: 24),

                  // Quick Stats
                  _buildQuickStats(),
                  const SizedBox(height: 24),

                  // Settings Section
                  _buildSettingsSection(),
                  const SizedBox(height: 24),

                  // Account Actions
                  _buildAccountActionsSection(),
                  const SizedBox(height: 24),

                  // App Info
                  _buildAppInfoSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeController, _slideController]),
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _slideController,
              curve: Curves.easeOutCubic,
            )),
            child: Container(
              padding: const EdgeInsets.all(24),
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
                    offset: const Offset(0, 10),
                    blurRadius: 30,
                  ),
                ],
                border: Border.all(
                  color: kPrimaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Profile Picture (same as before)
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              kPrimaryColor,
                              kPrimaryColor.withOpacity(0.7)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(0.3),
                              offset: const Offset(0, 8),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
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
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showChangePhotoDialog(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF43e97b).withOpacity(0.3),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // User Info with loading states and dynamic data
                  isLoadingProfile
                      ? Column(
                          children: [
                            const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(kPrimaryColor),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Loading profile...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            // Name
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Phone Number with Click-to-Reveal
                            GestureDetector(
                              onTap: _togglePhoneReveal,
                              child: AnimatedBuilder(
                                animation: _revealAnimation,
                                builder: (context, child) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _isPhoneRevealed
                                          ? kPrimaryColor.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _isPhoneRevealed
                                            ? kPrimaryColor.withOpacity(0.3)
                                            : Colors.grey.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.phone_rounded,
                                          size: 16,
                                          color: _isPhoneRevealed
                                              ? kPrimaryColor
                                              : Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 8),
                                        AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: Text(
                                            _isPhoneRevealed
                                                ? (userPhone.isNotEmpty
                                                    ? userPhone
                                                    : widget.phoneNumber)
                                                : _maskPhone(
                                                    userPhone.isNotEmpty
                                                        ? userPhone
                                                        : widget.phoneNumber),
                                            key: ValueKey(_isPhoneRevealed),
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: _isPhoneRevealed
                                                  ? kPrimaryColor
                                                  : Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        AnimatedRotation(
                                          turns: _isPhoneRevealed ? 0.5 : 0,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: Icon(
                                            _isPhoneRevealed
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            size: 16,
                                            color: _isPhoneRevealed
                                                ? kPrimaryColor
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Email with Click-to-Reveal
                            GestureDetector(
                              onTap: _toggleEmailReveal,
                              child: AnimatedBuilder(
                                animation: _revealAnimation,
                                builder: (context, child) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: _isEmailRevealed
                                          ? kPrimaryColor.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _isEmailRevealed
                                            ? kPrimaryColor.withOpacity(0.3)
                                            : Colors.grey.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.email_rounded,
                                          size: 16,
                                          color: _isEmailRevealed
                                              ? kPrimaryColor
                                              : Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 8),
                                        AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: Text(
                                            _isEmailRevealed
                                                ? email
                                                : _maskEmail(email),
                                            key: ValueKey(_isEmailRevealed),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _isEmailRevealed
                                                  ? kPrimaryColor
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        AnimatedRotation(
                                          turns: _isEmailRevealed ? 0.5 : 0,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          child: Icon(
                                            _isEmailRevealed
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            size: 16,
                                            color: _isEmailRevealed
                                                ? kPrimaryColor
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Location (if available)
                            if (userPlace.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    userPlace,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // Additional info (Gender, Date of Birth) - optional
                            if (userGender.isNotEmpty ||
                                userDateOfBirth.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (userGender.isNotEmpty) ...[
                                      Icon(
                                        userGender.toLowerCase() == 'male'
                                            ? Icons.male
                                            : userGender.toLowerCase() ==
                                                    'female'
                                                ? Icons.female
                                                : Icons.person,
                                        size: 16,
                                        color: kPrimaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        userGender,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                    if (userGender.isNotEmpty &&
                                        userDateOfBirth.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        width: 1,
                                        height: 12,
                                        color: kPrimaryColor.withOpacity(0.3),
                                      ),
                                    if (userDateOfBirth.isNotEmpty) ...[
                                      Icon(
                                        Icons.cake_rounded,
                                        size: 16,
                                        color: kPrimaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(userDateOfBirth),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],

                            // Account status indicator
                            if (isUserActive) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Active',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Hint text for click-to-reveal
                            const SizedBox(height: 12),
                            Text(
                              'Tap on phone or email to reveal',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  String _formatStorageSize(int bytes) {
    if (bytes == 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${suffixes[i]}';
  }

  int _calculateDaysActive(Map<String, dynamic> data) {
    // This is a simplified calculation - you might want to implement
    // more sophisticated logic based on actual contribution dates
    int totalContributions = data['total_contributions'] ?? 0;

    if (totalContributions == 0) return 0;

    // Estimate days active based on contributions (you can improve this logic)
    return (totalContributions / 2).ceil().clamp(1, 365);
  }

// Mask email address
  String _maskEmail(String email) {
    if (email.isEmpty) return email;

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) return email;

    final maskedUsername =
        username.substring(0, 2) + '*' * (username.length - 2);
    return '$maskedUsername@$domain';
  }

// Mask phone number
  String _maskPhone(String phone) {
    if (phone.isEmpty) return phone;

    // Remove any non-digit characters for processing
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length < 6) return phone;

    // Keep country code and last 2 digits visible
    if (digits.length >= 10) {
      final countryCode = phone.startsWith('+') ? phone.substring(0, 3) : '';
      final lastTwo = digits.substring(digits.length - 2);
      final maskedMiddle =
          '*' * (digits.length - 2 - (countryCode.isEmpty ? 0 : 2));

      if (countryCode.isNotEmpty) {
        return '$countryCode$maskedMiddle$lastTwo';
      } else {
        return '${digits.substring(0, 2)}$maskedMiddle$lastTwo';
      }
    }

    return phone;
  }

// Toggle email reveal
  void _toggleEmailReveal() {
    setState(() {
      _isEmailRevealed = !_isEmailRevealed;
    });

    if (_isEmailRevealed) {
      _revealController.forward();
    } else {
      _revealController.reverse();
    }
  }

// Toggle phone reveal
  void _togglePhoneReveal() {
    setState(() {
      _isPhoneRevealed = !_isPhoneRevealed;
    });

    if (_isPhoneRevealed) {
      _revealController.forward();
    } else {
      _revealController.reverse();
    }
  }

  String? _decodeUserIdFromToken(String token) {
    try {
      print('DEBUG: Attempting to decode user ID from token');

      // JWT tokens have 3 parts separated by dots: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        print(
            'DEBUG: Invalid JWT format - expected 3 parts, got ${parts.length}');
        return null;
      }

      // Get the payload (middle part)
      String payload = parts[1];

      // JWT uses base64url encoding, but Dart's base64 decoder expects standard base64
      // Add padding if needed (base64 strings should be multiples of 4)
      while (payload.length % 4 != 0) {
        payload += '=';
      }

      // Replace URL-safe characters with standard base64 characters
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');

      print('DEBUG: Payload to decode: ${payload.substring(0, 50)}...');

      // Decode the base64 payload
      final decodedBytes = base64Decode(payload);
      final decodedString = utf8.decode(decodedBytes);

      print('DEBUG: Decoded payload string: $decodedString');

      // Parse JSON
      final Map<String, dynamic> payloadMap = json.decode(decodedString);

      print('DEBUG: Parsed payload map: $payloadMap');

      // Common JWT fields that might contain user ID
      final possibleUserIdFields = [
        'user_id',
        'userId',
        'sub', // Subject - standard JWT field
        'id',
        'uid',
        'user',
      ];

      String? userId;
      for (String field in possibleUserIdFields) {
        if (payloadMap.containsKey(field)) {
          userId = payloadMap[field]?.toString();
          if (userId != null && userId.isNotEmpty) {
            print('DEBUG: Found user ID "$userId" in field "$field"');
            break;
          }
        }
      }

      if (userId == null) {
        print('DEBUG: No user ID found in any expected fields');
        print('DEBUG: Available fields: ${payloadMap.keys.toList()}');
      }

      return userId;
    } catch (e) {
      print('DEBUG: Error decoding user ID from token: $e');
      return null;
    }
  }

  Future<void> _fetchUserContributions() async {
    print('DEBUG: Starting _fetchUserContributions');

    try {
      // Get all user data
      final userData = await TokenStorageService.getUserData();
      print('DEBUG: User data: $userData');

      // Check if user is logged in
      final isLoggedIn = userData['isLoggedIn'] == 'true';
      if (!isLoggedIn) {
        print('DEBUG: ERROR - User is not logged in');
        if (mounted) {
          setState(() {
            isLoadingStats = false;
          });
        }
        return;
      }

      // Get auth token
      final authToken = userData['token'];
      if (authToken == null || authToken.isEmpty) {
        print('DEBUG: ERROR - Auth Token is null or empty');
        if (mounted) {
          setState(() {
            isLoadingStats = false;
          });
        }
        return;
      }

      // Try to get userId from storage first
      String? userId = userData['userId'];

      // If userId is null or empty, try to decode from token
      if (userId == null || userId.isEmpty) {
        print(
            'DEBUG: User ID not found in storage, attempting to decode from token...');
        userId = _decodeUserIdFromToken(authToken);

        if (userId != null) {
          print('DEBUG: Successfully decoded user ID from token: $userId');
          // Optionally save it for future use
          await TokenStorageService.storeUserId(userId);
        }
      }

      if (userId == null || userId.isEmpty) {
        print('DEBUG: ERROR - Could not get user ID from storage or token');
        if (mounted) {
          setState(() {
            isLoadingStats = false;
          });
        }
        return;
      }

      print('DEBUG: Using user ID: $userId');

      // Continue with API call
      final result = await UserApiService.getUserContributions(
        userId: userId,
        authToken: authToken,
      ).timeout(
        Duration(seconds: 15),
        onTimeout: () {
          print('DEBUG: API call timed out after 15 seconds');
          throw TimeoutException('API call timed out', Duration(seconds: 15));
        },
      );

      // Rest of your existing API handling code...
      print('DEBUG: API result: $result');

      if (result != null && result['success'] == true) {
        final data = result['data'];
        if (data != null && mounted) {
          final contributions = data['total_contributions'] ?? 0;
          final totalSize = data['total_size'] ?? 0;

          setState(() {
            totalContributions = contributions;
            totalStorageUsed = _formatStorageSize(totalSize);
            daysActive = _calculateDaysActive(data);
            isLoadingStats = false;
          });
          print('DEBUG: UI updated successfully');
        }
      } else {
        print('DEBUG: API call failed: ${result?['message']}');
        if (mounted) {
          setState(() {
            isLoadingStats = false;
          });
        }
      }
    } catch (e, stackTrace) {
      print('DEBUG: Exception: $e');
      print('DEBUG: Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          isLoadingStats = false;
        });
      }
    }
  }

  Future<void> _fetchUserProfile() async {
    print('DEBUG: Starting _fetchUserProfile');
    try {
      final result = await TokenStorageService.getCurrentUserFromApi();

      if (result != null && result['success'] == true) {
        final userData = result['data'];

        if (userData != null && mounted) {
          setState(() {
            displayName = userData['name'] ?? widget.userName;
            email = userData['email'] ??
                '${widget.userName.toLowerCase().replaceAll(' ', '')}@example.com';
            userPhone = userData['phone'] ?? widget.phoneNumber;
            userGender = userData['gender'] ?? '';
            userDateOfBirth = userData['date_of_birth'] ?? '';
            userPlace = userData['place'] ?? '';
            userId = userData['id'] ?? '';
            isUserActive = userData['is_active'] ?? false;
            hasGivenConsent = userData['has_given_consent'] ?? false;

            // Parse datetime strings
            if (userData['consent_given_at'] != null) {
              consentGivenAt = DateTime.tryParse(userData['consent_given_at']);
            }
            if (userData['last_login_at'] != null) {
              lastLoginAt = DateTime.tryParse(userData['last_login_at']);
            }
            if (userData['created_at'] != null) {
              createdAt = DateTime.tryParse(userData['created_at']);
            }
            if (userData['updated_at'] != null) {
              updatedAt = DateTime.tryParse(userData['updated_at']);
            }

            isLoadingProfile = false;
          });

          // Store profile data locally for offline access
          await TokenStorageService.storeUserProfile(
            name: displayName,
            email: email,
            phone: userPhone,
            gender: userGender,
            dateOfBirth: userDateOfBirth,
            place: userPlace,
            userId: userId,
          );

          print('DEBUG: Profile updated and stored successfully');
        }
      } else {
        print('DEBUG: Failed to fetch user profile: ${result?['error']}');
        // Try to load from local storage as fallback
        final storedProfile = await TokenStorageService.getStoredUserProfile();
        if (storedProfile.isNotEmpty && mounted) {
          setState(() {
            displayName = storedProfile['name'] ?? widget.userName;
            email = storedProfile['email'] ??
                '${widget.userName.toLowerCase().replaceAll(' ', '')}@example.com';
            userPhone = storedProfile['phone'] ?? widget.phoneNumber;
            userGender = storedProfile['gender'] ?? '';
            userDateOfBirth = storedProfile['dateOfBirth'] ?? '';
            userPlace = storedProfile['place'] ?? '';
            userId = storedProfile['userId'] ?? '';
            isLoadingProfile = false;
          });
          print('DEBUG: Loaded profile from local storage');
        } else if (mounted) {
          setState(() {
            isLoadingProfile = false;
          });
        }
      }
    } catch (e, stackTrace) {
      print('DEBUG: Exception in _fetchUserProfile: $e');
      print('DEBUG: Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          isLoadingProfile = false;
        });
      }
    }
  }

  Widget _buildQuickStats() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.4),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          )),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  isLoadingStats ? '...' : totalContributions.toString(),
                  'Recordings',
                  const Color(0xFF4facfe),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  isLoadingStats ? '...' : totalStorageUsed,
                  'Storage Used',
                  const Color(0xFF43e97b),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  isLoadingStats ? '...' : daysActive.toString(),
                  'Days Active',
                  const Color(0xFFfa709a),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 15,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          )),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 8),
                  blurRadius: 25,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.notifications_rounded,
                  title: 'Push Notifications',
                  subtitle: 'Receive app notifications',
                  trailing: Switch(
                    value: notificationsEnabled,
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          notificationsEnabled = value;
                        });
                      }
                    },
                    activeColor: kPrimaryColor,
                  ),
                  color: const Color(0xFF4facfe),
                ),
                /*_buildSettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  subtitle: 'Toggle dark theme',
                  trailing: Switch(
                    value: darkModeEnabled,
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          darkModeEnabled = value;
                        });
                      }
                    },
                    activeColor: kPrimaryColor,
                  ),
                  color: const Color(0xFF667eea),
                ),
                _buildSettingsTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Security',
                  subtitle: 'Use fingerprint to unlock',
                  trailing: Switch(
                    value: biometricEnabled,
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          biometricEnabled = value;
                        });
                      }
                    },
                    activeColor: kPrimaryColor,
                  ),
                  color: const Color(0xFF43e97b),
                ),*/
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildAccountActionsSection() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.6),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
          )),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 8),
                  blurRadius: 25,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                _buildActionTile(
                  icon: Icons.lock_reset_rounded,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  color: const Color(0xFF667eea),
                  onTap: () => _showChangePasswordDialog(),
                ),
                _buildActionTile(
                  icon: Icons.storage_rounded,
                  title: 'Storage Management',
                  subtitle: 'Manage app storage',
                  color: const Color(0xFF4facfe),
                  onTap: () => _showStorageDialog(),
                ),
                _buildActionTile(
                  icon: Icons.backup_rounded,
                  title: 'Backup & Sync',
                  subtitle: 'Backup your data',
                  color: const Color(0xFF43e97b),
                  onTap: () => _showBackupDialog(),
                ),
                _buildActionTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  subtitle: 'Sign out from your account',
                  color: Colors.orange,
                  onTap: () => _showLogoutDialog(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.7),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic),
          )),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 8),
                  blurRadius: 25,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Audio Recorder Pro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoButton(
                        'Privacy Policy', Icons.privacy_tip_rounded),
                    _buildInfoButton(
                        'Terms of Service', Icons.description_rounded),
                    _buildInfoButton('Support', Icons.help_outline_rounded),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoButton(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening $title...'),
              backgroundColor: kPrimaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: kPrimaryColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: displayName);
    final emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: kPrimaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Edit Profile', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kPrimaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kPrimaryColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
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
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }

                try {
                  // Force complete logout - this will clear ALL auth data
                  await TokenStorageService.forceLogout();

                  // Additional verification - ensure clearance
                  await TokenStorageService.debugPrintAuthData();

                  await TokenStorageService.clearUserProfile();

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
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePhotoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Change Profile Photo'),
          content:
              const Text('This feature will be available in the next update.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: kPrimaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Change Password'),
          content: const Text(
              'Password change functionality will be implemented soon.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: kPrimaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Storage Management'),
          content: const Text('Storage management features coming soon.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: kPrimaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Backup & Sync'),
          content: const Text('Backup functionality will be available soon.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: kPrimaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from your account?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            // In your _showLogoutDialog method, replace the ElevatedButton onPressed with this:
            ElevatedButton(
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
                      backgroundColor: Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }

                try {
                  // Clear all stored authentication data
                  await TokenStorageService.clearAuthData();
                  await TokenStorageService.clearUserProfile();

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
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
