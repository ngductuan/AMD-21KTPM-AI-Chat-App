import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/constants/dimensions.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';

/// Gọi hàm này để show dialog upgrade
void showUpgradeAccountModal(BuildContext context) {
  final size = MediaQuery.of(context).size;
  // Tạo controller để quản lý PageView
  final pageController = PageController();
  int currentPage = 0;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setState) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        child: Container(
          width: size.width,
          height: size.height * 0.8,
          padding: const EdgeInsets.all(spacing16),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tiêu đề
                Center(
                  child: Text(
                    'Upgrade PRO account?',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: spacing16),

                // PageView để swipe ngang qua 3 gói
                Expanded(
                  child: PageView(
                    controller: pageController,
                    padEnds: false,
                    onPageChanged: (idx) {
                      setState(() => currentPage = idx);
                    },
                    children: [
                      _buildPlanPage(
                        ctx,
                        title: 'Basic',
                        subtitle: 'Free',
                        features: [
                          'AI Chat Model\nGPT-3.5',
                          'AI Action Injection',
                          'Select Text for AI Action',
                          '50 free queries per day',
                          'AI Reading Assistant',
                          'Real-time Web Access',
                          'AI Writing Assistant',
                          'AI Pro Search',
                          'Lower response speed during high-traffic',
                        ],
                        buttonText: 'Sign up to subscribe',
                        isHotPick: false,
                      ),
                      _buildPlanPage(
                        ctx,
                        title: 'Starter',
                        subtitle: '1-month Free Trial\nThen \$9.99/mo',
                        features: [
                          'AI Chat Models\nGPT-3.5 & GPT-4.0/Turbo & Gemini Pro & Gemini Ultra',
                          'AI Action Injection',
                          'Select Text for AI Action',
                          'Unlimited queries per month',
                          'AI Reading Assistant',
                          'Real-time Web Access',
                          'AI Writing Assistant',
                          'AI Pro Search',
                          'Jira Copilot Assistant',
                          'Github Copilot Assistant',
                          'Maximize productivity with unlimited* queries',
                          'No request limits during high-traffic',
                          '2X faster response speed',
                          'Priority email support',
                        ],
                        buttonText: 'Sign up to subscribe',
                        isHotPick: false,
                      ),
                      _buildPlanPage(
                        ctx,
                        title: 'Pro Annually',
                        subtitle: '1-month Free Trial\nThen \$79.99/yr',
                        trialInfo: 'Save 33% on annual plan!',
                        features: [
                          'AI Chat Models\nGPT-3.5 & GPT-4.0/Turbo & Gemini Pro & Gemini Ultra',
                          'AI Action Injection',
                          'Select Text for AI Action',
                          'Unlimited queries per year',
                          'AI Reading Assistant',
                          'Real-time Web Access',
                          'AI Writing Assistant',
                          'AI Pro Search',
                          'Jira Copilot Assistant',
                          'Github Copilot Assistant',
                          'Maximize productivity with unlimited* queries',
                          'No request limits during high-traffic',
                          '2X faster response speed',
                          'Priority email support',
                        ],
                        buttonText: 'Sign up to subscribe',
                        isHotPick: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: spacing12),
                // Indicator chấm
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (idx) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentPage == idx
                            ? Colors.blueAccent
                            : Colors.grey.shade400,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Xây dựng từng trang của PageView (có truyền context)
Widget _buildPlanPage(
  BuildContext context, {
  required String title,
  required String subtitle,
  String? trialInfo,
  required List<String> features,
  required String buttonText,
  bool isHotPick = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: spacing8),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // Thẻ chính
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(spacing16),
          ),
          padding: const EdgeInsets.all(spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: spacing8),
              Text(subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              if (trialInfo != null) ...[
                const SizedBox(height: spacing4),
                Text(trialInfo,
                    style:
                        TextStyle(fontSize: 12, color: Colors.orange.shade700)),
              ],
              const SizedBox(height: spacing12),

              // Scroll danh sách tính năng
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: features.map((f) => _FeatureItem(text: f)).toList(),
                ),
              ),

              const SizedBox(height: spacing12),
              GradientFormButton(
                text: buttonText,
                onPressed: () => Navigator.of(context).pop(),
                isActiveButton: true,
              ),
            ],
          ),
        ),

        // Hot Pick badge
        if (isHotPick)
          Positioned(
            top: -10,
            right: -10,
            child: Chip(
              label: const Text('HOT PICK',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
              backgroundColor: Colors.orange,
            ),
          ),
      ],
    ),
  );
}

/// Widget cho mỗi dòng feature
class _FeatureItem extends StatelessWidget {
  final String text;
  const _FeatureItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 12, height: 1.4))),
        ],
      ),
    );
  }
}
