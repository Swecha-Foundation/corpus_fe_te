import 'package:flutter/material.dart';
import 'package:org.swecha.telugu_corpus_collection/responsive.dart';
import '../../components/background.dart';
import 'components/otp_form.dart';
import 'components/otp_screen_top_image.dart';

class OTPScreen extends StatelessWidget {
  final String phoneNumber;
  final String name;
  final bool isNewUser;
  final Map<String, dynamic>? userData;
  
  const OTPScreen({
    Key? key,
    required this.phoneNumber,
    required this.name,
    this.isNewUser = false,
    this.userData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Responsive(
          mobile: MobileOTPScreen(
            phoneNumber: phoneNumber, 
            name: name,
            isNewUser: isNewUser,
            userData: userData,
          ),
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
                      child: OTPForm(
                        phoneNumber: phoneNumber, 
                        name: name,
                        isNewUser: isNewUser,
                        userData: userData,
                      ),
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
  final bool isNewUser;
  final Map<String, dynamic>? userData;
  
  const MobileOTPScreen({
    Key? key,
    required this.phoneNumber,
    required this.name,
    this.isNewUser = false,
    this.userData,
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
              child: OTPForm(
                phoneNumber: phoneNumber, 
                name: name,
                isNewUser: isNewUser,
                userData: userData,
              ),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}