import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';

class SlackSourcePopup {
  static void build(
    BuildContext context, {
    required String knowledgeId,
  }) {
    final overlay = Overlay.of(context)!;
    OverlayEntry? entry;

    final unitNameController = TextEditingController();
    final workspaceController = TextEditingController();
    final botTokenController = TextEditingController();
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
                //margin: const EdgeInsets.symmetric(horizontal: padding16),
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
                          'Import from Slack',
                          style: AppFontStyles.poppinsTitleSemiBold(fontSize: fontSize16),
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
                        hintText: 'e.g. Slack Channel',
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: spacing16),

                    // Workspace
                    TextField(
                      controller: workspaceController,
                      decoration: const InputDecoration(
                        labelText: 'Slack Workspace',
                        hintText: 'your-workspace',
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: spacing16),

                    // Bot Token
                    TextField(
                      controller: botTokenController,
                      decoration: const InputDecoration(
                        labelText: 'Slack Bot Token',
                        hintText: 'xoxb-...',
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
                            final ws = workspaceController.text.trim();
                            final token = botTokenController.text.trim();
                            if (unit.isEmpty || ws.isEmpty || token.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please fill all fields')),
                              );
                              return;
                            }
                            loading.value = true;
                            ApiBase()
                                .uploadKnowledgeFromSlack(
                              knowledgeId: knowledgeId,
                              unitName: unit,
                              slackWorkspace: ws,
                              slackBotToken: token,
                            )
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Import from Slack thành công!')),
                              );
                            }).catchError((e) {
                              String msg = 'Internal server error';
                              try {
                                final m = jsonDecode(RegExp(r'\{.*\}').firstMatch(e.toString())?.group(0) ?? '{}')
                                    as Map<String, dynamic>;
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
