import 'package:eco_chat_bot/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildGradientButton(
    BuildContext context, String text, VoidCallback onPressed) {
  return Container(
    width: double.infinity,
    height: 56, // Increased height
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      gradient: ColorConst.primaryGradientColor,
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withAlpha(77), // 0.3 * 255 = 77
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
}
