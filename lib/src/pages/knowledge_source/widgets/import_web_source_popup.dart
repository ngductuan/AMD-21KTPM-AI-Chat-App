import 'package:eco_chat_bot/src/pages/knowledge_source/widgets/select_knowledge_source_popup.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';
import 'package:eco_chat_bot/src/widgets/input_form_field.dart';
import 'package:flutter/material.dart';

import '../../../constants/styles.dart';

class ImportWebSourcePopup {
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
                        'Import Web Resource',
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

                  SizedBox(height: spacing24),

                  // Name Field
                  InputFormField.build('Name', 'Enter knowledge unit name', required: true),

                  SizedBox(height: spacing24),

                  // Instructions Field
                  InputFormField.build('Web URL', 'https://example.com', required: true),

                  SizedBox(height: spacing32),

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ColorConst.bluePastelColor,
                      borderRadius: BorderRadius.circular(spacing12),
                      border: Border.all(color: ColorConst.blueColor.withAlpha((0.5 * 255).toInt()), width: 1),
                    ),
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Limitation:',
                          style: AppFontStyles.poppinsTitleSemiBold(fontSize: fontSize16, color: Colors.blue),
                        ),
                        SizedBox(height: spacing8),
                        Text(
                          '• You can load up to 64 pages at a time',
                          style: AppFontStyles.poppinsRegular(),
                        ),
                        SizedBox(height: spacing4),
                        Text(
                          '• Need more? Contact us at',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'myjarvischat@gmail.com',
                          style: AppFontStyles.poppinsRegular(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: spacing40),

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
