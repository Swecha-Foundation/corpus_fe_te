import 'package:flutter/material.dart';

import '../../components/background.dart';
import '../../responsive.dart';
import 'components/login_signup_btn.dart';
import 'components/welcome_image.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Background(
      // We wrap the content in a SingleChildScrollView to prevent
      // overflow errors on smaller screens when the keyboard appears or
      // content is larger than the screen.
      child: SingleChildScrollView(
        child: SafeArea(
          child: Responsive(
            desktop: _DesktopWelcomeScreen(),
            mobile: _MobileWelcomeScreen(),
            // You can add a tablet-specific layout here if needed
            // tablet: _TabletWelcomeScreen(),
          ),
        ),
      ),
    );
  }
}

/// Private widget for the desktop layout.
class _DesktopWelcomeScreen extends StatelessWidget {
  const _DesktopWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        // The welcome image takes up the first flexible space.
        Expanded(
          child: WelcomeImage(),
        ),
        // The login buttons are constrained to a max width and centered.
        Expanded(
          child: Center( // Center the content within the Expanded widget
            child: SizedBox(
              width: 450, // Constrain the width for the buttons
              child: LoginAndSignupBtn(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Private widget for the mobile layout.
class _MobileWelcomeScreen extends StatelessWidget {
  const _MobileWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Add some vertical padding for better spacing on mobile.
        SizedBox(height: 32.0),
        WelcomeImage(),
        SizedBox(height: 32.0),
        Row(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: LoginAndSignupBtn(),
            ),
            Spacer(),
          ],
        ),
        SizedBox(height: 32.0),
      ],
    );
  }
}
