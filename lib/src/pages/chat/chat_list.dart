import 'package:eco_chat_bot/src/constants/asset_path.dart';
import 'package:eco_chat_bot/src/constants/colors.dart';
import 'package:eco_chat_bot/src/constants/dimensions.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  static const String routeName = '/chat-list';

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All chat',
          style: GoogleFonts.poppins(
            fontSize: fontSize20,
            fontWeight: FontWeight.bold,
            color: ColorConst.textBlackColor,
          ),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: spacing20),
          child: ImageHelper.loadFromAsset(
            AssetPath.noDataIcon,
            width: 140,
            height: 160,
          ),
        ),
      ),
    );
  }
}
