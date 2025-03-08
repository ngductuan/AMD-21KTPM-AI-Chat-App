import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:flutter/material.dart';

class GradientFormButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isActiveButton;

  const GradientFormButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isActiveButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: spacing40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(spacing8),
        gradient: isActiveButton == true ? ColorConst.primaryGradientColor : null,
        border:
            Border.all(color: isActiveButton == false ? ColorConst.textHighlightColor : Colors.transparent, width: 1),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActiveButton == false ? ColorConst.backgroundWhiteColor : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spacing8),
          ),
        ),
        child: Text(
          text,
          style: AppFontStyles.poppinsTitleBold(
            color: isActiveButton ? ColorConst.textWhiteColor : ColorConst.textBlackColor,
          ),
        ),
      ),
    );
  }
}
