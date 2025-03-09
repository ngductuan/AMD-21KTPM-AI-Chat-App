import 'package:another_flushbar/flushbar.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:eco_chat_bot/src/widgets/animations/typing_indicator.dart';
import 'package:eco_chat_bot/src/pages/prompt/prompt_libary.dart';
import 'package:flutter/material.dart';

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({super.key});

  static const String routeName = '/chat-thread';

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  bool isTyping = true;
  int activeAiModel = 0;

  final TextEditingController _controller = TextEditingController();
  final Map<String, TextEditingController> _placeholderControllers = {};

  final List<Map<String, dynamic>> _messages = [
    {'text': "Hello.👋 I'm your new friend, StarryAI Bot.", 'isBot': true},
    {'text': "Have a healthy meal.", 'isBot': true},
    {'text': "How much price is it?", 'isBot': false},
    {'text': "Only 5\$ for hamburger.", 'isBot': true},
    {'text': "", 'isBot': true},
  ];

  List<Map<String, String>> aiModels = [
    {"value": "gpt4o_mini", "display": "GPT-4o mini"},
    {"value": "gpt4o", "display": "GPT-4o"},
    {"value": "gemini_15_flash", "display": "Gemini 1.5 Flash"},
    {"value": "gemini_15_pro", "display": "Gemini 1.5 Pro"},
    {"value": "claude_3_haiku", "display": "Claude 3 Haiku"},
    {"value": "claude_35_sonet", "display": "Claude 3.5 Sonet"},
    {"value": "deepseek_chat", "display": "Deepseek Chat"},
  ];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({'text': _controller.text, 'isBot': false});
        _controller.clear();
      });
    }
  }

  // Extract placeholders from prompt text (text in square brackets)
  List<String> _extractPlaceholders(String promptText) {
    final RegExp regex = RegExp(r'\[(.*?)\]');
    final matches = regex.allMatches(promptText);
    return matches.map((match) => match.group(1)!).toList();
  }

  // Replace placeholders with user input
  String _replacePlaceholders(
      String promptText, Map<String, String> replacements) {
    String result = promptText;
    replacements.forEach((placeholder, value) {
      result = result.replaceAll('[$placeholder]', value);
    });
    return result;
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
                      alignment: message['isBot']
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.all(spacing8),
                        margin: EdgeInsets.symmetric(
                            vertical: spacing6, horizontal: spacing8),
                        decoration: BoxDecoration(
                          color: message['isBot']
                              ? ColorConst.textWhiteColor
                              : ColorConst.textHighlightColor,
                          borderRadius: BorderRadius.circular(radius12),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(
                              color: message['isBot']
                                  ? ColorConst.textBlackColor
                                  : ColorConst.textWhiteColor),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.transparent,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: spacing8, vertical: spacing4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius16),
                          color: ColorConst.backgroundWhiteColor,
                        ),
                        child: DropdownButton<String>(
                          underline: SizedBox.shrink(),
                          isDense: true,
                          isExpanded: false,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.black),
                          dropdownColor: ColorConst.backgroundWhiteColor,
                          value: aiModels[activeAiModel]["value"],
                          items:
                              aiModels.map<DropdownMenuItem<String>>((model) {
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
                              activeAiModel = aiModels.indexWhere(
                                  (element) => element["value"] == value);
                            });
                          },
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.camera_enhance_outlined,
                              color: ColorConst.backgroundBlackColor),
                          SizedBox(width: spacing16),
                          const Icon(Icons.image,
                              color: ColorConst.backgroundBlackColor),
                          SizedBox(width: spacing16),
                          const Icon(Icons.history_outlined,
                              color: ColorConst.backgroundBlackColor),
                          SizedBox(width: spacing16),
                          const Icon(Icons.add_circle_outline,
                              color: ColorConst.backgroundBlackColor),
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
                          color: Colors.grey.withAlpha(77),
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
                              padding: EdgeInsets.all(spacing16),
                              child: TextField(
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: "Send message...",
                                  border: InputBorder.none,
                                  hintStyle: AppFontStyles.poppinsRegular(
                                      color: ColorConst.textLightGrayColor),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: spacing16, vertical: spacing12),
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
                                GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration:
                                            const Duration(milliseconds: 500),
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            const PromptLibrary(),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOut;

                                          var tween =
                                              Tween(begin: begin, end: end)
                                                  .chain(
                                            CurveTween(curve: curve),
                                          );

                                          return SlideTransition(
                                            position: animation.drive(tween),
                                            child: child,
                                          );
                                        },
                                      ),
                                    );

                                    // Handle the selected prompt
                                    if (result != null) {
                                      // Clear any previous placeholder controllers
                                      _placeholderControllers.clear();

                                      // Extract placeholders from the prompt
                                      final placeholders = _extractPlaceholders(
                                          result['prompt']);

                                      // Create controllers for each placeholder
                                      for (final placeholder in placeholders) {
                                        _placeholderControllers[placeholder] =
                                            TextEditingController();
                                      }

                                      // Show the prompt UI
                                      if (placeholders.isNotEmpty) {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20)),
                                          ),
                                          builder: (context) => Padding(
                                            padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom,
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(16),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    result['title'],
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    result['prompt'],
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  SizedBox(height: 16),
                                                  ...placeholders
                                                      .map((placeholder) {
                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          placeholder,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        SizedBox(height: 8),
                                                        TextField(
                                                          controller:
                                                              _placeholderControllers[
                                                                  placeholder],
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                placeholder,
                                                            filled: true,
                                                            fillColor: Colors
                                                                .grey[100],
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              borderSide:
                                                                  BorderSide
                                                                      .none,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 16),
                                                      ],
                                                    );
                                                  }).toList(),
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        // Replace placeholders with user input
                                                        final replacements =
                                                            <String, String>{};
                                                        _placeholderControllers
                                                            .forEach(
                                                                (placeholder,
                                                                    controller) {
                                                          replacements[
                                                                  placeholder] =
                                                              controller.text
                                                                      .isNotEmpty
                                                                  ? controller
                                                                      .text
                                                                  : placeholder; // Use placeholder as fallback
                                                        });

                                                        final finalPrompt =
                                                            _replacePlaceholders(
                                                                result[
                                                                    'prompt'],
                                                                replacements);

                                                        // Set the message and send
                                                        _controller.text =
                                                            finalPrompt;
                                                        Navigator.pop(context);
                                                        _sendMessage();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 16),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Send',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        // No placeholders, just set the prompt directly
                                        _controller.text = result['prompt'];
                                      }
                                    }
                                  },
                                  child: InkWell(
                                    borderRadius:
                                        BorderRadius.circular(spacing10),
                                    splashColor: Colors.grey.withOpacity(0.2),
                                    child: ImageHelper.loadFromAsset(
                                      AssetPath.icoPromptLibrary,
                                      width: spacing16,
                                      height: spacing16,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _sendMessage,
                                  child: ImageHelper.loadFromAsset(
                                    AssetPath.icSend,
                                    width: spacing16,
                                    height: spacing16,
                                  ),
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
