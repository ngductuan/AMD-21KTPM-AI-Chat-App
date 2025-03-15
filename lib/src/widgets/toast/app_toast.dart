import 'package:another_flushbar/flushbar.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:flutter/material.dart';

import '../../constants/styles.dart';

enum AppToastMode { warning, confirm, error, info }

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
    double horizontalMargin = spacing16,
    double bottomOffset = spacing8,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(radius12)),
    Color? backgroundColor,
    AppToastMode? mode = AppToastMode.confirm,
  }) : super(
            messageText: Text(
              message,
              style: AppFontStyles.poppinsRegular(
                fontSize: fontSize14,
                color: Colors.white,
              ),
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
            icon: mode == null
                ? null
                : mode == AppToastMode.confirm
                    ? ImageHelper.loadFromAsset(
                        AssetPath.icoWhiteTick,
                        tintColor: const Color(0xFF039855),
                        height: iconAppToast22,
                        width: iconAppToast22,
                      )
                    : mode == AppToastMode.error
                        ? ImageHelper.loadFromAsset(
                            AssetPath.icoErrorToast,
                            height: iconAppToast22,
                            width: iconAppToast22,
                          )
                        : mode == AppToastMode.warning
                            ? ImageHelper.loadFromAsset(
                                AssetPath.icoWhiteExclamation,
                                height: iconAppToast22,
                                width: iconAppToast22,
                              )
                            : ImageHelper.loadFromAsset(AssetPath.icoWhiteExclamation,
                                height: iconAppToast22, width: iconAppToast22, tintColor: Colors.blue));
}
