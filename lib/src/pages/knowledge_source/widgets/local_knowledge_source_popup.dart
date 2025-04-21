import 'package:dotted_border/dotted_border.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';
import 'package:eco_chat_bot/src/pages/knowledge_source/widgets/select_knowledge_source_popup.dart';

class LocalKnowledgeSourcePopup {
  static void build(
    BuildContext context, {
    required void Function(String) onFileSelected,
  }) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;
    String? _pickedFile;

    void _close() {
      overlayEntry?.remove();
    }

    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: ColorConst.backgroundWhiteColor,
              borderRadius: BorderRadius.circular(radius12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(padding16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title and Close
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Import Local Files',
                        style: AppFontStyles.poppinsTitleSemiBold(
                          fontSize: fontSize16,
                        ),
                      ),
                      SizedBox(
                        width: spacing32,
                        height: spacing32,
                        child: IconButton(
                          icon: Icon(Icons.close, size: spacing20),
                          onPressed: () {
                            _close();
                            SelectKnowledgeSourcePopup.build(
                              context,
                              onLocalFileSelected: onFileSelected,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: spacing32),

                  // Drag or Click Area
                  GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform
                          .pickFiles(allowMultiple: false);
                      if (result == null) return;
                      _pickedFile = result.files.single.path;
                      overlayEntry?.markNeedsBuild();
                    },
                    child: DottedBorder(
                      strokeWidth: 1,
                      dashPattern: [4, 2],
                      borderType: BorderType.RRect,
                      radius: Radius.circular(radius12),
                      color: ColorConst.textGrayColor,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(spacing16),
                        color: ColorConst.backgroundGrayColor
                            .withAlpha((0.5 * 255).toInt()),
                        child: _pickedFile == null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ImageHelper.loadFromAsset(
                                    AssetPath.icUpload,
                                    width: spacing28,
                                    height: spacing28,
                                    tintColor: ColorConst.blueColor,
                                  ),
                                  SizedBox(height: spacing16),
                                  Text(
                                    'Click or drag files to upload',
                                    textAlign: TextAlign.center,
                                    style: AppFontStyles.poppinsRegular(
                                      fontSize: fontSize16,
                                    ),
                                  ),
                                  SizedBox(height: spacing16),
                                  Text(
                                    'Supported formats: .pdf, .docx, .txt, .zip …',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(
                                    Icons.insert_drive_file,
                                    size: spacing28,
                                    color: ColorConst.blueColor,
                                  ),
                                  SizedBox(width: spacing8),
                                  Expanded(
                                    child: Text(
                                      _pickedFile!.split('/').last,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFontStyles.poppinsTextBold(),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: spacing32),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GradientFormButton(
                        text: 'Cancel',
                        isActiveButton: false,
                        onPressed: () {
                          _close();
                          SelectKnowledgeSourcePopup.build(
                            context,
                            onLocalFileSelected: onFileSelected,
                          );
                        },
                      ),
                      SizedBox(width: spacing12),
                      GradientFormButton(
                        text: 'Import',
                        isActiveButton: true,
                        onPressed: () {
                          if (_pickedFile != null) {
                            onFileSelected(_pickedFile!);
                            _close();
                          }
                        },
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
