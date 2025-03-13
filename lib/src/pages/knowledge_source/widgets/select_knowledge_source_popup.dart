import 'package:eco_chat_bot/src/constants/mock_data.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:flutter/material.dart';

class SelectKnowledgeSourcePopup {
  static void build(BuildContext context) {
    final overlay = Overlay.of(context);

    OverlayEntry? overlayEntry;

    // Declare overlayEntry before use
    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: ColorConst.backgroundWhiteColor,
              borderRadius: BorderRadius.circular(radius12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: padding16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title and Close Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: padding16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Knowledge Source',
                          style: AppFontStyles.poppinsTitleSemiBold(fontSize: fontSize16),
                        ),
                        SizedBox(
                          width: spacing32,
                          height: spacing32,
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              size: spacing20,
                            ),
                            onPressed: () => {
                              overlayEntry?.remove(),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: spacing16),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: padding16, right: padding8),
                        child: SizedBox(
                          height: 500,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: spacing8),
                            itemCount: MockData.knowledgeSource.length,
                            itemBuilder: (context, index) {
                              Map<String, String> dataItem = MockData.knowledgeSource[index];

                              // Avatar path
                              String avatarPath = AssetPath.knowledgeSource[dataItem['value']]!;

                              return GestureDetector(
                                onTap: () {
                                  print('Selected: ${dataItem["display"]}');
                                },
                                child: Container(
                                  padding: EdgeInsets.all(spacing12),
                                  margin: EdgeInsets.only(bottom: spacing8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: ColorConst.backgroundLightGrayColor,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(radius12),
                                  ),
                                  child: Row(children: [
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
                                          width: spacing16,
                                          height: spacing16,
                                          // radius: BorderRadius.circular(radius32),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: spacing12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dataItem["display"]!,
                                            style: AppFontStyles.poppinsTextBold(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: spacing4),
                                          Text(
                                            dataItem["hint"]!,
                                            style: AppFontStyles.poppinsRegular(
                                                color: ColorConst.textGrayColor, fontSize: fontSize12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: ColorConst.textGrayColor,
                                    )
                                  ]),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Now insert the overlay entry
    overlay.insert(overlayEntry);
  }
}
