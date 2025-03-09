import 'package:flutter/material.dart';

class ColorConst {
  static const primaryColorArray = [
    Color(0xEB0099FF),
    Color(0xEBA334FA),
    Color(0xEBFF5280),
    Color(0xEBFF7061),
  ];

  static const LinearGradient primaryGradientColor = LinearGradient(
    colors: primaryColorArray,
    stops: [0.0, 0.36, 0.71, 0.97],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundPastelColor = LinearGradient(
    colors: [
      Color(0xFFE7E7FF),
      Color(0xFFF8F8FF),
    ],
    stops: [0.0, 0.68],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const backgroundGrayColor = Color(0xC4F3F3F3);
  static const backgroundWhiteColor = Color(0xFFFFFFFF);
  static const backgroundBlackColor = Color(0xFF000000);
  static const backgroundRedColor = Color(0xFFFF3B30);
  static const backgroundLightGrayColor = Color(0xFFE5E5E5); // & indicator color
  static const backgroundLightGrayColor2 = Color(0xFFEFEFF4);

  static const textHighlightColor = Color(0xFF675DFF);
  static const textGrayColor = Color(0xFF8E8E93);
  static const textLightGrayColor = Color(0x66000000); // for icon in navbar
  static const textBlackColor = Color(0xFF000000);
  static const textWhiteColor = Color(0xFFFFFFFF);
  static const textRedColor = Color(0xFFFF3B30);

  static const grayOverlayColor = Color(0xFFAEAEB2);
}
