import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';

class GoogleDriveSourcePopup {
  // Khởi tạo GoogleSignIn với scope đọc Drive
  static final _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'https://www.googleapis.com/auth/drive.readonly',
      'https://www.googleapis.com/auth/drive.metadata.readonly',
    ],
  );

  static void build(
    BuildContext context, {
    required String knowledgeId,
  }) {
    final overlay = Overlay.of(context)!;
    OverlayEntry? entry;

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
                width: 300,
                padding: const EdgeInsets.all(padding16),
                decoration: BoxDecoration(
                  color: ColorConst.backgroundWhiteColor,
                  borderRadius: BorderRadius.circular(radius12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Kết nối Google Drive',
                      style: AppFontStyles.poppinsTitleSemiBold(
                        fontSize: fontSize16,
                      ),
                    ),
                    const SizedBox(height: spacing24),
                    if (isLoading)
                      const CircularProgressIndicator()
                    else ...[
                      // Nút sign in Google
                      GradientFormButton(
                        text: 'Sign in with Google',
                        isActiveButton: true,
                        onPressed: () async {
                          loading.value = true;
                          try {
                            // 1) Sign in
                            final account = await _googleSignIn.signIn();
                            if (account == null) {
                              // user cancelled
                              loading.value = false;
                              return;
                            }
                            final auth = await account.authentication;
                            final token = auth.accessToken;
                            if (token == null)
                              throw Exception('No access token');

                            // 2) Gửi lên server
                            await ApiBase().uploadKnowledgeFromGoogleDrive(
                              knowledgeId: knowledgeId,
                              // giả sử bạn đã bổ sung param token
                              googleDriveToken: token,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Import từ Drive thành công!'),
                              ),
                            );
                            _googleSignIn.disconnect();
                            _close();
                          } catch (e) {
                            String msg = 'Có lỗi xảy ra';
                            try {
                              final body = RegExp(r'\{.*\}')
                                      .firstMatch(e.toString())
                                      ?.group(0) ??
                                  '{}';
                              msg = (jsonDecode(body) as Map)['message'] ?? msg;
                            } catch (_) {}
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi: $msg')),
                            );
                            loading.value = false;
                          }
                        },
                      ),
                      const SizedBox(height: spacing16),
                      TextButton(
                        onPressed: _close,
                        child: const Text('Cancel'),
                      ),
                    ],
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
