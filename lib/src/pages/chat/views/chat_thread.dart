import 'package:eco_chat_bot/src/constants/enum.dart';
import 'package:eco_chat_bot/src/constants/mock_data.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:eco_chat_bot/src/widgets/animations/typing_indicator.dart';
import 'package:flutter/material.dart';

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({super.key});

  static const String routeName = '/chat-thread';

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  bool isTyping = true;
  int activeAiModelIndex = 0;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Delay fetching arguments to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map?;
      if (args != null) {
        String? botValue = args['botValue'];

        setState(() {
          activeAiModelIndex =
              botValue != null ? MockData.aiModels.indexWhere((element) => element["value"] == botValue) : 0;

          // If not found, fallback to index 0
          if (activeAiModelIndex == -1) {
            activeAiModelIndex = 0;
          }
        });

        print("Initialized activeAiModelIndex = $activeAiModelIndex");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> _messages = [
      {'text': "Hello.👋 I'm your new friend, StarryAI Bot.", 'isBot': true},
    ];

    final args = ModalRoute.of(context)!.settings.arguments as Map;
    String avatarPath = args['avatarPath'] ?? AssetPath.chatThreadAvatarList[0];
    String? title;

    ChatThreadStatus chatStatus = args['chatStatus'];

    if (chatStatus == ChatThreadStatus.existing) {
      title = args['title'];

      _messages.addAll([
        {'text': "Have a healthy meal.", 'isBot': true},
        {'text': "How much price is it?", 'isBot': false},
        {'text': "Only 5\$ for hamburger.", 'isBot': true},
        {'text': 'What is this image?', 'imagePath': AssetPath.imgUploadChat, 'isBot': false},
        {'text': "", 'isBot': true}
      ]);
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: spacing44,
        elevation: 1,
        shadowColor: ColorConst.backgroundLightGrayColor,
        backgroundColor: ColorConst.backgroundWhiteColor,
        title: Row(
          children: [
            ImageHelper.loadFromAsset(
              avatarPath,
              width: spacing36,
              height: spacing36,
              radius: BorderRadius.circular(radius32),
            ),
            SizedBox(width: spacing8),
            Expanded(
              child: Text(
                title ?? 'New chat',
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
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(spacing8),
                child: ListView.builder(
                  reverse: false,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    String messageContent = message['text'];

                    if (messageContent.isEmpty) {
                      return TypingIndicator();
                    }

                    return Align(
                      alignment: message['isBot'] ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.all(spacing8),
                        margin: EdgeInsets.symmetric(vertical: spacing6, horizontal: spacing8),
                        decoration: BoxDecoration(
                          color: message['isBot'] ? ColorConst.textWhiteColor : ColorConst.textHighlightColor,
                          borderRadius: BorderRadius.circular(radius12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (messageContent.isNotEmpty)
                              Text(messageContent,
                                  style: TextStyle(
                                      color: message['isBot'] ? ColorConst.textBlackColor : ColorConst.textWhiteColor)),
                            if (message['imagePath'] != null) ...[
                              SizedBox(
                                height: spacing4,
                              ),
                              ImageHelper.loadFromAsset(
                                message['imagePath'],
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: spacing12, right: spacing12, bottom: spacing8),
              color: Colors.transparent,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: spacing8, vertical: spacing4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius16),
                          color: ColorConst.backgroundWhiteColor,
                        ),
                        child: DropdownButton<String>(
                          underline: SizedBox.shrink(),
                          isDense: true,
                          isExpanded: false,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.black), // Default Flutter icon
                          dropdownColor: ColorConst.backgroundWhiteColor,
                          value: MockData.aiModels[activeAiModelIndex]["value"],
                          items: MockData.aiModels.map<DropdownMenuItem<String>>((model) {
                            return DropdownMenuItem<String>(
                              value: model["value"],
                              child: Row(
                                children: [
                                  ImageHelper.loadFromAsset(
                                    AssetPath.aiModels[model["value"]]!,
                                    width: spacing24,
                                    height: spacing24,
                                  ),
                                  SizedBox(width: spacing8),
                                  Text(
                                    model["display"]!,
                                    style: AppFontStyles.poppinsRegular(),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              activeAiModelIndex = MockData.aiModels.indexWhere((element) => element["value"] == value);
                              print(activeAiModelIndex);
                              print(MockData.aiModels[activeAiModelIndex]["value"]);
                            });
                          },
                        ),
                      ),
                      Row(
                        spacing: spacing16,
                        children: [
                          const Icon(Icons.camera_enhance_outlined, color: ColorConst.backgroundBlackColor),
                          const Icon(Icons.image, color: ColorConst.backgroundBlackColor),
                          const Icon(Icons.history_outlined, color: ColorConst.backgroundBlackColor),
                          const Icon(Icons.add_circle_outline, color: ColorConst.backgroundBlackColor),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: spacing12),
                  Container(
                    margin: EdgeInsets.only(bottom: spacing16),
                    decoration: BoxDecoration(
                      color: ColorConst.backgroundWhiteColor,
                      borderRadius: BorderRadius.circular(radius20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(77), // 0.3 * 255 = 77
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 140,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(radius20),
                                  topRight: Radius.circular(radius20),
                                ),
                                color: Colors.transparent,
                              ),
                              padding:
                                  EdgeInsets.only(left: spacing16, right: spacing16, bottom: spacing16, top: spacing4),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Send message...",
                                  border: InputBorder.none,
                                  hintStyle: AppFontStyles.poppinsRegular(color: ColorConst.textLightGrayColor),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(radius20),
                                bottomRight: Radius.circular(radius20),
                              ),
                              color: Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  spacing: spacing12,
                                  children: [
                                    ImageHelper.loadFromAsset(
                                      AssetPath.icAttachFile,
                                      width: spacing16,
                                      height: spacing16,
                                    ),
                                    ImageHelper.loadFromAsset(
                                      AssetPath.icoPromptLibrary,
                                      width: spacing16,
                                      height: spacing16,
                                    ),
                                  ],
                                ),
                                ImageHelper.loadFromAsset(
                                  AssetPath.icSend,
                                  width: spacing16,
                                  height: spacing16,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
