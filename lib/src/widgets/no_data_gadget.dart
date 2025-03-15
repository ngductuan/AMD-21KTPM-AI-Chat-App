import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:flutter/material.dart';

class NoDataGadget extends StatelessWidget {
  final double width;
  final double height;
  final double leftSpacing;

  const NoDataGadget({
    super.key,
    this.width = 120,
    this.height = 140,
    this.leftSpacing = spacing20,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: spacing20),
        child: ImageHelper.loadFromAsset(
          AssetPath.noDataIcon,
          width: width,
          height: height,
        ),
      ),
    );
  }
}
