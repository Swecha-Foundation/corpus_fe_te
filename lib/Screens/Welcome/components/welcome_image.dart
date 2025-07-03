import 'package:flutter/material.dart';

import '../../../constants.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      // Vertically center the content within its available space.
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "A Product By Swecha",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // Slightly larger font
        ),
        const SizedBox(height: defaultPadding * 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using a SizedBox to give the image a consistent size.
            SizedBox(
              width: 300, // Increased size for better visibility
              child: Image.asset(
                "assets/icons/swecha_logo.png",
              ),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}
