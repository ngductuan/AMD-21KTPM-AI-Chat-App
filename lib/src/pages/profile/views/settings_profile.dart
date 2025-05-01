import 'dart:convert';
import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:eco_chat_bot/src/constants/dimensions.dart';
import 'package:eco_chat_bot/src/constants/share_preferences/local_storage_key.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/pages/authentication/views/login.dart';
import 'package:eco_chat_bot/src/pages/authentication/views/welcome.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';
import 'package:eco_chat_bot/src/widgets/toast/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(LocalStorageKey.accessToken);
    setState(() {
      isLoggedIn = token != null;
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(LocalStorageKey.accessToken);
    final refreshToken = prefs.getString(LocalStorageKey.refreshToken);

    final url = Uri.parse('${ApiBase.authUrl}/api/v1/auth/sessions/current');

    final newHeaders = Map<String, String>.from(ApiBase.headerAuth);
    newHeaders.addAll({'X-Stack-Refresh-Token': refreshToken ?? ''});

    try {
      final request = http.Request('DELETE', url);
      request.body = jsonEncode({});
      request.headers.addAll(newHeaders);
      final response = await request.send();

      print("🔐 Logout status: ${response.statusCode}");
      print("🔐 Logout response: ${await response.stream.bytesToString()}");

    } catch (e) {
      print("❌ Logout error: $e");
    }

    // Xóa tất cả dữ liệu lưu trữ và cập nhật lại trạng thái đăng nhập
    await prefs.clear();
    setState(() {
      isLoggedIn = false;
    });

    // Nếu muốn điều hướng về màn hình login, bạn có thể mở dòng dưới đây
    Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: ColorConst.backgroundWhiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(spacing20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Do you want to log out?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GradientFormButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      isActiveButton: false,
                    ),
                  ),
                  const SizedBox(width: spacing12),
                  Expanded(
                    child: GradientFormButton(
                      text: 'Confirm',
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      isActiveButton: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpgradeModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: ColorConst.backgroundWhiteColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Upgrade PRO account?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Benefit features',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildBenefitItem('AI Chat Models (GPT-3.5, GPT-4.0, Gemini...)'),
              const SizedBox(height: 12),
              _buildBenefitItem('Unlimited queries per month'),
              const SizedBox(height: 12),
              _buildBenefitItem('Unlimited AI Action Injection'),
              const SizedBox(height: 30),
              const Text(
                '\$9.99/month',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GradientFormButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                      isActiveButton: false,
                    ),
                  ),
                  const SizedBox(width: spacing12),
                  Expanded(
                    child: GradientFormButton(
                      text: 'Upgrade',
                      onPressed: () => Navigator.of(context).pop(),
                      isActiveButton: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: spacing24,
          height: spacing24,
          decoration:
              const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Colors.white, size: spacing20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  void _showAboutUsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: ColorConst.backgroundWhiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Creator:',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorConst.blueColor),
              ),
              const SizedBox(height: 8),
              const Text('Nguyễn Gia Bảo',
                  style: TextStyle(
                      fontSize: spacing18, fontWeight: FontWeight.bold)),
              const Text('Nguyễn Đức Tuấn',
                  style: TextStyle(
                      fontSize: spacing18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              GradientFormButton(
                text: 'Cancel',
                padding: spacing12,
                onPressed: () => Navigator.of(context).pop(),
                isActiveButton: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(trailing,
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(spacing16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  // First group
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        _buildSettingItem(
                          icon: Icons.brightness_6,
                          iconColor: Colors.purple,
                          title: 'Theme',
                          trailing: 'Light mode',
                          onTap: () => AppToast(
                            context: context,
                            message: 'Coming soon!',
                            mode: AppToastMode.info,
                          ).show(context),
                        ),
                        Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
                        _buildSettingItem(
                          icon: Icons.workspace_premium,
                          iconColor: Colors.pink,
                          title: 'Upgrade account',
                          onTap: () => _showUpgradeModal(context),
                        ),
                        Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
                        _buildSettingItem(
                          icon: Icons.info_outline,
                          iconColor: Colors.blue,
                          title: 'About us',
                          onTap: () => _showAboutUsModal(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Log out or Login section
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    child: _buildSettingItem(
                      icon: isLoggedIn ? Icons.logout : Icons.login,
                      iconColor: Colors.orange,
                      title: isLoggedIn ? 'Log out' : 'Login',
                      onTap: () async {
                        if (isLoggedIn) {
                          final confirm = await _showLogoutDialog(context);
                          if (confirm == true) {
                            await _logout(context);
                          }
                        } else {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login', (route) => false);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(spacing16),
              child: Column(
                children: const [
                  Text('Version: 2.3.4',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Design by @EcoTeam',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                  SizedBox(height: spacing24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
