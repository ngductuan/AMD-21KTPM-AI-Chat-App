import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:flutter/material.dart';

class ProgressTracker extends StatelessWidget {
  final int today;
  final int total;

  const ProgressTracker({
    Key? key,
    required this.today,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: spacing16),
      child: Column(
        children: [
          // Header row with labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today',
                style: AppFontStyles.poppinsTitleSemiBold(fontSize: spacing16),
              ),
              Text(
                'Total',
                style: AppFontStyles.poppinsTitleSemiBold(fontSize: spacing16),
              ),
            ],
          ),
          const SizedBox(height: spacing8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: today == 0 && total == 0 ? 0 : today / total,
              backgroundColor: Colors.grey.shade200,
              color: Colors.blue,
              minHeight: spacing8,
            ),
          ),
          const SizedBox(height: spacing8),

          // Values row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                today.toString(),
                style: AppFontStyles.poppinsTitleSemiBold(fontSize: spacing16),
              ),
              Text(
                total.toString(),
                style: AppFontStyles.poppinsTitleSemiBold(fontSize: spacing16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
