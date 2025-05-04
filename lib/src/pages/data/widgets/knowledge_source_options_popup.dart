import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/constants/mock_data.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';

import 'local_knowledge_source_popup.dart';
import 'import_web_source_popup.dart';
import 'google_drive_source_popup.dart';
import 'slack_source_popup.dart';
import 'confluence_source_popup.dart';

/// A popup that lets the user select a source to add knowledge from.
class KnowledgeSourceOptionsPopup {
  static void build(
    BuildContext context, {
    required String knowledgeId,
    required void Function(String knowledgeId, List<String> paths) onLocalFileSelected,
  }) {
    final overlay = Overlay.of(context);
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            // margin: const EdgeInsets.symmetric(horizontal: padding16),
            decoration: BoxDecoration(
              color: ColorConst.backgroundWhiteColor,
              borderRadius: BorderRadius.circular(radius12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: padding16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: padding16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add Knowledge Source', style: AppFontStyles.poppinsTitleSemiBold(fontSize: fontSize16)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => entry?.remove()),
                      ],
                    ),
                  ),
                  const SizedBox(height: spacing16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: padding16),
                    child: SizedBox(
                      height: 450,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: spacing8),
                        itemCount: MockData.knowledgeSource.length,
                        itemBuilder: (context, index) {
                          final item = MockData.knowledgeSource[index];
                          final avatarPath = AssetPath.knowledgeSource[item['value']]!;
                          return GestureDetector(
                            onTap: () {
                              entry?.remove();
                              switch (item['value']) {
                                case 'local_file':
                                  LocalKnowledgeSourcePopup.build(
                                    context,
                                    knowledgeId: knowledgeId,
                                    onFilesSelected: onLocalFileSelected,
                                  );
                                  break;
                                case 'website':
                                  ImportWebSourcePopup.build(context, knowledgeId: knowledgeId);
                                  break;
                                case 'google_drive':
                                  GoogleDriveSourcePopup.build(context, knowledgeId: knowledgeId);
                                  break;
                                case 'slack':
                                  SlackSourcePopup.build(context, knowledgeId: knowledgeId);
                                  break;
                                case 'confluence':
                                  ConfluenceSourcePopup.build(context, knowledgeId: knowledgeId);
                                  break;
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
                                          item['display']!,
                                          style: AppFontStyles.poppinsTextBold(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: spacing4),
                                        Text(
                                          item['hint']!,
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

    overlay.insert(entry);
  }
}
