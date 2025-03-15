import 'package:flutter/material.dart';

import '../constants/styles.dart';

Widget buildGradientLoadingButton(BuildContext context, String text, bool isLoading, VoidCallback onPressed) {
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
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing30),
        ),
        padding: const EdgeInsets.symmetric(vertical: spacing16),
      ),
      child: isLoading
          ? const SizedBox(
              height: spacing20,
              width: spacing20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(ColorConst.backgroundWhiteColor),
              ),
            )
          : Text(
              text,
              style: AppFontStyles.poppinsTitleSemiBold(
                fontSize: fontSize18,
                color: ColorConst.textWhiteColor,
              ),
            ),
    ),
  );
}
