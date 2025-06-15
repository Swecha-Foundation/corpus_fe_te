// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../../services/otp_api_service.dart';
import '../../../services/user_api_service.dart';
import '../../Login/login_screen.dart';
import '../../OTP/otp_screen.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _placeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedGender;
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isCheckingUser = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _placeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showSnackBar(String message, Color backgroundColor, {SnackBarAction? action}) {
    // Enhanced mounted check with context validation
    if (!mounted) return;
    
    try {
      // Use a post-frame callback to ensure the widget tree is stable
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: backgroundColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                action: action,
                duration: const Duration(seconds: 3),
              ),
            );
          } catch (e) {
            print('Error showing snackbar: $e');
            // Fallback - just print the message
            print('Message: $message');
          }
        }
      });
    } catch (e) {
      print('Error in _showSnackBar: $e');
      print('Message: $message');
    }
  }

  // Check if user exists when phone number field loses focus
  void _checkIfUserExists() async {
    if (!mounted) return;
    
    String phoneNumber = _phoneController.text.trim();
    
    if (phoneNumber.length == 10) {
      setState(() {
        _isCheckingUser = true;
      });
      
      try {
        final userExistsResult = await UserApiService.checkUserExists(phoneNumber);
        
        if (!mounted) return;
        
        if (userExistsResult['success']) {
          // User already exists
          _showSnackBar(
            'Account with this phone number already exists. Please login instead.',
            Colors.orange,
            action: SnackBarAction(
              label: 'Login',
              textColor: Colors.white,
              onPressed: () {
                if (mounted && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
            ),
          );
        }
      } catch (e) {
        print('Error checking user: $e');
        // Don't show error to user, just log it
      } finally {
        if (mounted) {
          setState(() {
            _isCheckingUser = false;
          });
        }
      }
    }
  }

  void _handleCreateAccount() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      if (_selectedDate == null) {
        _showSnackBar('Please select your date of birth', Colors.red);
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    String phoneNumber = _phoneController.text.trim();
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String place = _placeController.text.trim();
    String password = _passwordController.text.trim();
    
    try {
      print('Attempting to create account for phone: $phoneNumber');
      
      // Check if user already exists before creating
      final userExistsResult = await UserApiService.checkUserExists(phoneNumber);
      
      if (!mounted) return;
      
      if (userExistsResult['success']) {
        // User already exists - show message and navigate to login
        _showSnackBar(
          'Account with this phone number already exists. Please login instead.',
          Colors.orange,
          action: SnackBarAction(
            label: 'Login',
            textColor: Colors.white,
            onPressed: () {
              if (mounted && context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
          ),
        );
        return;
      }
      
      // User doesn't exist, proceed with creation
      print('Creating user...');
      final createUserResult = await UserApiService.createUser(
        phone: phoneNumber,
        name: name,
        email: email,
        gender: _selectedGender!,
        dateOfBirth: _selectedDate!,
        place: place,
        password: password,
      );
      
      if (!mounted) return;
      
      if (createUserResult['success']) {
        print('User created successfully, navigating to OTP screen');
        
        // Show success message without waiting for it to complete
        _showSnackBar('Account created successfully! Please verify your phone number.', Colors.green);
        
        // Navigate to OTP screen with user data - use a small delay to ensure UI updates
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted && context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                phoneNumber: phoneNumber,
                name: name,
                isNewUser: true,
                userData: createUserResult['data'],
              ),
            ),
          );
        }
      } else {
        print('User creation failed: ${createUserResult['message']}');
        
        // Handle specific error cases
        if (createUserResult['error'] == 'user_exists') {
          _showSnackBar(
            'Account with this phone number already exists. Please login instead.',
            Colors.orange,
            action: SnackBarAction(
              label: 'Login',
              textColor: Colors.white,
              onPressed: () {
                if (mounted && context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
            ),
          );
        } else {
          // Other creation errors
          String errorMessage = createUserResult['message'] ?? 'Failed to create account';
          
          // Handle common backend errors
          if (errorMessage.toLowerCase().contains('email') && errorMessage.toLowerCase().contains('already')) {
            errorMessage = 'Email address already in use. Please use a different email.';
          } else if (errorMessage.toLowerCase().contains('phone') && errorMessage.toLowerCase().contains('already')) {
            errorMessage = 'Phone number already in use. Please login instead.';
          } else if (errorMessage.toLowerCase().contains('validation')) {
            errorMessage = 'Please check your information and try again.';
          }
          
          _showSnackBar(errorMessage, Colors.red);
        }
      }
    } catch (e) {
      print('Sign up error: $e');
      if (mounted) {
        _showSnackBar('An error occurred. Please try again.', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    Widget? suffixIcon,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.grey[50],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(
                icon,
                color: kPrimaryColor,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              counterText: '', // Hide character counter
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.grey[50],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: kPrimaryColor,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: onToggleVisibility,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: defaultPadding * 1.5),
            
            // Full Name Field
            _buildInputField(
              controller: _nameController,
              label: "Full Name",
              hint: "Enter your full name",
              icon: Icons.person_outline_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: defaultPadding),
            
            // Phone Number Field
            _buildInputField(
              controller: _phoneController,
              label: "Phone Number",
              hint: "Enter your phone number",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
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
              onChanged: (value) {
                // Check for existing user when phone number is complete
                if (value.length == 10) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      _checkIfUserExists();
                    }
                  });
                }
              },
              suffixIcon: _isCheckingUser 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(height: defaultPadding),
            
            // Email Field
            _buildInputField(
              controller: _emailController,
              label: "Email Address",
              hint: "Enter your email address",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email address';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            
            const SizedBox(height: defaultPadding),
            
            // Place Field
            _buildInputField(
              controller: _placeController,
              label: "Place",
              hint: "Enter your place/city",
              icon: Icons.location_on_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your place';
                }
                if (value.trim().length < 2) {
                  return 'Place must be at least 2 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: defaultPadding),
            
            // Password Field
            _buildPasswordField(
              controller: _passwordController,
              label: "Password",
              hint: "Enter your password",
              obscureText: _obscurePassword,
              onToggleVisibility: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            
            const SizedBox(height: defaultPadding),
            
            // Confirm Password Field
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: "Confirm Password",
              hint: "Confirm your password",
              obscureText: _obscureConfirmPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            
            const SizedBox(height: defaultPadding),
            
            // Gender Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gender",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    color: Colors.grey[50],
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      hintText: "Select your gender",
                      prefixIcon: Icon(
                        Icons.people_outline_rounded,
                        color: kPrimaryColor,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    items: _genderOptions.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your gender';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: defaultPadding),
            
            // Date of Birth Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Date of Birth",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    color: Colors.grey[50],
                  ),
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Row( 
                        children:  [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: kPrimaryColor,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate != null
                                ? _formatDate(_selectedDate!)
                                : "Select your date of birth",
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedDate != null
                                  ? Colors.black87
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_selectedDate == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 12),
                    child: Text(
                      'Please select your date of birth',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: defaultPadding * 2),
            
            // Create Account Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleCreateAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: defaultPadding * 1.5),
            
            // Already have account check
            AlreadyHaveAnAccountCheck(
              press: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: defaultPadding),
          ],
        ),
      ),
    );
  }
}