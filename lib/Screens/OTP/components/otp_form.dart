import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants.dart';

class OTPForm extends StatefulWidget {
  final String phoneNumber;
  final String name;
  
  const OTPForm({
    Key? key,
    required this.phoneNumber,
    required this.name,
  }) : super(key: key);

  @override
  State<OTPForm> createState() => _OTPFormState();
}

class _OTPFormState extends State<OTPForm> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
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
  
  void _onBackspacePressed(int index) {
    if (index > 0 && _controllers[index].text.isEmpty) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }
  
  String _getOTPCode() {
    return _controllers.map((controller) => controller.text).join();
  }
  
  bool _isOTPComplete() {
    return _getOTPCode().length == 6;
  }
  
  void _verifyOTP() {
    if (_isOTPComplete()) {
      String otpCode = _getOTPCode();
      // Here you would typically validate the OTP with your backend
      print('Verifying OTP: $otpCode for ${widget.name} (${widget.phoneNumber})');
      
      // Show success message or navigate to next screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:  Text('OTP Verified Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete OTP'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _resendOTP() {
    // Clear all fields
    for (var controller in _controllers) {
      controller.clear();
    }
    // Focus on first field
    FocusScope.of(context).requestFocus(_focusNodes[0]);
    
    // Here you would typically trigger OTP resend API call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent to ${widget.phoneNumber}'),
        backgroundColor: kPrimaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
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
                    // Clear the field when tapped for better UX
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
          ElevatedButton(
            onPressed: _isOTPComplete() ? _verifyOTP : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isOTPComplete() ? kPrimaryColor : Colors.grey,
            ),
            child: const Text(
              "VERIFY OTP",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(height: defaultPadding),
          
          // Resend OTP
          TextButton(
            onPressed: _resendOTP,
            child: const Text(
              "Didn't receive OTP? Resend",
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: defaultPadding),
          
          // Back to Login
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "← Back to Login",
              style: TextStyle(
                color: kPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}