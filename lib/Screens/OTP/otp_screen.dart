import 'package:flutter/material.dart';
import 'package:flutter_auth/responsive.dart';
import '../../components/background.dart';
import 'components/otp_form.dart';
import 'components/otp_screen_top_image.dart';

class OTPScreen extends StatelessWidget {
  final String phoneNumber;
  final String name;
  
  const OTPScreen({
    Key? key,
    required this.phoneNumber,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Responsive(
          mobile: MobileOTPScreen(phoneNumber: phoneNumber, name: name),
          desktop: Row(
            children: [
              const Expanded(
                child: OTPScreenTopImage(),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 450,
                      child: OTPForm(phoneNumber: phoneNumber, name: name),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileOTPScreen extends StatelessWidget {
  final String phoneNumber;
  final String name;
  
  const MobileOTPScreen({
    Key? key,
    required this.phoneNumber,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const OTPScreenTopImage(),
        Row(
          children: [
            const Spacer(),
            Expanded(
              flex: 8,
              child: OTPForm(phoneNumber: phoneNumber, name: name),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}