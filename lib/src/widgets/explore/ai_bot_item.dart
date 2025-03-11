import 'package:flutter/material.dart';
import '../../constants/styles.dart';
import '../../helpers/image_helpers.dart';
import '../../constants/mock_data.dart';
import '../../constants/enum.dart';
import '../../pages/chat/views/chat_thread.dart';

class AiBotItem extends StatelessWidget {
  final Map<String, String> botData;

  const AiBotItem({Key? key, required this.botData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Avatar path
    String avatarPath =
        AssetPath.aiModels[botData['value']] ?? AssetPath.icoDefaultImage;

    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: padding16, vertical: padding4),
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
          botData["display"]!,
          style: AppFontStyles.poppinsTextBold(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          botData["prompt"]!,
          style: AppFontStyles.poppinsRegular(
            color: ColorConst.textGrayColor,
            fontSize: fontSize12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          Navigator.of(context).pushNamed(
            ChatThreadScreen.routeName,
            arguments: {
              ...botData,
              'chatStatus': ChatThreadStatus.new_,
              'botValue': botData['value'],
            },
          );
        },
      ),
    );
  }
}
