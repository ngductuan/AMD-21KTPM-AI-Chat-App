import 'package:eco_chat_bot/src/constants/asset_path.dart';
import 'package:eco_chat_bot/src/constants/colors.dart';
import 'package:eco_chat_bot/src/constants/dimensions.dart';
import 'package:eco_chat_bot/src/constants/enum.dart';
import 'package:eco_chat_bot/src/constants/font_styles.dart';
import 'package:eco_chat_bot/src/constants/services/bot.service.dart';
import 'package:eco_chat_bot/src/constants/services/chat.service.dart';
import 'package:eco_chat_bot/src/emails/pages/email_thread.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:eco_chat_bot/src/helpers/utility_helper.dart';
import 'package:eco_chat_bot/src/pages/chat/views/chat_thread.dart';
import 'package:eco_chat_bot/src/pages/chat/widgets/manage_bot_modal.dart';
import 'package:eco_chat_bot/src/widgets/animations/animation_modal.dart';
import 'package:eco_chat_bot/src/widgets/loading_indicator.dart';
import 'package:eco_chat_bot/src/widgets/no_data_gadget.dart';
import 'package:eco_chat_bot/src/widgets/toast/app_toast.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  static const String routeName = '/chat-list';

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> chatData = [];

  bool isLoading = false;

  Future<void> getChatHistory() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Simulate a network call
      final response = await ChatServiceApi.getChatHistory();

      final data = response['items'] as List<dynamic>;

      // Update the chat data with the response
      setState(() {
        chatData = data.map((e) {
          return {
            'id': e['id'],
            'title': e['title'],
            'createdAt': e['createdAt'],
          };
        }).toList();
      });

      // Update the list count to simulate data retrieval
      setState(() {});
    } catch (e) {
      print('Error fetching chat history: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> createBotData(dynamic body, Function endCallback) async {
    try {
      await BotServiceApi.createBotResponse(body);

      AppToast(
        context: context,
        duration: Duration(seconds: 1),
        message: 'Bot created successfully!',
        mode: AppToastMode.confirm,
      ).show(context);
    } catch (e) {
      print('Error creating bot: $e');
      AppToast(
        context: context,
        duration: Duration(seconds: 1),
        message: 'Error creating bot',
        mode: AppToastMode.error,
      ).show(context);
    } finally {
      await Future.delayed(const Duration(milliseconds: 1000));
      endCallback();
    }
  }

  @override
  void initState() {
    super.initState();
    getChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All chat',
          style: AppFontStyles.poppinsTitleBold(fontSize: fontSize20),
        ),
        elevation: 1,
        shadowColor: ColorConst.backgroundLightGrayColor,
        backgroundColor: ColorConst.backgroundWhiteColor,
        centerTitle: true,
        actions: [
          _buildPopupMenu(),
        ],
      ),
      backgroundColor: ColorConst.backgroundGrayColor,
      body: isLoading ? buildLoadingIndicator(hasMore: isLoading) : (chatData.isEmpty
          ? NoDataGadget()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: padding8),
              itemCount: chatData.length,
              itemBuilder: (context, index) {
                // Avatar path
                String avatarPath = AssetPath.chatThreadAvatarList[index % AssetPath.chatThreadAvatarList.length];

                return ListTile(
                  leading: ImageHelper.loadFromAsset(
                    avatarPath,
                    width: spacing48,
                    height: spacing48,
                    radius: BorderRadius.circular(radius32),
                  ),
                  title: Text(
                    chatData[index]["title"],
                    style: AppFontStyles.poppinsTextBold(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    UtilityHelper.formatTimeAgo(chatData[index]["createdAt"]),
                    style: AppFontStyles.poppinsRegular(color: ColorConst.textGrayColor, fontSize: fontSize12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    // Handle chat item tap
                    Navigator.of(context).pushNamed(
                      ChatThreadScreen.routeName,
                      arguments: {
                        ...chatData[index],
                        'avatarPath': avatarPath,
                        'chatStatus': ChatThreadStatus.existing,
                      },
                    );
                  },
                );
              },
              separatorBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: spacing16),
                  child: const Divider(
                    height: 1,
                    thickness: 1,
                    color: ColorConst.backgroundLightGrayColor,
                  ),
                );
              },
            )),
    );
  }

  // Menu Popup
  Widget _buildPopupMenu() {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: ColorConst.backgroundWhiteColor,
        ),
      ),
      child: PopupMenuButton<int>(
        icon: const Icon(Icons.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius12),
        ),
        offset: const Offset(0, spacing48),
        onSelected: (value) {
          if (value == 1) {
            Navigator.of(context)
                .pushNamed(ChatThreadScreen.routeName, arguments: {'chatStatus': ChatThreadStatus.new_});
          } else if (value == 2) {
            Navigator.of(context).push(AnimationModal.fadeInModal(ManageBotModal(
              endCallback: createBotData,
              activeButtonText: 'Create',
            )));
          } else if (value == 3) {
            Navigator.of(context).pushNamed(
              EmailThreadScreen.routeName,
            );
          }
        },
        itemBuilder: (context) => [
          _buildPopupItem(1, Icons.chat_bubble_outline, "New Chat"),
          _buildPopupItem(2, Icons.smart_toy_outlined, "Create Bot"),
          _buildPopupItem(3, Icons.email_outlined, "New email"),
        ],
      ),
    );
  }

  // Build Menu Items
  PopupMenuItem<int> _buildPopupItem(int value, IconData icon, String text) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: spacing24, color: Colors.black),
          const SizedBox(width: spacing12),
          Text(text, style: AppFontStyles.poppinsRegular(fontSize: fontSize16)),
        ],
      ),
    );
  }
}
