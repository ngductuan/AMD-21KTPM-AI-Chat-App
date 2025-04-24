import 'package:dotted_border/dotted_border.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';
import 'package:eco_chat_bot/src/pages/knowledge_source/widgets/select_knowledge_source_popup.dart';

class LocalKnowledgeSourcePopup {
  /// Opens an overlay to pick one or more local files.
  ///
  /// [onFilesSelected] is called with the full list of selected file paths.
  static void build(
    BuildContext context, {
    required void Function(List<String>) onFilesSelected,
  }) {
    final overlay = Overlay.of(context);
    OverlayEntry? entry;
    // Holds the currently picked file paths
    List<String> pickedFiles = [];

    entry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: ColorConst.backgroundWhiteColor,
                  borderRadius: BorderRadius.circular(radius12),
                ),
                padding: const EdgeInsets.all(padding16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Import Local Files',
                          style: AppFontStyles.poppinsTitleSemiBold(
                            fontSize: fontSize16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: spacing20),
                          onPressed: () {
                            entry?.remove();
                            // go back to select popup
                            SelectKnowledgeSourcePopup.build(
                              context,
                              onLocalFilesSelected: onFilesSelected,
                              onWebSourceSelected: (String name, String url) {},
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: spacing24),

                    // File selection area
                    GestureDetector(
                      onTap: () async {
                        final result = await FilePicker.platform.pickFiles(
                          allowMultiple: true,
                        );
                        if (result == null) return;
                        setState(() {
                          pickedFiles = result.paths
                              .where((path) => path != null)
                              .cast<String>()
                              .toList();
                        });
                      },
                      child: DottedBorder(
                        strokeWidth: 1,
                        dashPattern: const [4, 2],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(radius12),
                        color: ColorConst.textGrayColor,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(spacing16),
                          color: ColorConst.backgroundGrayColor
                              .withAlpha((0.5 * 255).toInt()),
                          child: pickedFiles.isEmpty
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ImageHelper.loadFromAsset(
                                      AssetPath.icUpload,
                                      width: spacing28,
                                      height: spacing28,
                                      tintColor: ColorConst.blueColor,
                                    ),
                                    const SizedBox(height: spacing16),
                                    Text(
                                      'Click or drag files to upload',
                                      textAlign: TextAlign.center,
                                      style: AppFontStyles.poppinsRegular(
                                        fontSize: fontSize16,
                                      ),
                                    ),
                                    const SizedBox(height: spacing16),
                                    Text(
                                      'Supported formats: .pdf, .docx, .txt, .zip …',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                )
                              : Wrap(
                                  spacing: spacing8,
                                  runSpacing: spacing8,
                                  children: pickedFiles.map((file) {
                                    final name = file.split('/').last;
                                    return Chip(
                                      label: Text(name),
                                      onDeleted: () {
                                        setState(() {
                                          pickedFiles.remove(file);
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: spacing32),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GradientFormButton(
                          text: 'Cancel',
                          isActiveButton: false,
                          onPressed: () {
                            entry?.remove();
                            SelectKnowledgeSourcePopup.build(
                              context,
                              onLocalFilesSelected: onFilesSelected,
                              onWebSourceSelected: (String name, String url) {},
                            );
                          },
                        ),
                        SizedBox(width: spacing12),
                        GradientFormButton(
                          text: 'Import',
                          isActiveButton: pickedFiles.isNotEmpty,
                          onPressed: pickedFiles.isEmpty
                              ? () {}
                              : () {
                                  onFilesSelected(pickedFiles);
                                  entry?.remove();
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    overlay?.insert(entry);
  }
}
