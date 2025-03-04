import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:flutter/material.dart';

class GradientTextWidget extends StatelessWidget {
  final String text;
  final double fontSize;
  GradientTextWidget({required this.text, required this.fontSize});

  final gradient = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: ColorConst.primaryColorArray,
    stops: [0.0, 0.36, 0.71, 0.97],
  );

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
        shaderCallback: (bounds) {
          return gradient.createShader(
            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
          );
        },
        child: Text(text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: ColorConst.primaryGradientColor.colors.last,
              shadows: [
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: 5,
                  offset: Offset(1, 1),
                ),
              ],
            )));
  }
}
