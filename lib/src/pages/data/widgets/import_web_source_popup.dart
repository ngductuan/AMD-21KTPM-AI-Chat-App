import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';

class ImportWebSourcePopup {
  static void build(
    BuildContext context, {
    required String knowledgeId,
  }) {
    // Lấy overlay, fallback sang Navigator nếu cần
    final overlay = Overlay.of(context) ?? Navigator.of(context).overlay!;
    OverlayEntry? entry;

    // Controllers để đọc input
    final unitNameController = TextEditingController();
    final webUrlController = TextEditingController();

    void _close() {
      entry?.remove();
    }

    entry = OverlayEntry(
      builder: (overlayContext) => Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: padding16),
            decoration: BoxDecoration(
              color: ColorConst.backgroundWhiteColor,
              borderRadius: BorderRadius.circular(radius12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(padding16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tiêu đề + đóng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Import Web Resource',
                        style: AppFontStyles.poppinsTitleSemiBold(
                            fontSize: fontSize16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _close,
                      ),
                    ],
                  ),

                  const SizedBox(height: spacing24),

                  // Nhập unit name
                  TextField(
                    controller: unitNameController,
                    decoration: const InputDecoration(
                      labelText: 'Unit Name',
                      hintText: 'Enter knowledge unit name',
                    ),
                  ),

                  const SizedBox(height: spacing24),

                  // Nhập web URL
                  TextField(
                    controller: webUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Web URL',
                      hintText: 'https://example.com',
                    ),
                  ),

                  const SizedBox(height: spacing32),

                  // Nút Cancel / Import
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
                        onPressed: () {
                          final unitName = unitNameController.text.trim();
                          final webUrl = webUrlController.text.trim();
                          if (unitName.isEmpty || webUrl.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill both fields'),
                              ),
                            );
                            return;
                          }
                          // Gọi API
                          ApiBase()
                              .uploadKnowledgeFromWeb(
                            knowledgeId: knowledgeId,
                            unitName: unitName,
                            webUrl: webUrl,
                          )
                              .then((resp) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Upload từ web thành công!'),
                              ),
                            );
                            _close();
                          }).catchError((e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi khi upload: $e'),
                              ),
                            );
                          });
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

    overlay.insert(entry);
  }
}
