import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';

class SlackIntegrationPopup {
  static void build(BuildContext context) {
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
                        labelText: 'Bot Token',
                        hintText: 'e.g. xoxb-...',
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: spacing16),

                    // Workspace
                    TextField(
                      controller: workspaceController,
                      decoration: const InputDecoration(
                        labelText: 'Client ID',
                        hintText: 'your-slack-app',
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: spacing16),

                    // Bot Token
                    TextField(
                      controller: botTokenController,
                      decoration: const InputDecoration(
                        labelText: 'Client Secret',
                        hintText: 'your-slack-app',
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: spacing24),
                    TextField(
                      controller: botTokenController,
                      decoration: const InputDecoration(
                        labelText: 'Signing Secret',
                        hintText: 'your-slack-app',
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: spacing24),

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
                          onPressed: () {},
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
