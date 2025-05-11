import 'package:flutter/material.dart';

import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';

class EmailThreadScreen extends StatefulWidget {
  const EmailThreadScreen({super.key});

  static const String routeName = '/email-thread';

  @override
  State<EmailThreadScreen> createState() => _EmailThreadScreenState();
}

class _EmailThreadScreenState extends State<EmailThreadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Your back icon
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
        leadingWidth: spacing48,
        elevation: 1,
        shadowColor: ColorConst.backgroundLightGrayColor,
        backgroundColor: ColorConst.backgroundWhiteColor,
        title: Row(
          children: [
            ImageHelper.loadFromAsset(
              AssetPath.ic_email,
              width: spacing28,
              height: spacing28,
              radius: BorderRadius.circular(radius32),
            ),
            SizedBox(width: spacing8),
            Expanded(
              child: Text(
                'New Email',
                style: AppFontStyles.poppinsTextBold(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: ColorConst.backgroundGrayColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              // Top row with Subject, To, CC (equally spaced)
              Column(
                children: [
                  _buildTextFieldSection("Subject"),
                  _buildTextFieldSection("To"),
                  _buildTextFieldSection("CC"),
                ],
              ),
              SizedBox(height: spacing16),

              // Chat section (fixed height)
              Expanded(
                // Takes remaining space
                child: Container(
                  margin: EdgeInsets.only(bottom: spacing16),
                  decoration: BoxDecoration(
                    color: ColorConst.backgroundWhiteColor,
                    borderRadius: BorderRadius.circular(radius20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(77),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: spacing16),
                          child: TextField(
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: "Compose email...",
                              border: InputBorder.none,
                              hintStyle: AppFontStyles.poppinsRegular(
                                color: ColorConst.textLightGrayColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: spacing16,
                          right: spacing16,
                          bottom: spacing12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              child: ImageHelper.loadFromAsset(
                                AssetPath.icSend,
                                width: spacing16,
                                height: spacing16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldSection(String hintText) {
    return Container(
      margin: EdgeInsets.only(bottom: spacing8),
      padding: EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing8),
      decoration: BoxDecoration(
        color: ColorConst.backgroundWhiteColor,
        borderRadius: BorderRadius.circular(radius20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(77),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        maxLines: null,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: AppFontStyles.poppinsRegular(color: ColorConst.textLightGrayColor),
        ),
      ),
    );
  }
}
