import 'dart:io';

import 'package:flutter/material.dart';

import '../../../constants/styles.dart';

class UploadImageWidget {
  static Widget buildUploadImageWidget(
      {required BuildContext context,
      required File imageFile,
      Function? onTap,
      double height = 40,
      bool hasExit = true}) {
    return Stack(
      alignment: Alignment.topRight,
      clipBehavior: Clip.none,
      children: [
        Image.file(
          imageFile,
          height: height,
          alignment: Alignment.centerLeft,
        ),
        hasExit
            ? Positioned(
                top: -spacing6,
                right: -spacing6,
                child: GestureDetector(
                  onTap: () => onTap?.call() ?? () {},
                  child: Container(
                    margin: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: spacing20,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
