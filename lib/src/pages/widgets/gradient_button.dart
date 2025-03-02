import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildGradientButton(
    BuildContext context, String text, VoidCallback onPressed) {
  return Container(
    width: double.infinity,
    height: 60, // Increased height
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: const LinearGradient(
        colors: [
          Color(0xFF4285F4), // Google blue
          Color(0xFFEA4335), // Google red
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
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
          borderRadius: BorderRadius.circular(30),
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
