import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _dotCount = IntTween(begin: 0, end: 3).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _dotCount,
          builder: (context, child) {
            String dots = "." * (_dotCount.value + 1); // Cycle through 1-3 dots
            return Container(
              padding: EdgeInsets.symmetric(horizontal: spacing8),
              margin: EdgeInsets.symmetric(vertical: spacing6, horizontal: spacing8),
              decoration: BoxDecoration(
                color: ColorConst.backgroundWhiteColor,
                borderRadius: BorderRadius.circular(radius12),
              ),
              child: SizedBox(
                width: spacing24,
                child: Text(
                  dots,
                  style: AppFontStyles.poppinsTitleBold(fontSize: fontSize20),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
