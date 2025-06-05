import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../components/already_have_an_account_acheck.dart';
import '../../../constants.dart';
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

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleGetOTP() {
    // ignore: avoid_print
    print("Get OTP button pressed!"); // Debug print
    
    if (_formKey.currentState!.validate()) {
      // Get the phone number
      String phoneNumber = _phoneController.text.trim();
      
      // ignore: avoid_print
      print("Form validated successfully!"); // Debug print
      // ignore: avoid_print
      print("Phone: $phoneNumber"); // Debug print
      
      try {
        // Navigate to OTP screen with phone number
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              phoneNumber: phoneNumber,
              name: "New User", // Default name for signup flow
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
          const SizedBox(height: defaultPadding / 2),
          ElevatedButton(
            onPressed: _handleGetOTP,
            child: Text("Get OTP".toUpperCase()),
          ),
          const SizedBox(height: defaultPadding),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen();
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