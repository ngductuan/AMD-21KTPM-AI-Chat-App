import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/constants/dimensions.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';

/// Gọi hàm này để show dialog upgrade
void showUpgradeAccountModal(BuildContext context) {
  final size = MediaQuery.of(context).size;
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
                    'Upgrade PRO Account',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: spacing12),

                // PageView
                Expanded(
                  child: PageView(
                    controller: pageController,
                    padEnds: false,
                    onPageChanged: (idx) => setState(() => currentPage = idx),
                    children: [
                      _buildPlanPage(
                        ctx,
                        title: 'Basic',
                        subtitle: 'Free',
                        features: [
                          'AI Chat Model: GPT-3.5',
                          '50 queries per day',
                          'AI Reading Assistant',
                          'Real-time Web Access',
                          'AI Writing Assistant',
                        ],
                        buttonText: 'Select Basic',
                        isHotPick: false,
                      ),
                      _buildPlanPage(
                        ctx,
                        title: 'Starter',
                        subtitle: '1-month Free Trial, then \$9.99/mo',
                        features: [
                          'AI Chat Models: GPT-4 Turbo',
                          'Unlimited queries per month',
                          '2× faster speed',
                          'Priority email support',
                          'Jira & Github Copilots',
                        ],
                        buttonText: 'Select Starter',
                        isHotPick: false,
                      ),
                      _buildPlanPage(
                        ctx,
                        title: 'Pro Annual',
                        subtitle: 'Save 33% - \$79.99/yr',
                        trialInfo: '1-month Free Trial',
                        features: [
                          'All Starter features',
                          'Enterprise integrations',
                          'Dedicated support',
                          'Custom AI workflows',
                          'Unlimited usage',
                        ],
                        buttonText: 'Select Pro',
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
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: currentPage == idx ? 12 : 8,
                      height: currentPage == idx ? 12 : 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentPage == idx
                            ? Theme.of(context).primaryColor
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

/// Xây dựng từng trang của PageView
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
              Text(
                title,
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: spacing8),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
              if (trialInfo != null) ...[
                const SizedBox(height: spacing6),
                Text(
                  trialInfo,
                  style: TextStyle(fontSize: 16, color: Colors.orange.shade700),
                ),
              ],
              const SizedBox(height: spacing12),

              // Danh sách tính năng (đã phóng to chữ)
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: features
                      .map((f) => _FeatureItem(text: f, fontSize: 16))
                      .toList(),
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
              label: const Text('HOT',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
              backgroundColor: Colors.redAccent,
            ),
          ),
      ],
    ),
  );
}

/// Widget cho mỗi dòng feature với kích thước chữ lớn hơn
class _FeatureItem extends StatelessWidget {
  final String text;
  final double fontSize;

  const _FeatureItem({Key? key, required this.text, required this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check,
              size: fontSize, color: Theme.of(context).primaryColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: fontSize, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
