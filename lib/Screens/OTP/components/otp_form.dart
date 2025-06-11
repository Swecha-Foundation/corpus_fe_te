// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../constants.dart';
import '../../../services/otp_api_service.dart';
import '../../../services/user_api_service.dart';
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
    
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
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
      }
    }
  }
  
  String _getOTPCode() {
    return _controllers.map((controller) => controller.text).join();
  }
  
  bool _isOTPComplete() {
    return _getOTPCode().length == 6;
  }
  
  void _verifyOTP() async {
    if (_isOTPComplete()) {
      setState(() {
        _isVerifying = true;
      });

      String otpCode = _getOTPCode();
      
      try {
        // Verify OTP API call
        final result = await OTPApiService.verifyOTP(widget.phoneNumber, otpCode);
        
        if (result['success']) {
          // Update last login for existing users
          if (!widget.isNewUser && widget.userData != null) {
            final userId = widget.userData!['id']?.toString();
            if (userId != null) {
              await UserApiService.updateLastLogin(userId);
            }
          }
          
          // Navigate to Dashboard after successful OTP verification
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  userName: widget.name,
                  phoneNumber: widget.phoneNumber,
                ),
              ),
            );
          }
        } else {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'OTP verification failed'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isVerifying = false;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter complete OTP'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
  
  void _resendOTP() async {
    setState(() {
      _isResending = true;
    });

    try {
      // Resend OTP API call
      final result = await OTPApiService.sendOTP(widget.phoneNumber);
      
      if (result['success']) {
        // Clear all fields
        for (var controller in _controllers) {
          controller.clear();
        }
        // Focus on first field
        FocusScope.of(context).requestFocus(_focusNodes[0]);
        
        // Restart countdown
        _startResendCountdown();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'OTP sent successfully'),
              backgroundColor: kPrimaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to resend OTP'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
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
                  onChanged: (value) => _onOTPChanged(value, index),
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