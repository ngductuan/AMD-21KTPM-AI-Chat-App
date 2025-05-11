import 'package:eco_chat_bot/src/constants/enum.dart';
import 'package:eco_chat_bot/src/pages/chat/widgets/upload_image_widget.dart';
import 'package:flutter/widgets.dart';

import '../../../constants/styles.dart';

class ChatLineItem {
  static Widget build(BuildContext context, bool isModel, Map<String, dynamic> message, String activeAiModelId,
      Function buildModelLabel,
      {required ChatThreadStatus chatStatus}) {
    return Column(
      children: [
        isModel
            ? Padding(
                padding: EdgeInsets.only(left: spacing8),
                child: buildModelLabel(activeAiModelId, iconSize: spacing20, isDefaultMessage: true),
              )
            : SizedBox.shrink(),
        Align(
          alignment: isModel ? Alignment.centerLeft : Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isModel == false && message['imagePath'] != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: spacing8),
                      child: UploadImageWidget.buildUploadImageWidget(
                        context: context,
                        imageFile: message['imagePath'],
                        height: 120,
                        hasExit: false,
                      ),
                    )
                  : SizedBox.shrink(),
              Container(
                padding: EdgeInsets.all(spacing8),
                margin: EdgeInsets.symmetric(vertical: spacing6, horizontal: spacing8),
                decoration: BoxDecoration(
                  color: isModel ? ColorConst.textWhiteColor : ColorConst.textHighlightColor,
                  borderRadius: BorderRadius.circular(radius12),
                ),
                child: Text(
                  isModel ? message['answer'] : message['query'],
                  style: TextStyle(color: isModel ? ColorConst.textBlackColor : ColorConst.textWhiteColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
