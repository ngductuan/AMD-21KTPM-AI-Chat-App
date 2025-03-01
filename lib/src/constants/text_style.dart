import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:flutter/material.dart';

extension ExtendedTextStyle on TextStyle {
  TextStyle get light {
    return copyWith(fontWeight: FontWeight.w300);
  }

  TextStyle get regular {
    return copyWith(fontWeight: FontWeight.w400);
  }

  TextStyle get italic {
    return copyWith(
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
    );
  }

  TextStyle get medium {
    return copyWith(fontWeight: FontWeight.w500);
  }

  TextStyle get semibold {
    return copyWith(fontWeight: FontWeight.w600);
  }

  TextStyle get bold {
    return copyWith(fontWeight: FontWeight.w700);
  }

  TextStyle get fontLeading2 {
    return copyWith(
      fontSize: (22.0 + differenceFont),
      height: (22.0 + differenceFont) / (20.0 + differenceFont),
    );
  }

  TextStyle get fontLeading1 {
    return copyWith(
      fontSize: (20.0 + differenceFont),
      height: (20.0 + differenceFont) / (18.0 + differenceFont),
    );
  }

  TextStyle get fontSize16 {
    return copyWith(
      fontSize: (16.0 + differenceFont),
      height: (16.0 + differenceFont) / (14.0 + differenceFont),
    );
  }

  TextStyle get fontHeader {
    return copyWith(
      fontSize: (14.0 + differenceFont),
      height: (14.0 + differenceFont) / (12.0 + differenceFont),
    );
  }

  // TextStyle get fontHeaderNoHeight {
  //   return copyWith(
  //     fontSize: (14.0 + differenceFont),
  //   );
  // }

  TextStyle get fontCaption {
    return copyWith(
      fontSize: (12.0 + differenceFont),
      height: (12.0 + differenceFont) / (10.0 + differenceFont),
    );
  }

  TextStyle get fontSize8 {
    return copyWith(
      fontSize: (8.0 + differenceFont),
      height: (8.0 + differenceFont) / (6.0 + differenceFont),
    );
  }

  // TextStyle get whiteTextColor {
  //   return copyWith(color: AppColor.white);
  // }

  // TextStyle get subTitleTextColor {
  //   return copyWith(color: AppColor.defaultFontLight.shade500);
  // }

  // convenience functions
  TextStyle setColor(Color color) {
    return copyWith(color: color);
  }

  TextStyle setTextSize(double size) {
    return copyWith(fontSize: size);
  }

  TextStyle setHeight(double height) {
    return copyWith(height: height);
  }

  TextStyle setFontFamily(String fontFamily) {
    return copyWith(fontFamily: fontFamily);
  }
}

class AppTextStyle {
  AppTextStyle(this.context);

  final BuildContext context;

  TextStyle getDefaultStyle() {
    return TextStyle(
      fontSize: 10.0 + differenceFont,
      color: colorsByTheme(context).defaultFont ?? AppColor.defaultFontLight,
      fontFamily: dongLeFont,
      fontWeight: FontWeight.w400,
      height: (10.0 + differenceFont) / (8.0 + differenceFont),
    );
  }

  TextStyle getShadowStyle() {
    return const TextStyle(
      fontSize: 10.0 + differenceFont,
      // color: colorsByTheme(context).hintTextColor ?? AppColor.shadow,
      color: AppColor.shadow,
      fontFamily: dongLeFont,
      fontWeight: FontWeight.w400,
      height: (10.0 + differenceFont) / (8.0 + differenceFont),
    );
  }
}
