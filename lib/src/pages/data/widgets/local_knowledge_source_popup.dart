import 'package:dotted_border/dotted_border.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';

class LocalKnowledgeSourcePopup {
  static void build(
    BuildContext context, {
    required String knowledgeId,
    required void Function(String knowledgeId, List<String> paths) onFilesSelected,
  }) {
    final overlay = Overlay.of(context) ?? Navigator.of(context).overlay;
    OverlayEntry? overlayEntry;
    List<String> _pickedFiles = [];

    void _close() => overlayEntry?.remove();

    overlayEntry = OverlayEntry(
      builder: (overlayContext) => Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            // width: MediaQuery.of(overlayContext).size.width * 0.8,
            decoration: BoxDecoration(
              color: ColorConst.backgroundWhiteColor,
              borderRadius: BorderRadius.circular(radius12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(padding16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title & Close
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
                        icon: const Icon(Icons.close),
                        onPressed: _close,
                      ),
                    ],
                  ),

                  const SizedBox(height: spacing32),

                  // Drag or Click area
                  GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        allowMultiple: true,
                      );
                      if (result == null) return;
                      _pickedFiles = result.paths.whereType<String>().toList();
                      overlayEntry?.markNeedsBuild();
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
                        color: ColorConst.backgroundGrayColor.withAlpha((0.5 * 255).toInt()),
                        child: _pickedFiles.isEmpty
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
                                  const Text(
                                    'Supported formats: .pdf, .docx, .txt, .zip …',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _pickedFiles.map((p) {
                                  final name = p.split('/').last;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.insert_drive_file),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(name)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: spacing32),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GradientFormButton(
                        text: 'Cancel',
                        isActiveButton: false,
                        onPressed: _close,
                      ),
                      const SizedBox(width: spacing12),
                      GradientFormButton(
                        text: 'Import',
                        isActiveButton: true,
                        onPressed: _pickedFiles.isNotEmpty
                            ? () {
                                if (_pickedFiles.isNotEmpty) {
                                  onFilesSelected(knowledgeId, _pickedFiles);
                                  _close();
                                }
                              }
                            : () {},
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

    overlay?.insert(overlayEntry);
  }
}
