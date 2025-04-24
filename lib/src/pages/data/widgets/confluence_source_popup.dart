import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';

class ConfluenceSourcePopup {
  static void build(
    BuildContext context, {
    required String knowledgeId,
  }) {
    final overlay = Overlay.of(context)!;
    OverlayEntry? entry;

    final unitNameController = TextEditingController();
    final pageUrlController = TextEditingController();
    final usernameController = TextEditingController();
    final accessTokenController = TextEditingController();
    final loading = ValueNotifier<bool>(false);

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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Import from Confluence',
                          style: AppFontStyles.poppinsTitleSemiBold(
                              fontSize: fontSize16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: isLoading ? null : _close,
                        ),
                      ],
                    ),
                    const SizedBox(height: spacing24),

                    // Unit Name
                    TextField(
                      controller: unitNameController,
                      decoration: const InputDecoration(
                        labelText: 'Unit Name',
                        hintText: 'e.g. Project Docs',
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: spacing16),

                    // Wiki Page URL
                    TextField(
                      controller: pageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Wiki Page URL',
                        hintText: 'https://yourcompany.atlassian.net/...',
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: spacing16),

                    // Username
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: spacing16),

                    // Access Token
                    TextField(
                      controller: accessTokenController,
                      decoration: const InputDecoration(
                        labelText: 'Access Token',
                        hintText: 'Confluence API token',
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: spacing24),

                    if (isLoading) const CircularProgressIndicator(),
                    const SizedBox(height: spacing16),

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
                          isActiveButton: !isLoading,
                          onPressed: () {
                            final unit = unitNameController.text.trim();
                            final url = pageUrlController.text.trim();
                            final user = usernameController.text.trim();
                            final token = accessTokenController.text.trim();
                            if ([unit, url, user, token]
                                .any((s) => s.isEmpty)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please fill all fields')),
                              );
                              return;
                            }
                            loading.value = true;
                            ApiBase()
                                .uploadKnowledgeFromConfluence(
                              knowledgeId: knowledgeId,
                              unitName: unit,
                              wikiPageUrl: url,
                              confluenceUsername: user,
                              confluenceAccessToken: token,
                            )
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Import from Confluence thành công!')),
                              );
                            }).catchError((e) {
                              String msg = 'Internal server error';
                              try {
                                final m = jsonDecode(RegExp(r'\{.*\}')
                                        .firstMatch(e.toString())
                                        ?.group(0) ??
                                    '{}') as Map<String, dynamic>;
                                msg = m['message'] ?? msg;
                              } catch (_) {}
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi: $msg')),
                              );
                            }).whenComplete(_close);
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
