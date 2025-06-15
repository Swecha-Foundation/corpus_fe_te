// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../constants.dart';
import '../../../services/otp_api_service.dart';
import '../../../services/user_api_service.dart';
import '../../../services/token_storage_service.dart';
import '../../Dashboard/dashboard_screen.dart';

class OTPForm extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final bool isNewUser;
  final Map<String, dynamic>? userData;
  
  const OTPForm({
    Key? key,
    required this.phoneNumber,
    required this.name,
    this.isNewUser = false,
    this.userData,
  }) : super(key: key);

  @override
  State<OTPForm> createState() => _OTPFormState();
}

class _OTPFormState extends State<OTPForm> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isVerifying = false;
  bool _isResending = false;
  
  // Countdown timer for resend button
  Timer? _resendTimer;
  int _resendCountdown = 0;
  
  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }
  
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }
  
  void _startResendCountdown() {
    setState(() {
      _resendCountdown = 60; // 60 seconds countdown
    });
    
    _resendTimer?.cancel(); // Cancel existing timer if any
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_resendCountdown > 0) {
          setState(() {
            _resendCountdown--;
          });
        } else {
          timer.cancel();
        }
      } else {
        timer.cancel();
      }
    });
  }
  
  void _onOTPChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        _focusNodes[index].unfocus();
        // Auto-verify when all digits are entered
        if (_isOTPComplete() && !_isVerifying) {
          _verifyOTP();
        }
      }
    }
  }
  
  void _onOTPBackspace(String value, int index) {
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }
  
  String _getOTPCode() {
    return _controllers.map((controller) => controller.text).join();
  }
  
  bool _isOTPComplete() {
    return _getOTPCode().length == 6;
  }
  
  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  void _verifyOTP() async {
    if (!_isOTPComplete()) {
      _showSnackBar('Please enter complete OTP', Colors.red);
      return;
    }
    
    if (_isVerifying) return; // Prevent multiple calls
    
    setState(() {
      _isVerifying = true;
    });

    String otpCode = _getOTPCode();
    
    try {
      print('Verifying OTP: $otpCode for phone: ${widget.phoneNumber}');
      
      // Verify OTP API call
      final result = await OTPApiService.verifyOTP(widget.phoneNumber, otpCode);
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        print('OTP verification successful');
        
        // Extract token data from response
        final responseData = result['data'];
        if (responseData != null) {
          String? accessToken = responseData['access_token']?.toString();
          String tokenType = responseData['token_type']?.toString() ?? 'bearer';
          String? userId = responseData['user_id']?.toString();
          String? phoneNumber = responseData['phone_number']?.toString();
          
          print('=== Token Information ===');
          print('Access Token: ${accessToken?.substring(0, 20)}...');
          print('Token Type: $tokenType');
          print('User ID: $userId');
          print('Phone Number: $phoneNumber');
          
          if (accessToken != null && accessToken.isNotEmpty) {
            // Store authentication data
            final stored = await TokenStorageService.storeAuthData(
              token: accessToken,
              tokenType: tokenType,
              userId: userId,
              phoneNumber: phoneNumber ?? widget.phoneNumber,
              userName: widget.name,
              // Token expires in 24 hours by default
              expiryTime: DateTime.now().add(const Duration(hours: 24)),
            );
            
            if (stored) {
              print('✅ Token stored successfully');
              
              // Debug: Print stored auth data
              await TokenStorageService.debugPrintAuthData();
              
              // Test token retrieval
              final retrievedToken = await TokenStorageService.getAuthToken();
              final authHeader = await TokenStorageService.getAuthorizationHeader();
              
              if (retrievedToken != null) {
                print('\n🔑 Token retrieved successfully:');
                print('Token: ${retrievedToken.substring(0, 20)}...');
                print('Auth Header: $authHeader');
                print('\n📋 You can now use this token in API calls');
              } else {
                print('❌ Failed to retrieve stored token');
              }
              
            } else {
              print('❌ Failed to store token');
            }
          } else {
            print('⚠️ No access token received in response');
          }
        }
        
        // Handle successful OTP verification
        if (widget.isNewUser) {
          _showSnackBar('Registration completed successfully!', Colors.green);
        } else {
          // Update last login for existing users
          if (widget.userData != null) {
            final userIdFromData = widget.userData!['id']?.toString();
            if (userIdFromData != null) {
              try {
                // Get the stored token for the API call
                final storedToken = await TokenStorageService.getAuthToken();
                if (storedToken != null) {
                  await UserApiService.updateLastLogin(userIdFromData, authToken: storedToken);
                  print('✅ Last login updated successfully');
                } else {
                  print('⚠️ No stored token available for last login update');
                }
              } catch (e) {
                print('Failed to update last login: $e');
                // Continue with login process even if last login update fails
              }
            }
          }
          
          _showSnackBar('Login successful!', Colors.green);
        }
        
        // Small delay to show success message
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Navigate to Dashboard after successful OTP verification
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                userName: widget.name,
                phoneNumber: widget.phoneNumber,
              ),
            ),
            (route) => false, // Remove all previous routes
          );
        }
      } else {
        // Show error message
        String errorMessage = result['message'] ?? 'OTP verification failed';
        
        // Provide user-friendly error messages
        if (errorMessage.toLowerCase().contains('invalid') ||
            errorMessage.toLowerCase().contains('incorrect') ||
            errorMessage.toLowerCase().contains('wrong')) {
          errorMessage = 'Invalid OTP. Please check and try again.';
        } else if (errorMessage.toLowerCase().contains('expired')) {
          errorMessage = 'OTP has expired. Please request a new one.';
        }
        
        _showSnackBar(errorMessage, Colors.red);
        
        // Clear OTP fields on error
        for (var controller in _controllers) {
          controller.clear();
        }
        // Focus on first field
        if (mounted) {
          FocusScope.of(context).requestFocus(_focusNodes[0]);
        }
      }
    } catch (e) {
      print('OTP verification error: $e');
      if (mounted) {
        _showSnackBar('Network error occurred. Please try again.', Colors.red);
        
        // Clear OTP fields on error
        for (var controller in _controllers) {
          controller.clear();
        }
        // Focus on first field
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }
  
  void _resendOTP() async {
    if (_isResending) return; // Prevent multiple calls
    
    setState(() {
      _isResending = true;
    });

    try {
      print('Resending OTP to: ${widget.phoneNumber}');
      
      // Resend OTP API call
      final result = await OTPApiService.sendOTP(widget.phoneNumber);
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        // Clear all fields
        for (var controller in _controllers) {
          controller.clear();
        }
        // Focus on first field
        FocusScope.of(context).requestFocus(_focusNodes[0]);
        
        // Restart countdown
        _startResendCountdown();
        
        String message = result['message'] ?? 'OTP sent successfully';
        _showSnackBar(message, Colors.green);
      } else {
        String errorMessage = result['message'] ?? 'Failed to resend OTP';
        String errorType = result['error'] ?? '';
        
        if (errorType == 'rate_limit_client_side' || errorType == 'rate_limit_server_side') {
          int waitTime = result['waitTime'] ?? 30;
          errorMessage = 'Please wait $waitTime seconds before requesting another OTP';
          _showSnackBar(errorMessage, Colors.orange);
        } else {
          _showSnackBar(errorMessage, Colors.red);
        }
      }
    } catch (e) {
      print('Resend OTP error: $e');
      if (mounted) {
        _showSnackBar('Network error occurred. Please try again.', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          // Welcome message based on user type
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: defaultPadding),
            decoration: BoxDecoration(
              color: widget.isNewUser 
                  ? Colors.green.withOpacity(0.1)
                  : kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isNewUser 
                    ? Colors.green.withOpacity(0.3)
                    : kPrimaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.isNewUser ? Icons.celebration : Icons.login,
                  color: widget.isNewUser ? Colors.green : kPrimaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.isNewUser 
                        ? 'Welcome ${widget.name}! Complete your registration'
                        : 'Welcome back ${widget.name}!',
                    style: TextStyle(
                      color: widget.isNewUser ? Colors.green : kPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Text(
            'Enter the 6-digit OTP sent to',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.phoneNumber,
            style: const TextStyle(
              color: kPrimaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: defaultPadding * 2),
          
          // OTP Input Boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 45,
                height: 55,
                child: TextFormField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: kPrimaryLightColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: kPrimaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(0),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    _onOTPChanged(value, index);
                    _onOTPBackspace(value, index);
                  },
                  onTap: () {
                    _controllers[index].selection = TextSelection.fromPosition(
                      TextPosition(offset: _controllers[index].text.length),
                    );
                  },
                  onEditingComplete: () {
                    if (index == 5 && _isOTPComplete()) {
                      _verifyOTP();
                    }
                  },
                ),
              );
            }),
          ),
          
          const SizedBox(height: defaultPadding * 2),
          
          // Verify Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: (_isOTPComplete() && !_isVerifying) 
                    ? [kPrimaryColor, kPrimaryColor.withOpacity(0.8)]
                    : [Colors.grey, Colors.grey.withOpacity(0.8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: (_isOTPComplete() && !_isVerifying) 
                  ? [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: ElevatedButton(
              onPressed: (_isOTPComplete() && !_isVerifying) ? _verifyOTP : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isVerifying
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isNewUser ? Icons.check_circle : Icons.verified,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.isNewUser ? "Complete Registration" : "Verify & Login",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          
          const SizedBox(height: defaultPadding),
          
          // Resend OTP with countdown
          TextButton(
            onPressed: (_resendCountdown == 0 && !_isResending) ? _resendOTP : null,
            child: _isResending
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    ),
                  )
                : Text(
                    _resendCountdown > 0 
                        ? "Resend OTP in ${_resendCountdown}s"
                        : "Didn't receive OTP? Resend",
                    style: TextStyle(
                      color: _resendCountdown > 0 ? Colors.grey : kPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          
          const SizedBox(height: defaultPadding),
          
          // Back to Login/Signup
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              widget.isNewUser ? "← Back to Sign Up" : "← Back to Login",
              style: const TextStyle(
                color: kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}