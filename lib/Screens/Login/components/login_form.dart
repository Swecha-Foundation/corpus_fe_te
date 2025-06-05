import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
import '../../Signup/signup_screen.dart';
import '../../OTP/otp_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // ignore: avoid_print
    print("Login button pressed!"); // Debug print
    
    if (_formKey.currentState!.validate()) {
      // Get the entered values
      String name = _nameController.text.trim();
      String phoneNumber = _phoneController.text.trim();
      
      // ignore: avoid_print
      print("Form validated successfully!"); // Debug print
      // ignore: avoid_print
      print("Name: $name, Phone: $phoneNumber"); // Debug print
      
      try {
        // Navigate to OTP screen with the collected data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              phoneNumber: phoneNumber,
              name: name,
            ),
          ),
        ).then((value) {
          // ignore: avoid_print
          print("Navigation completed"); // Debug print
        });
        // ignore: avoid_print
        print("Navigation initiated"); // Debug print
      } catch (e) {
        // ignore: avoid_print
        print("Navigation error: $e"); // Debug print
      }
    } else {
      // ignore: avoid_print
      print("Form validation failed!"); // Debug print
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: defaultPadding),
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              cursorColor: kPrimaryColor,
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
              decoration: const InputDecoration(
                hintText: "Enter your phone number",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(defaultPadding),
                  child: Icon(Icons.phone),
                ),
                counterText: '', // Hides the character counter
              ),
            ),
          ),
          const SizedBox(height: defaultPadding),
          ElevatedButton(
            onPressed: _handleLogin,
            child: Text(
              "Login".toUpperCase(),
            ),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const SignUpScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}