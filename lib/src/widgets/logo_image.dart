import 'package:eco_chat_bot/src/constants/asset_path.dart';
import 'package:flutter/material.dart';

class LogoImage extends StatelessWidget {
  final double width;
  final double height;

  const LogoImage({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          AssetPath.logoApp,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
