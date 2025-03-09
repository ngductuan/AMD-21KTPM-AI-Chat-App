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

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'text': "Hello.👋 I'm your new friend, StarryAI Bot.", 'isBot': true},
    {'text': "Have a healthy meal.", 'isBot': true},
    {'text': "How much price is it?", 'isBot': false},
    {'text': "Only 5\$ for hamburger.", 'isBot': true},
    {'text': "", 'isBot': true},
  ];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({'text': _controller.text, 'isBot': false});
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    String title = args['title'];
    String avatarPath = args['avatarPath'];

    return Scaffold(
      appBar: AppBar(
        leadingWidth: spacing48,
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
                title,
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
        padding: EdgeInsets.all(spacing8),
        color: ColorConst.backgroundGrayColor,
        child: Column(
          children: [
            Expanded(
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
                      child: Text(
                        message['text'],
                        style:
                            TextStyle(color: message['isBot'] ? ColorConst.textBlackColor : ColorConst.textWhiteColor),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: spacing8, right: spacing8, bottom: spacing16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Send a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
