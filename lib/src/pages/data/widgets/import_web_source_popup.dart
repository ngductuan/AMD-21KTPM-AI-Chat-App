import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';

class ImportWebSourcePopup {
  static void build(
    BuildContext context, {
    required String knowledgeId,
  }) {
    final overlay = Overlay.of(context)!;
    OverlayEntry? entry;

    final unitNameController = TextEditingController();
    final webUrlController = TextEditingController();
    final loading = ValueNotifier<bool>(false);

    // Chỉ remove overlay, không dispose notifier
    void _close() {
      entry?.remove();
    }

    entry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black54,
        child: Center(
          child: ValueListenableBuilder<bool>(
            valueListenable: loading,
            builder: (_, isLoading, __) {
              return Container(
                padding: const EdgeInsets.all(padding16),
                margin: const EdgeInsets.symmetric(horizontal: padding16),
                decoration: BoxDecoration(
                  color: ColorConst.backgroundWhiteColor,
                  borderRadius: BorderRadius.circular(radius12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tiêu đề & close
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Import Web Resource',
                            style: AppFontStyles.poppinsTitleSemiBold(
                                fontSize: fontSize16)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: isLoading ? null : _close,
                        ),
                      ],
                    ),
                    const SizedBox(height: spacing24),
                    TextField(
                      controller: unitNameController,
                      decoration: const InputDecoration(labelText: 'Unit Name'),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: spacing24),
                    TextField(
                      controller: webUrlController,
                      decoration: const InputDecoration(labelText: 'Web URL'),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: spacing32),
                    if (isLoading) const CircularProgressIndicator(),
                    const SizedBox(height: spacing16),
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
                          isActiveButton: !isLoading,
                          onPressed: () {
                            final unit = unitNameController.text.trim();
                            final url = webUrlController.text.trim();
                            if (unit.isEmpty || url.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please fill both fields')),
                              );
                              return;
                            }
                            loading.value = true;
                            ApiBase()
                                .uploadKnowledgeFromWeb(
                              knowledgeId: knowledgeId,
                              unitName: unit,
                              webUrl: url,
                            )
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Upload thành công!')),
                              );
                            }).catchError((e) {
                              // parse JSON nếu có
                              String msg = 'Internal server error';
                              try {
                                final m = jsonDecode(
                                  RegExp(r'\{.*\}')
                                          .firstMatch(e.toString())
                                          ?.group(0) ??
                                      '{}',
                                ) as Map<String, dynamic>;
                                msg = m['message'] ?? msg;
                              } catch (_) {}
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi: $msg')),
                              );
                            }).whenComplete(() {
                              _close();
                            });
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

    overlay.insert(entry);
  }
}
