import 'package:eco_chat_bot/src/constants/mock_data.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:eco_chat_bot/src/widgets/toast/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/pages/knowledge_source/widgets/local_knowledge_source_popup.dart';
import 'package:eco_chat_bot/src/pages/knowledge_source/widgets/import_web_source_popup.dart';

class SelectKnowledgeSourcePopup {
  /// Shows an overlay allowing the user to pick between local files or web import.
  static void build(
    BuildContext context, {
    required void Function(List<String>) onLocalFilesSelected,
    required void Function(String name, String url) onWebSourceSelected,
  }) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;

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
                            icon: const Icon(Icons.close, size: spacing20),
                            onPressed: () => overlayEntry?.remove(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: spacing16),

                  // Options List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: padding16),
                    child: SizedBox(
                      height: 500,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: spacing8),
                        itemCount: MockData.knowledgeSource.length,
                        itemBuilder: (context, index) {
                          final data = MockData.knowledgeSource[index];
                          final avatarPath = AssetPath.knowledgeSource[data['value']]!;
                          return GestureDetector(
                            onTap: () {
                              overlayEntry?.remove();
                              if (data['value'] == 'local_file') {
                                LocalKnowledgeSourcePopup.build(
                                  context,
                                  onFilesSelected: onLocalFilesSelected,
                                );
                              } else if (data['value'] == 'website') {
                                ImportWebSourcePopup.build(
                                  context,
                                  onWebSourceSelected: onWebSourceSelected,
                                );
                              } else {
                                AppToast(
                                  context: context,
                                  message: 'Coming soon!',
                                  mode: AppToastMode.info,
                                ).show(context);
                              }
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
                                        width: spacing16,
                                        height: spacing16,
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
                                    Icons.arrow_forward,
                                    color: ColorConst.textGrayColor,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }
}
