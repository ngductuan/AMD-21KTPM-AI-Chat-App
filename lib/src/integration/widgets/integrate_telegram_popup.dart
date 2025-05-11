import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';

class TelegramIntegrationPopup {
  static void build(BuildContext context) {
    final overlay = Overlay.of(context)!;
    OverlayEntry? entry;

    final unitNameController = TextEditingController();
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
                          'Import from Telegram',
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
                        hintText: 'your-telegram-bot-token',
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
