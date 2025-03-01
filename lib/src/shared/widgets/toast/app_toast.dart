import 'package:another_flushbar/flushbar.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/constants/theme.dart';
import 'package:eco_chat_bot/src/helpers/asset_helper.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:flutter/material.dart';

enum AppToastMode { warning, confirm, error }

// ignore: must_be_immutable
class AppToast extends Flushbar {
  AppToast({
    Key? key,
    String? title,
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 2),
    Duration animationDuration = const Duration(milliseconds: 700),
    EdgeInsets padding = const EdgeInsets.all(padding16),
    double horizontalMargin = 16.0,
    double bottomOffset = 8,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
    Color? backgroundColor,
    AppToastMode? mode = AppToastMode.confirm,
  }) : super(
          messageText: Text(
            message,
            style: AppTextStyle(context).getDefaultStyle().setColor(
                colorsByTheme(context).refectDefaultFont ?? Colors.red),
          ),
          key: key,
          title: title,
          duration: duration,
          animationDuration: animationDuration,
          padding: padding,
          margin: EdgeInsets.fromLTRB(
            horizontalMargin,
            0,
            horizontalMargin,
            bottomOffset,
          ),
          borderRadius: borderRadius,
          backgroundColor: colorsByTheme(context).defaultFont ?? Colors.red,
          icon: mode == null
              ? null
              : mode == AppToastMode.confirm
                  ? ImageHelper.loadFromAsset(
                      AssetHelper.icoWhiteTick,
                      tintColor: const Color(0xFF039855),
                      height: iconAppToast22,
                      width: iconAppToast22,
                    )
                  : mode == AppToastMode.error
                      ? ImageHelper.loadFromAsset(
                          AssetHelper.icoErrorToast,
                          height: iconAppToast22,
                          width: iconAppToast22,
                        )
                      : ImageHelper.loadFromAsset(
                          AssetHelper.icoWhiteExclamation,
                          tintColor: Colors.yellow[700],
                          height: iconAppToast22,
                          width: iconAppToast22,
                        ),
        );
}
