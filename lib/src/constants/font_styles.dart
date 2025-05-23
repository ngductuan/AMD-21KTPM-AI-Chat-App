import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFontStyles {
  static const double globalFontSize = 14;

  static TextStyle poppinsRegular({double? fontSize, Color color = ColorConst.textBlackColor}) {
    return GoogleFonts.poppins(
      fontSize: fontSize ?? globalFontSize,
      fontWeight: FontWeight.normal,
      color: color,
    );
  }

  static TextStyle poppinsTitleSemiBold({double? fontSize, Color color = ColorConst.textBlackColor}) {
    return GoogleFonts.poppins(
      fontSize: fontSize ?? globalFontSize,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle poppinsTitleBold(
      {double? fontSize, FontWeight fontWeight = FontWeight.bold, Color color = ColorConst.textBlackColor}) {
    return GoogleFonts.poppins(
      fontSize: fontSize ?? globalFontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle poppinsTextBold(
      {double? fontSize, FontWeight fontWeight = FontWeight.w500, Color color = ColorConst.textBlackColor}) {
    return GoogleFonts.poppins(
      fontSize: fontSize ?? globalFontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
