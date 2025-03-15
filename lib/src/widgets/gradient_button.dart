import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:flutter/material.dart';

Widget buildGradientButton(BuildContext context, String text, VoidCallback onPressed) {
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
        style: AppFontStyles.poppinsTitleSemiBold(
          fontSize: fontSize18,
          color: ColorConst.textWhiteColor,
        ),
      ),
    ),
  );
}
