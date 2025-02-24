import 'dart:ui';

import 'package:flutter/material.dart';

class BlurBackground extends StatelessWidget {
  const BlurBackground({super.key, this.assetImage});

  final double _scale = 1;
  final String? assetImage;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (assetImage != null)
          Image.asset(
            assetImage!,
            fit: BoxFit.cover, // Ensures it covers the screen
            width: MediaQuery.of(context).size.width * _scale,
            height: MediaQuery.of(context).size.height * _scale,
            alignment: Alignment.center,
          ),
        // BackdropFilter(
        //   filter: ImageFilter.blur(
        //     sigmaX: 20 * _scale,
        //     sigmaY: 20 * _scale,
        //   ), // ✅ Blur intensity
        //   child: Container(
        //     color: Colors.black.withValues(
        //       alpha: 0.2,
        //     ), // Optional overlay for contrast
        //   ),
        // ),
      ],
    );
  }
}
