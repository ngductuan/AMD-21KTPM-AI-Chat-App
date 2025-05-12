import 'dart:convert';
import 'dart:io';
import 'package:eco_chat_bot/src/constants/services/bot.service.dart';
import 'package:eco_chat_bot/src/constants/services/chat.service.dart';
import 'package:eco_chat_bot/src/pages/chat/widgets/chat_line_item.dart';
import 'package:eco_chat_bot/src/pages/chat/widgets/upload_image_widget.dart';
import 'package:eco_chat_bot/src/widgets/toast/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:eco_chat_bot/src/constants/enum.dart';
import 'package:eco_chat_bot/src/constants/mock_data.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:eco_chat_bot/src/widgets/animations/typing_indicator.dart';
import 'package:eco_chat_bot/src/pages/prompt/prompt_libary.dart';

class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({
    super.key,
    this.conversationId = "",
    // this.chatIndex = 0,
    this.title = "",
    this.avatarPath = '',
    this.chatStatus = ChatThreadStatus.new_,
    this.botId = "",
    this.isVisibleGadget = true,
  });

  static const String routeName = '/chat-thread';

  final String conversationId;
  // final int chatIndex;
  final String title;
  final String avatarPath;
  final ChatThreadStatus chatStatus;
  final String botId;
  final bool isVisibleGadget;

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  // List<File> _imageFiles = [];
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool isTyping = true;
  int activeAiModelIndex = 0;
  String activeAiModelId = "";

  // For preview bot
  bool isVisibleGadget = true;

  final TextEditingController _controller = TextEditingController();
  // Controller cho từng placeholder khi chọn prompt có chứa dấu []
  final Map<String, TextEditingController> _placeholderControllers = {};

  // Mảng chứa danh sách prompt dùng cho gợi ý (lấy từ API)
  final List<Map<String, dynamic>> _prompts = [];
  // Biến hiển thị gợi ý prompt hay không
  bool _showSuggestions = false;

  bool _isModelsLoading = false;
  final List<Map<String, String>> _aiModels = [];
  Map<String, String> selectedBotModel = {};

  // Lưu trữ các message chat
  final List<Map<String, dynamic>> _messages = [];

  bool isFirstLoading = true;

  @override
  void initState() {
    super.initState();

    if (isVisibleGadget) {
      fetchAiModels();
    }

    if (widget.chatStatus == ChatThreadStatus.existing) {
      _getChatHistoryById(widget.conversationId);
    }

    // Gọi API ban đầu để lấy danh sách prompt (limit 3)
    _fetchInitialPrompts();

    // Lắng nghe thay đổi nội dung của TextField chat
    _controller.addListener(_onChatInputChanged);
  }

  Future<void> _getImage(ImageSource source) async {
    // Check and request permission if needed
    if (source == ImageSource.camera) {
      await Permission.camera.request();
    } else {
      await Permission.photos.request();
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Image picker error: $e");
    }
  }

  Future<void> _getChatHistoryById(String conversationId) async {
    try {
      final response = await ChatServiceApi.getChatHistoryById(conversationId);

      final data = response['items'] as List<dynamic>;

      // Update the chat data with the response
      setState(() {
        _messages.addAll(data.map((e) {
          return {
            'query': e['query'] ?? '',
            'answer': e['answer'] ?? '',
            'createdAt': e['createdAt'] ?? '',
          };
        }).toList());
      });
    } catch (e) {
      // Handle the exception
      print('Exception occurred while fetching chat history: $e');
    } finally {
      setState(() {
        isFirstLoading = false;
      });
    }
  }

  Future<void> fetchAiModels({String? searchQuery, bool reset = false}) async {
    if (_isModelsLoading) return;

    setState(() {
      _isModelsLoading = true;
    });

    try {
      dynamic response = await BotServiceApi.getAllBots(search: searchQuery, offset: 0, limit: 50);

      final Map<String, dynamic> jsonResponse = json.decode(response);

      if (jsonResponse.containsKey('data')) {
        final List<dynamic> dataList = jsonResponse['data'];

        final List<Map<String, String>> newItems = dataList.where((item) => item is Map<String, dynamic>).map((item) {
          // Convert each dynamic value to String
          final Map<String, dynamic> dynamicMap = item as Map<String, dynamic>;
          return dynamicMap.map((key, value) => MapEntry(key, value?.toString() ?? ''));
        }).toList();

        setState(() {
          _aiModels.addAll(newItems);
          activeAiModelId = _aiModels[activeAiModelIndex]["id"]!;
          // print('AI model: ${_aiModels[activeAiModelIndex]}');
        });
      }
    } catch (e) {
      // Handle the exception
      print('Exception occurred while fetching AI models: $e');
    } finally {
      setState(() {
        _isModelsLoading = false;
      });
    }
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
    final authHeader = (accessToken == null || accessToken.isEmpty) ? '' : 'Bearer $accessToken';
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
    final authHeader = (accessToken == null || accessToken.isEmpty) ? '' : 'Bearer $accessToken';
    var headers = {'Authorization': authHeader};
    final url = 'https://api.dev.jarvis.cx/api/v1/prompts?query=$query&limit=3&offset=0';

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
        builder: (context) {
          // AnimatedPadding giúp smooth khi keyboard show/hide
          return AnimatedPadding(
            duration: const Duration(milliseconds: 100),
            padding: MediaQuery.of(context).viewInsets,
            child: Wrap(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // co nhỏ lại vừa nội dung
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result['title'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result['prompt'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Thay vì để Column “cứng” thì gom list vào SingleChildScrollView
                      SingleChildScrollView(
                        child: Column(
                          children: placeholders.map((placeholder) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: TextField(
                                controller: _placeholderControllers[placeholder],
                                decoration: InputDecoration(
                                  labelText: placeholder,
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final replacements = <String, String>{};
                            _placeholderControllers.forEach((placeholder, controller) {
                              replacements[placeholder] = controller.text.isNotEmpty ? controller.text : placeholder;
                            });

                            final finalPrompt = _replacePlaceholders(result['prompt'], replacements);

                            setState(() {
                              _controller.text = finalPrompt;
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
                          child: const Text(
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
              ],
            ),
          );
        },
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
  String _replacePlaceholders(String promptText, Map<String, String> replacements) {
    String result = promptText;
    replacements.forEach((placeholder, value) {
      result = result.replaceAll('[$placeholder]', value);
    });
    return result;
  }

  // Hàm gửi message
  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final String content = _controller.text;

      try {
        // Update UI with user message
        setState(() {
          _messages.addAll([
            {'query': content, 'answer': '', 'imagePath': _imageFile},
          ]);
          _controller.clear();
        });

        // Remove temp image file
        _imageFile = null;

        final List<Map<String, dynamic>> history = [];
        for (final message in _messages) {
          history.add({
            "role": "user",
            'content': message['query'],
            'assistant': BotServiceApi.assistant,
          });

          history.add({
            "role": "model",
            'content': message['answer'],
            'assistant': BotServiceApi.assistant,
          });
        }

        // Send message to server and wait for response
        final response = await ChatServiceApi.createChatWithBot(widget.conversationId, content, history);

        final data = jsonDecode(response) as Map<String, dynamic>;

        setState(() {
          _messages[_messages.length - 1]['answer'] = data['message'];
        });
      } catch (e) {
        // Handle any errors that occur during the API call
        print("Error sending message: $e");

        setState(() {
          _messages.removeLast();
        });

        AppToast(
          context: context,
          duration: Duration(seconds: 1),
          message: 'Error sending message: $e',
          mode: AppToastMode.error,
        ).show(context);
      }
    } else {
      print("Message is empty");
    }
  }

  @override
  Widget build(BuildContext context) {
    String avatarPath = widget.avatarPath.isEmpty ? AssetPath.chatThreadAvatarList[0] : widget.avatarPath;
    String title = widget.title.isEmpty ? "New chat" : widget.title;

    ChatThreadStatus chatStatus = widget.chatStatus;

    if (chatStatus == ChatThreadStatus.existing) {
    } else if (chatStatus == ChatThreadStatus.newExplore && isFirstLoading) {
      setState(() {
        activeAiModelId = widget.botId;
        isVisibleGadget = widget.isVisibleGadget;
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                padding: EdgeInsets.all(spacing4),
                child: ListView.builder(
                  reverse: false,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];

                    return Column(
                      children: [
                        // isModel = false
                        ChatLineItem.build(context, false, message, activeAiModelId, _buildModelLabel,
                            chatStatus: chatStatus),
                        // isModel = true
                        message['answer'].isEmpty
                            ? Align(alignment: Alignment.centerLeft, child: TypingIndicator())
                            : ChatLineItem.build(context, true, message, activeAiModelId, _buildModelLabel,
                                chatStatus: chatStatus),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Hiển thị danh sách gợi ý prompt nếu người dùng gõ '/' ở TextField
            if (_showSuggestions && _controller.text.startsWith('/'))
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => SizeTransition(
                    axisAlignment: -1.0,
                    sizeFactor: animation,
                    child: child,
                  ),
                  child: Container(
                    key: const ValueKey('prompt_suggestions'),
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Scrollbar(
                      radius: const Radius.circular(12),
                      thickness: 4,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: _prompts.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final prompt = _prompts[index];
                          return InkWell(
                            onTap: () => _handlePromptSelection(prompt),
                            borderRadius: BorderRadius.circular(12),
                            splashColor: Colors.grey.withOpacity(0.2),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prompt['title'] ?? '',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  if ((prompt['description'] ?? '').isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        prompt['description']!,
                                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

            // Phần nhập tin nhắn
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.transparent,
              child: Column(
                children: [
                  isVisibleGadget
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Dropdown chọn AI model
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
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black,
                                ),
                                value: activeAiModelId.isNotEmpty
                                    ? activeAiModelId
                                    : (_aiModels.isNotEmpty ? _aiModels[activeAiModelIndex]["id"] : null),
                                items: _aiModels.map<DropdownMenuItem<String>>((model) {
                                  return DropdownMenuItem<String>(
                                    value: model["id"],
                                    child: _buildModelLabel(model['id']!),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    isFirstLoading = false;

                                    activeAiModelIndex = _aiModels.indexWhere((element) => element["id"] == value);
                                    activeAiModelId = value!;
                                    // print(activeAiModelIndex);
                                    print(activeAiModelId);
                                  });
                                },
                              ),
                            ),
                            // Các icon chức năng
                            Row(
                              children: [
                                GestureDetector(
                                  child: const Icon(Icons.camera_alt, color: ColorConst.backgroundBlackColor),
                                  onTap: () => _getImage(ImageSource.camera),
                                ),
                                SizedBox(width: spacing24),
                                GestureDetector(
                                  child: const Icon(Icons.image, color: ColorConst.backgroundBlackColor),
                                  onTap: () => _getImage(ImageSource.gallery),
                                ),
                                SizedBox(width: spacing8),
                              ],
                            )
                          ],
                        )
                      : SizedBox.shrink(),
                  SizedBox(height: spacing12),

                  // Chat section
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
                      height: _imageFile != null ? 190 : 150,
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
                              padding: EdgeInsets.only(left: spacing16, right: spacing16, top: spacing12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _imageFile != null
                                      ? Align(
                                          alignment: Alignment.centerLeft,
                                          child: UploadImageWidget.buildUploadImageWidget(
                                            context: context,
                                            imageFile: _imageFile!,
                                            onTap: () {
                                              setState(() {
                                                _imageFile = null;
                                              });
                                            },
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                  Expanded(
                                    child: TextField(
                                      controller: _controller,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                        hintText: "Ask me anything...",
                                        border: InputBorder.none,
                                        hintStyle: AppFontStyles.poppinsRegular(color: ColorConst.textLightGrayColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: spacing16, right: spacing16, bottom: spacing12),
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
                                        transitionDuration: const Duration(milliseconds: 500),
                                        pageBuilder: (context, animation, secondaryAnimation) => const PromptLibrary(),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOut;

                                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                          return SlideTransition(
                                            position: animation.drive(tween),
                                            child: child,
                                          );
                                        },
                                      ),
                                    );

                                    if (result != null) {
                                      _placeholderControllers.clear();
                                      final placeholders = _extractPlaceholders(result['prompt']);
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
                                          builder: (context) {
                                            // AnimatedPadding giúp smooth khi keyboard show/hide
                                            return AnimatedPadding(
                                              duration: const Duration(milliseconds: 100),
                                              padding: MediaQuery.of(context).viewInsets,
                                              child: Wrap(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(16),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min, // co nhỏ lại vừa nội dung
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          result['title'],
                                                          style: const TextStyle(
                                                            fontSize: 24,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Text(
                                                          result['prompt'],
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.grey[600],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 16),

                                                        // Thay vì để Column “cứng” thì gom list vào SingleChildScrollView
                                                        SingleChildScrollView(
                                                          child: Column(
                                                            children: placeholders.map((placeholder) {
                                                              return Padding(
                                                                padding: const EdgeInsets.only(bottom: 16),
                                                                child: TextField(
                                                                  controller: _placeholderControllers[placeholder],
                                                                  decoration: InputDecoration(
                                                                    labelText: placeholder,
                                                                    filled: true,
                                                                    fillColor: Colors.grey[100],
                                                                    border: OutlineInputBorder(
                                                                      borderRadius: BorderRadius.circular(12),
                                                                      borderSide: BorderSide.none,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        ),

                                                        SizedBox(
                                                          width: double.infinity,
                                                          child: ElevatedButton(
                                                            onPressed: () {
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
                                                            child: const Text(
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
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        setState(() {
                                          _controller.text = result['prompt'];
                                        });
                                      }
                                    }
                                  },
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(spacing10),
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

  Widget _buildModelLabel(String modelId, {double iconSize = spacing24, bool isDefaultMessage = false}) {
    Map<String, String> botModel = _aiModels.firstWhere((model) => model["id"] == modelId,
        orElse: () => {
              "assistantName": "Jarvis AI",
              'id': "jarvis_ai",
            });

    int indexOfItem = _aiModels.indexOf(botModel);

    Map<String, String> modelAvatar = MockData.aiModels[indexOfItem % MockData.aiModels.length];

    return Row(children: [
      ImageHelper.loadFromAsset(
        botModel["id"] == "jarvis_ai"
            ? AssetPath.aiJarvisModel
            : (AssetPath.aiModels[modelAvatar["value"]] ?? AssetPath.icoDefaultImage),
        width: iconSize,
        height: iconSize,
      ),
      SizedBox(width: spacing8),
      Text(
        botModel["assistantName"]!,
        style: AppFontStyles.poppinsRegular(),
      )
    ]);
  }
}
