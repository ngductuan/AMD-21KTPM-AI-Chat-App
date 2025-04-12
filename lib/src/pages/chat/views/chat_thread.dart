import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:eco_chat_bot/src/constants/enum.dart';
import 'package:eco_chat_bot/src/constants/mock_data.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:eco_chat_bot/src/widgets/animations/typing_indicator.dart';
import 'package:eco_chat_bot/src/pages/prompt/prompt_libary.dart';

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
  // Controller cho từng placeholder khi chọn prompt có chứa dấu []
  final Map<String, TextEditingController> _placeholderControllers = {};

  // Mảng chứa danh sách prompt dùng cho gợi ý (lấy từ API)
  final List<Map<String, dynamic>> _prompts = [];
  // Biến hiển thị gợi ý prompt hay không
  bool _showSuggestions = false;

  // Lưu trữ các message chat
  final List<Map<String, dynamic>> _messages = [
    {'text': "Hello.👋 I'm your new friend, StarryAI Bot.", 'isBot': true},
  ];

  @override
  void initState() {
    super.initState();

    // Lấy đối số truyền vào (nếu có) và cập nhật activeAiModelIndex
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as Map?;
      if (args != null) {
        String? botValue = args['botValue'];

        setState(() {
          activeAiModelIndex = botValue != null
              ? MockData.aiModels
                  .indexWhere((element) => element["value"] == botValue)
              : 0;
          if (activeAiModelIndex == -1) {
            activeAiModelIndex = 0;
          }
        });

        print("Initialized activeAiModelIndex = $activeAiModelIndex");
      }
    });

    // Gọi API ban đầu để lấy danh sách prompt (limit 3)
    _fetchInitialPrompts();

    // Lắng nghe thay đổi nội dung của TextField chat
    _controller.addListener(_onChatInputChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _placeholderControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  // Hàm gọi API lấy prompt ban đầu với limit=3
  Future<void> _fetchInitialPrompts() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final authHeader = (accessToken == null || accessToken.isEmpty)
        ? ''
        : 'Bearer $accessToken';
    var headers = {'Authorization': authHeader};
    final url = 'https://api.dev.jarvis.cx/api/v1/prompts?limit=3';

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _prompts.clear();
          _prompts.addAll((data['items'] as List).map((item) {
            return {
              'id': item['_id'],
              'title': item['title'],
              'description': item['description'] ?? '',
              'prompt': item['content'],
              'isFavorite': item['isFavorite'] ?? false,
            };
          }));
        });
      }
    } catch (e) {
      print("Error fetching initial prompts: $e");
    }
  }

  // Hàm gọi API tìm kiếm prompt dựa trên từ khóa (loại bỏ ký tự '/')
  Future<void> _fetchPromptSuggestions(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final authHeader = (accessToken == null || accessToken.isEmpty)
        ? ''
        : 'Bearer $accessToken';
    var headers = {'Authorization': authHeader};
    final url =
        'https://api.dev.jarvis.cx/api/v1/prompts?query=$query&limit=3&offset=0';

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _prompts.clear();
          _prompts.addAll((data['items'] as List).map((item) {
            return {
              'id': item['_id'],
              'title': item['title'],
              'description': item['description'] ?? '',
              'prompt': item['content'],
              'isFavorite': item['isFavorite'] ?? false,
            };
          }));
        });
      }
    } catch (e) {
      print("Error fetching prompt suggestions: $e");
    }
  }

  // Lắng nghe thay đổi trong TextField chat
  void _onChatInputChanged() {
    final text = _controller.text;
    if (text.startsWith('/')) {
      setState(() {
        _showSuggestions = true;
      });
      if (text.length > 1) {
        final key = text.substring(1);
        _fetchPromptSuggestions(key);
      } else {
        // Nếu chỉ có ký tự '/' thì hiển thị prompt ban đầu đã được tải
      }
    } else {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  // Hàm xử lý khi chọn prompt từ danh sách gợi ý (giống hành vi khi chọn từ PromptLibrary)
  void _handlePromptSelection(Map<String, dynamic> result) {
    // Xoá các controller của placeholder cũ (nếu có)
    _placeholderControllers.clear();
    final placeholders = _extractPlaceholders(result['prompt']);

    // Tạo controller cho từng placeholder
    for (final placeholder in placeholders) {
      _placeholderControllers[placeholder] = TextEditingController();
    }

    if (placeholders.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result['title'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
                ...placeholders.map((placeholder) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        placeholder,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _placeholderControllers[placeholder],
                        decoration: InputDecoration(
                          hintText: placeholder,
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
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
                      // Thay thế các placeholder bằng giá trị người dùng nhập
                      final replacements = <String, String>{};
                      _placeholderControllers
                          .forEach((placeholder, controller) {
                        replacements[placeholder] = controller.text.isNotEmpty
                            ? controller.text
                            : placeholder;
                      });
                      final finalPrompt =
                          _replacePlaceholders(result['prompt'], replacements);

                      setState(() {
                        _controller.text = finalPrompt;
                        _showSuggestions = false;
                      });
                      Navigator.pop(context);
                      _sendMessage();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Send',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
      // Nếu không có placeholder, gán trực tiếp prompt và ẩn danh sách gợi ý
      setState(() {
        _controller.text = result['prompt'];
        _showSuggestions = false;
      });
    }
  }

  // Hàm trích xuất placeholder (chuỗi nằm trong dấu [ ])
  List<String> _extractPlaceholders(String promptText) {
    final RegExp regex = RegExp(r'\[(.*?)\]');
    final matches = regex.allMatches(promptText);
    return matches.map((match) => match.group(1)!).toList();
  }

  // Hàm thay thế placeholder bằng giá trị người dùng nhập
  String _replacePlaceholders(
      String promptText, Map<String, String> replacements) {
    String result = promptText;
    replacements.forEach((placeholder, value) {
      result = result.replaceAll('[$placeholder]', value);
    });
    return result;
  }

  // Hàm gửi message
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
    String avatarPath = args['avatarPath'] ?? AssetPath.chatThreadAvatarList[0];
    String? title;

    ChatThreadStatus chatStatus = args['chatStatus'];

    if (chatStatus == ChatThreadStatus.existing) {
      title = args['title'];

      _messages.addAll([
        {'text': "Have a healthy meal.", 'isBot': true},
        {'text': "How much price is it?", 'isBot': false},
        {'text': "Only 5\$ for hamburger.", 'isBot': true},
        {
          'text': 'What is this image?',
          'imagePath': AssetPath.imgUploadChat,
          'isBot': false
        },
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
            // Hiển thị danh sách gợi ý prompt nếu người dùng gõ '/' ở TextField
            if (_showSuggestions && _controller.text.startsWith('/'))
              Container(
                color: Colors.white,
                // Có thể tuỳ chỉnh chiều cao phù hợp
                height: 150,
                child: ListView.builder(
                  itemCount: _prompts.length,
                  itemBuilder: (context, index) {
                    final prompt = _prompts[index];
                    return ListTile(
                      title: Text(prompt['title'] ?? ''),
                      subtitle: Text(prompt['description'] ?? ''),
                      onTap: () => _handlePromptSelection(prompt),
                    );
                  },
                ),
              ),
            // Phần nhập tin nhắn
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
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                          ),
                          dropdownColor: ColorConst.backgroundWhiteColor,
                          value: MockData.aiModels[activeAiModelIndex]["value"],
                          items: MockData.aiModels
                              .map<DropdownMenuItem<String>>((model) {
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
                              activeAiModelIndex = MockData.aiModels.indexWhere(
                                  (element) => element["value"] == value);
                              print(activeAiModelIndex);
                              print(MockData.aiModels[activeAiModelIndex]
                                  ["value"]);
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
                              padding: EdgeInsets.only(
                                  left: spacing16,
                                  right: spacing16,
                                  top: spacing12),
                              child: TextField(
                                controller: _controller,
                                maxLines: null,
                                decoration: InputDecoration(
                                  hintText: "Ask me anything...",
                                  border: InputBorder.none,
                                  hintStyle: AppFontStyles.poppinsRegular(
                                      color: ColorConst.textLightGrayColor),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: spacing16,
                                right: spacing16,
                                bottom: spacing12),
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

                                          var tween = Tween(
                                                  begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));

                                          return SlideTransition(
                                            position: animation.drive(tween),
                                            child: child,
                                          );
                                        },
                                      ),
                                    );

                                    if (result != null) {
                                      _placeholderControllers.clear();
                                      final placeholders = _extractPlaceholders(
                                          result['prompt']);
                                      for (final placeholder in placeholders) {
                                        _placeholderControllers[placeholder] =
                                            TextEditingController();
                                      }
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
                                                                  : placeholder;
                                                        });

                                                        final finalPrompt =
                                                            _replacePlaceholders(
                                                                result[
                                                                    'prompt'],
                                                                replacements);

                                                        setState(() {
                                                          _controller.text =
                                                              finalPrompt;
                                                        });
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
                                        setState(() {
                                          _controller.text = result['prompt'];
                                        });
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
