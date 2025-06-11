// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../../services/otp_api_service.dart';
import '../../../services/user_api_service.dart';
import '../../Signup/signup_screen.dart';
import '../../OTP/otp_screen.dart';
import '../../Dashboard/dashboard_screen.dart'; // Add this import

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

  void _showSnackBar(String message, Color backgroundColor, {SnackBarAction? action}) {
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: action,
        ),
      );
    }
  }

  void _handleOTPLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String phoneNumber = _phoneController.text.trim();
    
    try {
      print('Attempting OTP login for phone: $phoneNumber');
      
      // Use the fixed checkUserExists method
      final userExistsResult = await UserApiService.checkUserExists(phoneNumber);
      
      print('User exists result: ${userExistsResult}'); // Debug log
      
      if (userExistsResult['success']) {
        // User exists, send OTP
        print('User found, sending OTP...');
        final otpResult = await OTPApiService.sendOTP(phoneNumber);
        
        print('OTP result: ${otpResult}'); // Debug log
        
        if (otpResult['success']) {
          print('OTP sent successfully');
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  phoneNumber: phoneNumber,
                  name: userExistsResult['data']['name'] ?? 'User',
                  isNewUser: false,
                  userData: userExistsResult['data'],
                ),
              ),
            );
          }
        } else {
          print('Failed to send OTP: ${otpResult['message']}');
          _showSnackBar(
            'Failed to send OTP: ${otpResult['message']}',
            Colors.red,
          );
        }
      } else {
        // User doesn't exist
        print('User not found: ${userExistsResult['message']}');
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
      }
    } catch (e) {
      print('OTP Login error: $e');
      _showSnackBar('Error: $e', Colors.red);
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

    setState(() {
      _isLoading = true;
    });

    String phoneNumber = _phoneController.text.trim();
    String password = _passwordController.text.trim();
    
    try {
      print('Attempting password login for phone: $phoneNumber');
      
      final loginResult = await UserApiService.loginUser(
        phone: phoneNumber,
        password: password,
      );
      
      if (loginResult['success']) {
        // Password login successful
        print('Password login successful');
        
        // Update last login
        String? userId = loginResult['data']['user']?['id']?.toString();
        String? authToken = loginResult['data']['token'] ?? loginResult['data']['access_token'];
        
        if (userId != null && authToken != null) {
          await UserApiService.updateLastLogin(userId, authToken: authToken);
        }
        
        // Show success message
        _showSnackBar('Login successful!', Colors.green);
        
        // Navigate to dashboard screen
        if (mounted) {
          // Get user data from login result
          final userData = loginResult['data']['user'];
          String userName = userData?['name'] ?? 'User';
          
          // Add a small delay to show the success message
          await Future.delayed(const Duration(milliseconds: 500));
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                userName: userName,
                phoneNumber: phoneNumber,
              ),
            ),
          );
        }
        
      } else {
        // Password login failed
        _showSnackBar(
          loginResult['message'] ?? 'Login failed',
          Colors.red,
        );
      }
    } catch (e) {
      print('Password Login error: $e');
      _showSnackBar('Error: $e', Colors.red);
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
                      setState(() {
                        _usePasswordLogin = false;
                      });
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
                      setState(() {
                        _usePasswordLogin = true;
                      });
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
                validator: (value) {
                  if (_usePasswordLogin && (value == null || value.trim().isEmpty)) {
                    return 'Please enter your password';
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
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
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
          
          const SizedBox(height: defaultPadding),
        ],
      ),
    );
  }
}