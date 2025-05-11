import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:flutter/material.dart';

class GradientFormButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isActiveButton;
  final double padding;
  final bool isLoading;

  const GradientFormButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isActiveButton,
    this.padding = 0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: spacing40,
      padding: padding == 0 ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(spacing8),
        gradient: isActiveButton == true ? ColorConst.primaryGradientColor : null,
        border: Border.all(color: isActiveButton == false ? ColorConst.textHighlightColor : Colors.transparent, width: 1),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActiveButton == false ? ColorConst.backgroundWhiteColor : Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spacing8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(right: spacing8),
                child: SizedBox(
                  height: spacing14,
                  width: spacing14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            Text(
              text,
              style: AppFontStyles.poppinsTitleBold(
                color: isActiveButton ? ColorConst.textWhiteColor : ColorConst.textBlackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
