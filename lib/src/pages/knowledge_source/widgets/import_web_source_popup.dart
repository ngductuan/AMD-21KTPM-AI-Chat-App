import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';
import 'package:flutter/material.dart';
import '../../../constants/styles.dart';

class ImportWebSourcePopup {
  /// Opens a dialog to import from a web URL.
  static Future<void> build(
    BuildContext context, {
    required void Function(String name, String url) onWebSourceSelected,
  }) {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) {
        // dùng builderContext để mọi InheritedWidget đều có sẵn
        final w = MediaQuery.of(dialogContext).size.width * .8;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius12),
          ),
          backgroundColor: ColorConst.backgroundWhiteColor,
          insetPadding: EdgeInsets.symmetric(
              horizontal: (MediaQuery.of(dialogContext).size.width - w) / 2),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(padding16),
              child: Form(
                key: _formKey,
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
                              fontSize: fontSize16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: spacing20),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),

                    const SizedBox(height: spacing24),

                    // Name
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        hintText: 'Enter knowledge unit name',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),

                    const SizedBox(height: spacing24),

                    // URL
                    TextFormField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        labelText: 'Web URL *',
                        hintText: 'https://example.com',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
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
                          color: ColorConst.blueColor
                              .withAlpha((0.5 * 255).toInt()),
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
                              style: AppFontStyles.poppinsRegular(
                                  color: Colors.blue)),
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
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                        const SizedBox(width: spacing12),
                        GradientFormButton(
                          text: 'Import',
                          isActiveButton: true,
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              onWebSourceSelected(
                                nameController.text.trim(),
                                urlController.text.trim(),
                              );
                              Navigator.of(dialogContext).pop();
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
        );
      },
    );
  }
}
