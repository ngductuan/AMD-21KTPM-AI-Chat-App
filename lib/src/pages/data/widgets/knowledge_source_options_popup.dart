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
    required void Function(String knowledgeId, List<String> paths)
        onLocalFileSelected,
  }) {
    final overlay = Overlay.of(context)!;
    OverlayEntry? entry;

    entry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: padding16),
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
                        Text('Add Knowledge Source',
                            style: AppFontStyles.poppinsTitleSemiBold(
                                fontSize: fontSize16)),
                        IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => entry?.remove()),
                      ],
                    ),
                  ),
                  const SizedBox(height: spacing8),

                  // Options list
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: MockData.knowledgeSource.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1, color: ColorConst.backgroundLightGrayColor),
                    itemBuilder: (ctx, idx) {
                      final item = MockData.knowledgeSource[idx];
                      final iconPath =
                          AssetPath.knowledgeSource[item['value']!]!;
                      return ListTile(
                        leading: ImageHelper.loadFromAsset(iconPath,
                            width: spacing32, height: spacing32),
                        title: Text(item['display']!,
                            style: AppFontStyles.poppinsTextBold()),
                        subtitle: Text(item['hint']!,
                            style: AppFontStyles.poppinsRegular(
                                color: ColorConst.textGrayColor,
                                fontSize: fontSize12)),
                        trailing: const Icon(Icons.arrow_forward,
                            color: ColorConst.textGrayColor),
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
                              ImportWebSourcePopup.build(context,
                                  knowledgeId: knowledgeId);
                              break;
                            case 'google_drive':
                              GoogleDriveSourcePopup.build(context,
                                  knowledgeId: knowledgeId);
                              break;
                            case 'slack':
                              SlackSourcePopup.build(context,
                                  knowledgeId: knowledgeId);
                              break;
                            case 'confluence':
                              ConfluenceSourcePopup.build(context,
                                  knowledgeId: knowledgeId);
                              break;
                          }
                        },
                      );
                    },
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
