import 'package:flutter/material.dart';
import '../../../constants/styles.dart';
import '../../../helpers/image_helpers.dart';

class AiBotItem extends StatelessWidget {
  final dynamic botData;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? avatarValue;

  const AiBotItem(
      {super.key, required this.botData, this.onTap, this.onLongPress, this.avatarValue});

  @override
  Widget build(BuildContext context) {
    // Avatar path
    String avatarPath = AssetPath.aiModels[avatarValue] ?? AssetPath.icoDefaultImage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: padding16, vertical: padding4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius12),
        color: ColorConst.backgroundWhiteColor,
        boxShadow: [
          BoxShadow(
            color: ColorConst.textHighlightColor.withAlpha(40),
            blurRadius: 2,
            offset: const Offset(0.5, 0.5),
          ),
        ],
      ),
      child: ListTile(
        leading: ImageHelper.loadFromAsset(
          avatarPath,
          width: spacing48,
          height: spacing48,
          radius: BorderRadius.circular(radius32),
        ),
        title: Text(
          botData["assistantName"]?.toString() ?? "",
          style: AppFontStyles.poppinsTextBold(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          botData["description"]?.toString() ?? "",
          style: AppFontStyles.poppinsRegular(
            color: ColorConst.textGrayColor,
            fontSize: fontSize12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
        // onLongPress: onLongPress,
      ),
    );
  }
}
