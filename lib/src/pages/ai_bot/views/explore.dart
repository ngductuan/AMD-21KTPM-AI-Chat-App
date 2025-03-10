import 'package:eco_chat_bot/src/constants/enum.dart';
import 'package:eco_chat_bot/src/constants/mock_data.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:eco_chat_bot/src/pages/chat/views/chat_thread.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../constants/styles.dart';

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
                ImageHelper.loadFromAsset(AssetPath.searchBeforeNavIcon,
                    width: spacing20, height: spacing20, tintColor: ColorConst.textGrayColor),
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
                  // Avatar path
                  String avatarPath =
                      AssetPath.aiModels[MockData.aiModels[index]['value']] ?? AssetPath.icoDefaultImage;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: padding16, vertical: padding4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius12),
                      color: ColorConst.backgroundWhiteColor,
                      boxShadow: [
                        BoxShadow(
                          color: ColorConst.textHighlightColor.withAlpha(40),
                          blurRadius: 2,
                          offset: const Offset(0.5, 0.5),
                        ),
                      ],
                    ),
                    child: ListTile(
                        leading: ImageHelper.loadFromAsset(
                          avatarPath,
                          width: spacing48,
                          height: spacing48,
                          radius: BorderRadius.circular(radius32),
                        ),
                        title: Text(
                          MockData.aiModels[index]["display"]!,
                          style: AppFontStyles.poppinsTextBold(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          MockData.aiModels[index]["prompt"]!,
                          style: AppFontStyles.poppinsRegular(color: ColorConst.textGrayColor, fontSize: fontSize12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          // Handle chat item tap
                          Navigator.of(context).pushNamed(
                            ChatThreadScreen.routeName,
                            arguments: {
                              ...MockData.aiModels[index],
                              'chatStatus': ChatThreadStatus.new_,
                              'botValue': MockData.aiModels[index]['value'],
                            },
                          );
                        }),
                  );
                })));
  }
}
