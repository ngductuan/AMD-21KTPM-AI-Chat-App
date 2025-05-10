import 'package:eco_chat_bot/src/integration/widgets/integrate_messenger_popup.dart';
import 'package:eco_chat_bot/src/integration/widgets/integrate_slack_popup.dart';
import 'package:eco_chat_bot/src/integration/widgets/integrate_telegram_popup.dart';
import 'package:eco_chat_bot/src/pages/knowledge_source/widgets/select_source_item.dart';
import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';

class AppIntegration extends StatefulWidget {
  const AppIntegration({super.key, this.assistantId = ''});
  static const String routeName = '/app-integration';

  final String assistantId;

  @override
  State<AppIntegration> createState() => _AppIntegrationState();
}

class _AppIntegrationState extends State<AppIntegration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Integration',
          style: AppFontStyles.poppinsTitleBold(fontSize: fontSize20),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: ColorConst.backgroundWhiteColor,
        shadowColor: ColorConst.backgroundLightGrayColor,
      ),
      // backgroundColor: ColorConst.backgroundGrayColor,
      backgroundColor: ColorConst.backgroundWhiteColor,
      body: Padding(
        padding: const EdgeInsets.all(spacing16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                SlackIntegrationPopup.build(context);
              },
              child: SelectSourceItem.build(
                  AssetPath.knowledgeSource['slack'] ?? '',
                  {
                    'display': 'Slack',
                    'hint': 'Publish bot to Slack',
                  },
                  trailingIconData: Icons.device_hub),
            ),
            GestureDetector(
              onTap: () {
                TelegramIntegrationPopup.build(context);
              },
              child: SelectSourceItem.build(
                  AssetPath.knowledgeSource['telegram'] ?? '',
                  {
                    'display': 'Telegram',
                    'hint': 'Publish bot to Telegram',
                  },
                  avatarSize: spacing20,
                  trailingIconData: Icons.device_hub),
            ),
            GestureDetector(
              onTap: () {
                MessengerIntegrationPopup.build(context);
              },
              child: SelectSourceItem.build(
                  AssetPath.knowledgeSource['messenger'] ?? '',
                  {
                    'display': 'Messenger',
                    'hint': 'Publish bot to Messenger',
                  },
                  avatarSize: spacing24,
                  trailingIconData: Icons.device_hub),
            ),
          ],
        ),
      ),
    );
  }
}
