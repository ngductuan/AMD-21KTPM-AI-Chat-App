import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:flutter/material.dart';

class InputFormField {
  static Widget build(String label, String hint, {int maxLines = 1, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppFontStyles.poppinsTextBold(),
            children: [
              TextSpan(
                text: required == true ? ' *' : '',
                style: AppFontStyles.poppinsTextBold(color: ColorConst.textRedColor),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing12),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius8)),
            contentPadding: EdgeInsets.symmetric(horizontal: spacing12, vertical: spacing8),
          ),
        ),
      ],
    );
  }
}