import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../constants/styles.dart';

class SelectSourceItem {
  static Widget build(String avatarPath, Map<String, String> data, {IconData trailingIconData = Icons.arrow_forward, double avatarSize = spacing16}) {
    return Container(
      padding: EdgeInsets.all(spacing12),
      margin: EdgeInsets.only(bottom: spacing8),
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorConst.backgroundLightGrayColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(radius12),
      ),
      child: Row(
        children: [
          Container(
            width: spacing32,
            height: spacing32,
            decoration: BoxDecoration(
              color: ColorConst.bluePastelColor,
              borderRadius: BorderRadius.circular(radius24),
            ),
            child: Center(
              child: ImageHelper.loadFromAsset(
                avatarPath,
                width: avatarSize,
                height: avatarSize,
              ),
            ),
          ),
          SizedBox(width: spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['display']!,
                  style: AppFontStyles.poppinsTextBold(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing4),
                Text(
                  data['hint']!,
                  style: AppFontStyles.poppinsRegular(
                    color: ColorConst.textGrayColor,
                    fontSize: fontSize12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            trailingIconData,
            color: ColorConst.textGrayColor,
          ),
        ],
      ),
    );
  }
}
