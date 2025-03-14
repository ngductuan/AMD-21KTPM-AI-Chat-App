import 'package:dotted_border/dotted_border.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:eco_chat_bot/src/pages/knowledge_source/widgets/select_knowledge_source_popup.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';
import 'package:flutter/material.dart';

import '../../../constants/styles.dart';

class LocalKnowledgeSourcePopup {
  static void build(BuildContext context) {
    final overlay = Overlay.of(context);

    OverlayEntry? overlayEntry;

    void closeOverlay(BuildContext context) {
      overlayEntry?.remove();
      SelectKnowledgeSourcePopup.build(context);
    }

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
              padding: const EdgeInsets.all(padding16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title and Close Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Import Local Files',
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
                          onPressed: () {
                            closeOverlay(context);
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: spacing32),

                  Container(
                    color: ColorConst.backgroundGrayColor.withAlpha((0.5 * 255).toInt()),
                    child: DottedBorder(
                      strokeWidth: 1,
                      dashPattern: [4, 2], // Dashed pattern
                      borderType: BorderType.RRect, // Rounded rectangle
                      radius: Radius.circular(radius12), // Border radius
                      color: ColorConst.textGrayColor,
                      child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(spacing16),
                            child: Column(
                              children: [
                                ImageHelper.loadFromAsset(AssetPath.icUpload,
                                    width: spacing28, height: spacing28, tintColor: ColorConst.blueColor),
                                SizedBox(height: spacing16),
                                Text(
                                  "Click or drag files to upload",
                                  style: AppFontStyles.poppinsRegular(fontSize: fontSize16),
                                ),
                                SizedBox(height: spacing16),
                                Text(
                                  textAlign: TextAlign.center,
                                  "Supported formats: .c, .cpp, .docx, .html, .java, .json, .md, .pdf, .php, .pptx, .py, .py, .rb, .tex, .txt, .xls, .xml, .zip",
                                  style: AppFontStyles.poppinsRegular(color: ColorConst.textGrayColor),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),

                  SizedBox(height: spacing32),

                  // Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GradientFormButton(
                        text: 'Cancel',
                        onPressed: () {
                          closeOverlay(context);
                        },
                        isActiveButton: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: spacing12),
                        child: GradientFormButton(
                          text: 'Import',
                          onPressed: () {},
                          isActiveButton: true,
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
