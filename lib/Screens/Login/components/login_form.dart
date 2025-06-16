// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../../services/otp_api_service.dart';
import '../../../services/user_api_service.dart';
import '../../Signup/signup_screen.dart';
import '../../../services/token_storage_service.dart'; 
import '../../OTP/otp_screen.dart';
import '../../Dashboard/dashboard_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _usePasswordLogin = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phoneNumber) {
    String cleanNumber = phoneNumber.trim();
    if (cleanNumber.startsWith('+91')) {
      return cleanNumber;
    }
    return '+91$cleanNumber';
  }

  void _showSnackBar(String message, Color backgroundColor, {SnackBarAction? action}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: action,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _handleOTPLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    String phoneNumber = _formatPhoneNumber(_phoneController.text.trim());
    
    try {
      print('Attempting OTP login for phone: $phoneNumber');
      
      if (!mounted) return;
      
      // Directly send OTP without checking user existence first
      // The OTP service will handle whether the user exists or not
      final otpResult = await OTPApiService.sendOTP(phoneNumber);
      
      if (!mounted) return;
      
      print('OTP result: $otpResult');
      
      if (otpResult['success'] == true) {
        print('OTP sent successfully');
        if (mounted) {
          // Show success message
          _showSnackBar('OTP sent to your phone number', Colors.green);
          
          // Navigate to OTP screen with minimal user data
          // We'll get the full user data after OTP verification
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: phoneNumber,
                name: 'User', // Default name, will be updated after verification
                isNewUser: false, // Assume existing user for login
                userData: {'phone': phoneNumber},
              ),
            ),
          );
        }
      } else {
        // Handle different types of errors
        String errorMessage = otpResult['message'] ?? 'Failed to send OTP';
        String errorType = otpResult['error'] ?? '';
        
        if (errorType == 'rate_limit_client_side' || errorType == 'rate_limit_server_side') {
          // Handle rate limiting
          int waitTime = otpResult['waitTime'] ?? 20;
          _showSnackBar(
            'Please wait $waitTime seconds before requesting another OTP',
            Colors.orange,
          );
        } else if (errorType == 'user_not_found' || errorMessage.toLowerCase().contains('user not found')) {
          // User doesn't exist - suggest signup
          _showSnackBar(
            'No account found with this phone number. Please sign up first.',
            Colors.orange,
            action: SnackBarAction(
              label: 'Sign Up',
              textColor: Colors.white,
              onPressed: () {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                }
              },
            ),
          );
        } else if (errorType == 'timeout') {
          _showSnackBar(
            'Request timed out. Please check your internet connection and try again.',
            Colors.red,
          );
        } else {
          // Other errors
          _showSnackBar(errorMessage, Colors.red);
        }
      }
    } catch (e) {
      print('OTP Login error: $e');
      if (mounted) {
        _showSnackBar('Network error occurred. Please try again.', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handlePasswordLogin() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    String phoneNumber = _formatPhoneNumber(_phoneController.text.trim());
    String password = _passwordController.text.trim();
    
    try {
      print('Attempting password login for phone: $phoneNumber');
      
      if (!mounted) return;
      
      final loginResult = await UserApiService.loginUser(
        phone: phoneNumber,
        password: password,
      );
      
      if (!mounted) return;
      
      print('Login result: $loginResult');
      
      if (loginResult['success'] == true) {
        // Password login successful
        print('Password login successful');
        
        // Extract token and user data from response
        final responseData = loginResult['data'];
        if (responseData == null) {
          throw Exception('Invalid response data from server');
        }
        
        print('Response data: $responseData');
        
        // Extract authentication token
        String? authToken;
        String tokenType = 'bearer';
        
        // Check for different possible token field names
        if (responseData['access_token'] != null) {
          authToken = responseData['access_token'].toString();
        } else if (responseData['token'] != null) {
          authToken = responseData['token'].toString();
        } else if (responseData['auth_token'] != null) {
          authToken = responseData['auth_token'].toString();
        }
        
        // Extract token type if available
        if (responseData['token_type'] != null) {
          tokenType = responseData['token_type'].toString();
        }
        
        // Get user data
        String? userId;
        String userName = 'User'; // Default fallback
        
        // Extract user information from different possible structures
        Map<String, dynamic>? userData;
        if (responseData['user'] != null) {
          userData = responseData['user'] as Map<String, dynamic>?;
        } else if (responseData['user_data'] != null) {
          userData = responseData['user_data'] as Map<String, dynamic>?;
        } else if (responseData['id'] != null) {
          // User data might be at root level
          userData = responseData;
        }
        
        if (userData != null) {
          if (userData['id'] != null) {
            userId = userData['id'].toString();
          } else if (userData['user_id'] != null) {
            userId = userData['user_id'].toString();
          }
          
          if (userData['name'] != null) {
            userName = userData['name'].toString();
          } else if (userData['full_name'] != null) {
            userName = userData['full_name'].toString();
          } else if (userData['username'] != null) {
            userName = userData['username'].toString();
          }
        }
        
        print('Extracted - Token: ${authToken != null ? 'Present' : 'Missing'}, UserId: $userId, UserName: $userName');
        
        // Store authentication data - only if authToken is not null
        if (authToken != null && authToken.isNotEmpty) {
          try {
            await TokenStorageService.storeAuthData(
              token: authToken,
              tokenType: tokenType,
              userId: userId,
              phoneNumber: phoneNumber,
              userName: userName,
            );
            
            print('Auth data stored successfully');
          } catch (storageError) {
            print('Failed to store auth data: $storageError');
            throw Exception('Failed to store authentication data');
          }
        } else {
          print('No authentication token received in response');
          // Check if this is still a successful login without token (some APIs work this way)
          // In this case, we might just need to store basic user info
          try {
            await TokenStorageService.storeAuthData(
              token: '', // Empty token
              tokenType: tokenType,
              userId: userId,
              phoneNumber: phoneNumber,
              userName: userName,
            );
            print('Basic user data stored without token');
          } catch (storageError) {
            print('Failed to store basic user data: $storageError');
          }
        }
        
        // Update last login if we have the required data
        if (userId != null && authToken != null && authToken.isNotEmpty && mounted) {
          try {
            await UserApiService.updateLastLogin(userId, authToken: authToken);
            print('Last login updated successfully');
          } catch (e) {
            print('Failed to update last login: $e');
            // Continue with login process even if last login update fails
          }
        }
        
        if (!mounted) return;
        
        // Show success message
        _showSnackBar('Login successful!', Colors.green);
        
        // Add a small delay to show the success message
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                userName: userName,
                phoneNumber: phoneNumber,
              ),
            ),
            (route) => false, // Remove all previous routes
          );
        }
        
      } else {
        // Password login failed
        String errorMessage = loginResult['message'] ?? 'Login failed';
        String errorType = loginResult['error']?.toString() ?? '';
        
        print('Login failed - Error: $errorType, Message: $errorMessage');
        
        // Provide more user-friendly error messages
        if (errorMessage.toLowerCase().contains('invalid') || 
            errorMessage.toLowerCase().contains('incorrect') ||
            errorMessage.toLowerCase().contains('unauthorized') ||
            errorMessage.toLowerCase().contains('wrong') ||
            errorType.contains('invalid_credentials')) {
          errorMessage = 'Invalid phone number or password. Please check your credentials.';
        } else if (errorMessage.toLowerCase().contains('user not found') || 
                   errorMessage.toLowerCase().contains('does not exist') ||
                   errorMessage.toLowerCase().contains('no account') ||
                   errorType == 'user_not_found') {
          errorMessage = 'No account found with this phone number. Please sign up first.';
        } else if (errorType == 'timeout') {
          errorMessage = 'Request timed out. Please check your internet connection and try again.';
        } else if (errorType == 'network_error') {
          errorMessage = 'Network connection error. Please check your internet connection.';
        }
        
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e) {
      print('Password Login error: $e');
      if (mounted) {
        String errorMessage = 'Network error occurred. Please try again.';
        
        // Provide more specific error messages based on the exception
        if (e.toString().contains('token')) {
          errorMessage = 'Login authentication failed. Please try again.';
        } else if (e.toString().contains('connection')) {
          errorMessage = 'Connection error. Please check your internet connection.';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Request timed out. Please try again.';
        }
        
        _showSnackBar(errorMessage, Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Login Method Toggle
          Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.only(bottom: defaultPadding),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!_isLoading) {
                        setState(() {
                          _usePasswordLogin = false;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_usePasswordLogin ? kPrimaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Login with OTP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_usePasswordLogin ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!_isLoading) {
                        setState(() {
                          _usePasswordLogin = true;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _usePasswordLogin ? kPrimaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Login with Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _usePasswordLogin ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Info text
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: defaultPadding),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: kPrimaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: kPrimaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _usePasswordLogin 
                        ? 'Enter your phone number and password to login'
                        : 'Enter your registered phone number to receive OTP',
                    style: const TextStyle(
                      color: kPrimaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Phone Number Field
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.grey[50],
            ),
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: _usePasswordLogin ? TextInputAction.next : TextInputAction.done,
              maxLength: 10,
              enabled: !_isLoading,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.trim().length != 10) {
                  return 'Please enter exactly 10 digits';
                }
                // Basic validation for Indian phone numbers (starts with 6-9)
                if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: "Enter your phone number",
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: kPrimaryColor,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                counterText: '',
              ),
            ),
          ),
          
          // Password Field (shown only for password login)
          if (_usePasswordLogin) ...[
            const SizedBox(height: defaultPadding),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
                color: Colors.grey[50],
              ),
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                enabled: !_isLoading,
                onFieldSubmitted: (_) {
                  if (!_isLoading) {
                    _handlePasswordLogin();
                  }
                },
                validator: (value) {
                  if (_usePasswordLogin && (value == null || value.trim().isEmpty)) {
                    return 'Please enter your password';
                  }
                  if (_usePasswordLogin && value!.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: kPrimaryColor,
                  ),
                  suffixIcon: IconButton(
                    onPressed: !_isLoading ? () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    } : null,
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey[600],
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: defaultPadding * 1.5),
          
          // Login Button
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null 
                  : (_usePasswordLogin ? _handlePasswordLogin : _handleOTPLogin),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
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
                          _usePasswordLogin ? Icons.login_rounded : Icons.sms_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _usePasswordLogin ? "Login" : "Send OTP",
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
          
          const SizedBox(height: defaultPadding * 1.5),
          
          // Don't have account section
          AlreadyHaveAnAccountCheck(
            login: true,
            press: () {
              if (!_isLoading && mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpScreen(),
                  ),
                );
              }
            },
          ),
          
          const SizedBox(height: defaultPadding),
        ],
      ),
    );
  }
}