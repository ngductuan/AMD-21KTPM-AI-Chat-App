import 'package:eco_chat_bot/src/pages/knowledge_source/widgets/select_knowledge_source_popup.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';
import 'package:eco_chat_bot/src/widgets/input_form_field.dart';
import 'package:flutter/material.dart';
import '../../../constants/styles.dart';

class ImportWebSourcePopup {
  /// Opens an overlay to import from a web URL.
  static void build(BuildContext context) {
    final overlay = Overlay.of(context);
    OverlayEntry? entry;

    void closeAndReturnToSelector() {
      entry?.remove();
      SelectKnowledgeSourcePopup.build(
        context,
        onLocalFilesSelected: (files) {
          // nothing to do here when returning from web import
        },
      );
    }

    entry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
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
                      'Import Web Resource',
                      style: AppFontStyles.poppinsTitleSemiBold(
                        fontSize: fontSize16,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: spacing20),
                      onPressed: closeAndReturnToSelector,
                    ),
                  ],
                ),

                const SizedBox(height: spacing24),

                // Name field
                InputFormField.build(
                  'Name',
                  'Enter knowledge unit name',
                  required: true,
                ),

                const SizedBox(height: spacing24),

                // URL field
                InputFormField.build(
                  'Web URL',
                  'https://example.com',
                  required: true,
                ),

                const SizedBox(height: spacing32),

                // Limitation notice
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(spacing12),
                  decoration: BoxDecoration(
                    color: ColorConst.bluePastelColor,
                    borderRadius: BorderRadius.circular(radius12),
                    border: Border.all(
                      color:
                          ColorConst.blueColor.withAlpha((0.5 * 255).toInt()),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Limitation:',
                        style: AppFontStyles.poppinsTitleSemiBold(
                          fontSize: fontSize16,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: spacing8),
                      Text('• You can load up to 64 pages at a time',
                          style: AppFontStyles.poppinsRegular()),
                      const SizedBox(height: spacing4),
                      Text('• Need more? Contact us at',
                          style: AppFontStyles.poppinsRegular()),
                      Text('myjarvischat@gmail.com',
                          style:
                              AppFontStyles.poppinsRegular(color: Colors.blue)),
                    ],
                  ),
                ),

                const SizedBox(height: spacing40),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GradientFormButton(
                      text: 'Cancel',
                      isActiveButton: false,
                      onPressed: closeAndReturnToSelector,
                    ),
                    const SizedBox(width: spacing12),
                    GradientFormButton(
                      text: 'Import',
                      isActiveButton: true,
                      onPressed: () {
                        // TODO: handle import logic
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay?.insert(entry);
  }
}
