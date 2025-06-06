import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/styles.dart';

class ImageHelper {
  // Load local images
  static Widget loadFromAsset(
    String imageFilePath, {
    double? width,
    double? height,
    BorderRadius? radius,
    BoxFit fit = BoxFit.contain,
    Color? tintColor,
    Alignment alignment = Alignment.center,
    VoidCallback? onTap, // Added onTap parameter
  }) {
    bool isSvg = imageFilePath.toLowerCase().endsWith('.svg');
    
    Widget imageWidget = SizedBox(
      width: width != null ? width.clamp(0, maxSizeImageUploadChat) : maxSizeImageUploadChat,
      child: isSvg
          ? SvgPicture.asset(
              imageFilePath,
              width: width,
              height: height,
              fit: fit,
              colorFilter: tintColor != null
                  ? ColorFilter.mode(
                      tintColor, BlendMode.srcIn)
                  : null,
              alignment: alignment,
            )
          : Image.asset(
              imageFilePath,
              width: width,
              height: height,
              fit: fit,
              color: tintColor,
              alignment: alignment,
            ),
    );


    // Apply border radius if provided
    if (radius != null && radius != BorderRadius.zero) {
      imageWidget = ClipRRect(borderRadius: radius, child: imageWidget);
    }

    // Wrap with GestureDetector if onTap is provided
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  // Implement a method for loading images from URLs (CachedNetworkImage)
}
