import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';
import 'package:flutter/material.dart';

import '../constants/styles.dart';

Future<bool?> buildShowConfirmDialog(BuildContext context, String title, String activeButtonText) {
  return showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: ColorConst.backgroundWhiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(spacing20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: GradientFormButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                    isActiveButton: false,
                  ),
                ),
                const SizedBox(width: spacing12),
                Expanded(
                  child: GradientFormButton(
                    text: activeButtonText,
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    isActiveButton: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
