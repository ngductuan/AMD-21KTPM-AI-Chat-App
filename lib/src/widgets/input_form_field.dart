import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:flutter/material.dart';

class InputFormField {
  static Widget build(String label, String hint,
      {TextEditingController? controller, int maxLines = 1, bool required = false, bool isSubmit = false}) {
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
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: AppFontStyles.poppinsRegular(color: ColorConst.textBlackColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppFontStyles.poppinsRegular(color: ColorConst.textGrayColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius8)),
            contentPadding: EdgeInsets.symmetric(horizontal: spacing12, vertical: spacing8),
          ),
          // forceErrorText: isSubmit ?? (required && controller.text.isEmpty ? ToastText.requiredField : ''),
          forceErrorText: isSubmit && required && (controller?.text.isEmpty ?? true) 
                  ? 'This field is required' 
                  : null,
        ),
      ],
    );
  }
}
