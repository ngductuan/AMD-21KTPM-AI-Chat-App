import 'package:eco_chat_bot/src/constants/asset_path.dart';
import 'package:eco_chat_bot/src/constants/colors.dart';
import 'package:eco_chat_bot/src/constants/dimensions.dart';
import 'package:eco_chat_bot/src/constants/font_styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:eco_chat_bot/src/widgets/no_data_gadget.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  static const String routeName = '/chat-list';

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int listCount = 1;

  // Dummy chat data
  final List<Map<String, String>> chatData = [
    {"title": "Give me some example about Docker...", "subtitle": "Dr. Sage answers uni med questions in a..."},
    {"title": "Ask for flutter", "subtitle": "Hello! I can provide assistance with your..."},
    {"title": "How to code fast for homework...", "subtitle": "Generate photo-realistic pictures with Re..."},
    {"title": "Why does it use scss instead of css?", "subtitle": "I will help you learn anything you need h..."},
    {"title": "Translate english to vietnamese", "subtitle": "Describe the image you want to create."},
    {"title": "Generate for me a 2D picture", "subtitle": "This bot generates realistic, stock photo..."},
    {"title": "Propose for me a statement", "subtitle": "Expert in Psychology"},
    {"title": "What pharmacy have been closed near...", "subtitle": "Dr. Sage answers uni med questions in a..."},
    {"title": "How much cost is it for water?", "subtitle": "Your very own therapist with relationship..."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All chat',
          style: AppFontStyles.poppinsBold(fontSize: fontSize20),
        ),
        elevation: 1,
        shadowColor: ColorConst.backgroundLightGrayColor,
        backgroundColor: ColorConst.backgroundWhiteColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline), // Example: Search icon
            onPressed: () {
              print("Search button tapped!");
            },
          ),
        ],
      ),
      backgroundColor: ColorConst.backgroundGrayColor,
      body: listCount == 0
          ? NoDataGadget()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: chatData.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: ImageHelper.loadFromAsset(
                    AssetPath.chatThreadAvatarList[index % AssetPath.chatThreadAvatarList.length],
                    width: spacing48,
                    height: spacing48,
                    radius: BorderRadius.circular(50),
                  ),
                  title: Text(
                    chatData[index]["title"]!,
                    style: AppFontStyles.poppinsBold(fontSize: fontSize16, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    chatData[index]["subtitle"]!,
                    style: AppFontStyles.poppinsRegular(color: ColorConst.textGrayColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Handle chat item tap
                  },
                );
              },
            ),
    );
  }
}
