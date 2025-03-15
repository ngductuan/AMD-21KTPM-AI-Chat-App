import 'package:eco_chat_bot/src/constants/enum.dart';
import 'package:eco_chat_bot/src/pages/chat/views/chat_thread.dart';
import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/mock_data.dart';
import '../../../constants/styles.dart';
import '../widgets/ai_bot_item.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  static const String routeName = '/explore';

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  bool _isTextFieldFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isTextFieldFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: ColorConst.backgroundLightGrayColor,
        backgroundColor: ColorConst.backgroundWhiteColor,
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: spacing8, horizontal: spacing8),
          decoration: BoxDecoration(
            color: ColorConst.backgroundLightGrayColor,
            borderRadius: BorderRadius.circular(radius24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: spacing4),
              Expanded(
                child: Center(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: "Search for bots",
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: padding8),
                      border: InputBorder.none,
                      hintStyle: AppFontStyles.poppinsRegular(color: ColorConst.textLightGrayColor),
                    ),
                    onEditingComplete: () {
                      _focusNode.unfocus();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: (_isTextFieldFocused || _controller.text.isNotEmpty)
            ? [
                IconButton(
                  icon: Icon(Icons.clear, color: ColorConst.textGrayColor),
                  onPressed: () {
                    _focusNode.unfocus();
                    _controller.clear();
                  },
                ),
              ]
            : null,
      ),
      body: Container(
        color: ColorConst.backgroundGrayColor,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: padding8),
          itemCount: MockData.aiModels.length,
          itemBuilder: (context, index) {
            Map<String, String> botData = MockData.aiModels[index];

            return AiBotItem(
              botData: botData,
              onTap: () {
                Navigator.of(context).pushNamed(
                  ChatThreadScreen.routeName,
                  arguments: {
                    ...botData,
                    'chatStatus': ChatThreadStatus.new_,
                    'botValue': botData['value'],
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
