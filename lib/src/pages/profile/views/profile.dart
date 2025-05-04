import 'dart:convert';

import 'package:eco_chat_bot/src/constants/enum.dart';
import 'package:eco_chat_bot/src/constants/mock_data.dart';
import 'package:eco_chat_bot/src/constants/services/bot.service.dart';
import 'package:eco_chat_bot/src/constants/services/token.service.dart';
import 'package:eco_chat_bot/src/constants/share_preferences/local_storage_key.dart';
import 'package:eco_chat_bot/src/pages/ai_bot/widgets/ai_bot_item.dart';
import 'package:eco_chat_bot/src/pages/chat/views/chat_thread.dart';
import 'package:eco_chat_bot/src/pages/chat/widgets/manage_bot_modal.dart';
import 'package:eco_chat_bot/src/pages/data/views/data_screen.dart';
import 'package:eco_chat_bot/src/pages/data/widgets/knowledge_info_popup.dart';
import 'package:eco_chat_bot/src/pages/profile/widgets/token_progress.dart';
import 'package:eco_chat_bot/src/widgets/animations/animation_modal.dart';
import 'package:eco_chat_bot/src/widgets/loading_indicator.dart';
import 'package:eco_chat_bot/src/widgets/show_confirm_dialog.dart';
import 'package:eco_chat_bot/src/widgets/toast/app_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_profile.dart';
import 'package:flutter/material.dart';
import '../../../constants/styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userId;
  String? email;
  List<dynamic> _aiModels = [];
  String botSelectedId = "";
  dynamic botSelectedData;

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Nếu không có email, mặc định hiển thị "Guest"
      email = prefs.getString(LocalStorageKey.email) ?? "Guest";
      // Nếu không có userId, có thể để rỗng hoặc hiển thị "Guest" tùy ý
      userId = prefs.getString(LocalStorageKey.userId) ?? "";
    });
  }

  int _currentPage = 0;
  final int _limit = 10; // Number of items to load per request
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  int usedToken = 0;
  int totalToken = 0;

  Future<void> fetchTokenUsage() async {
    try {
      dynamic response = await TokenServiceApi.getTokenUsage();
      final Map<String, dynamic> jsonResponse = json.decode(response);
      final int availableTokens = jsonResponse['availableTokens'] ?? 0;

      setState(() {
        totalToken = jsonResponse['totalTokens'] ?? 0;
        usedToken = totalToken - availableTokens;
      });
    } catch (e) {
      // Handle the exception
      print('Exception occurred while fetching token usage: $e');
    }
  }

  Future<void> fetchAiModels({String? searchQuery, bool reset = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (reset) {
        _currentPage = 0;
        _hasMore = true;
        _aiModels.clear();
      }
    });

    try {
      final offset = _currentPage * _limit;
      dynamic response = await BotServiceApi.getAllBots(search: searchQuery, offset: offset, limit: _limit);

      final Map<String, dynamic> jsonResponse = json.decode(response);

      if (jsonResponse.containsKey('data')) {
        final newItems = jsonResponse['data'];

        setState(() {
          _aiModels.addAll(newItems);
          _currentPage++;
          // If we get fewer items than requested, we've reached the end
          _hasMore = newItems.length == _limit;
        });
      }
    } catch (e) {
      // Handle the exception
      print('Exception occurred while fetching AI models: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<dynamic> fetchAiModelById() async {
    if (botSelectedId.isEmpty) return;

    try {
      dynamic response = await BotServiceApi.getBotById(botSelectedId);

      return response;
    } catch (e) {
      print('Exception occurred while fetching bot data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _scrollController.addListener(_scrollListener);

    fetchTokenUsage();

    fetchAiModels();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (!_isLoading && _hasMore) {
        fetchAiModels();
        // print('Loading more items...');
      }
    }
  }

  Future<void> updateBotData(dynamic body, Function endCallback) async {
    try {
      await BotServiceApi.updateBotById(
        botSelectedId,
        body,
      );

      AppToast(
        context: context,
        duration: Duration(seconds: 1),
        message: 'Bot updated successfully!',
        mode: AppToastMode.confirm,
      ).show(context);
    } catch (e) {
      print('Error updating bot: $e');
      AppToast(
        context: context,
        duration: Duration(seconds: 1),
        message: 'Error updating bot',
        mode: AppToastMode.error,
      ).show(context);
    } finally {
      await Future.delayed(const Duration(milliseconds: 1000));
      endCallback();
      fetchAiModels(reset: true);
    }
  }

  void _showBotMenu(BuildContext context, int index, Offset tapPosition) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      color: ColorConst.backgroundGrayColor2,
      position: RelativeRect.fromRect(
        tapPosition & const Size(spacing40, spacing40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: const [
              Icon(Icons.edit, color: Colors.black),
              SizedBox(width: spacing8),
              Text('Edit Bot'),
            ],
          ),
          onTap: () async {
            try {
              final dynamic data = await fetchAiModelById();
              Navigator.of(context).push(AnimationModal.fadeInModal(
                  ManageBotModal(botData: data, endCallback: updateBotData, activeButtonText: 'Update')));
            } catch (e) {
              print('Error fetching bot data by ID: $e');
            }
          },
        ),
        PopupMenuItem(
          child: Row(
            children: const [
              Icon(Icons.chat_bubble_outline, color: Colors.black),
              SizedBox(width: spacing8),
              Text('Preview'),
            ],
          ),
          onTap: () async {
            Navigator.of(context).pushNamed(
              ChatThreadScreen.routeName,
              arguments: {
                'chatStatus': ChatThreadStatus.newExplore,
                'botId': _aiModels[index]['id'],
                'isVisibleGadget': false,
              },
            ).then((popValue) => {
                  if (popValue != null && popValue == true) {fetchTokenUsage()}
                });
          },
        ),
        PopupMenuItem(
          child: Row(
            children: const [
              Icon(Icons.source_outlined, color: Colors.black),
              SizedBox(width: spacing8),
              Text('Edit knowledge'),
            ],
          ),
          onTap: () {
            // Navigate to the knowledge base screen
            Navigator.of(context).pushNamed(DataScreen.routeName, arguments: {
              'isGotKnowledgeForEachBot': true,
              'assistantId': _aiModels[index]['id'],
            });
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.delete, color: ColorConst.backgroundRedColor),
              const SizedBox(width: spacing8),
              Text('Remove Bot', style: TextStyle(color: ColorConst.textRedColor)),
            ],
          ),
          onTap: () async {
            // Add remove functionality
            buildShowConfirmDialog(context, 'Are you sure you want to remove this bot?', 'Confirm').then(
              (bool? popValue) async {
                try {
                  if (popValue == true) {
                    final String response = await BotServiceApi.deleteBotById(botSelectedId);
                    if (response == 'true') {
                      AppToast(
                        context: context,
                        duration: const Duration(seconds: 1),
                        message: 'Bot removed successfully!',
                        mode: AppToastMode.confirm,
                      ).show(context);
                    }
                  }
                } catch (e) {
                  print('Error removing bot: $e');
                  AppToast(
                    context: context,
                    duration: const Duration(seconds: 1),
                    message: 'Error removing bot',
                    mode: AppToastMode.error,
                  ).show(context);
                } finally {
                  await Future.delayed(const Duration(milliseconds: 1000));
                  if (popValue == true) {
                    fetchAiModels(reset: true);
                  }
                }
              },
            );
          },
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: spacing44,
        elevation: 1,
        shadowColor: ColorConst.backgroundLightGrayColor,
        backgroundColor: ColorConst.backgroundWhiteColor,
        centerTitle: false,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: ColorConst.primaryColorArray,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            'EcoChatBot',
            style: AppFontStyles.poppinsTitleSemiBold(fontSize: fontSize24, color: ColorConst.textWhiteColor),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              // Điều hướng sang SettingsScreen và đợi kết quả trả về
              await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
              // Sau khi trở về, load lại thông tin người dùng
              _loadUserData();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Profile section
            Container(
              padding: const EdgeInsets.symmetric(vertical: spacing16),
              decoration: BoxDecoration(
                color: ColorConst.backgroundWhiteColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: spacing10,
                    offset: const Offset(0, spacing4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: spacing20),
                      // Profile image
                      CircleAvatar(
                        radius: spacing40,
                        backgroundImage: AssetImage(AssetPath.logoApp),
                      ),
                      const SizedBox(width: spacing20),
                      // Profile info
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: spacing16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                email != null && email != "Guest"
                                    ? (email!.contains('@gmail.com')
                                        ? email!.replaceFirst(RegExp(r'@gmail\.com$'), '')
                                        : (email!.length > 10 ? '${email!.substring(0, 15)}...' : email!))
                                    : 'Guest',
                                style: AppFontStyles.poppinsTitleSemiBold(fontSize: fontSize20),
                              ),
                              Text(
                                userId != null && userId!.isNotEmpty
                                    ? 'ID: ${userId!.length > 5 ? userId!.substring(0, 8) : userId!}'
                                    : 'ID: ',
                                style: AppFontStyles.poppinsRegular(color: ColorConst.textGrayColor),
                              ),
                              SizedBox(height: spacing4),
                              Row(
                                children: [
                                  Text(
                                    'Token/request: 1',
                                    style: AppFontStyles.poppinsTitleSemiBold(color: ColorConst.textGrayColor),
                                  ),
                                  SizedBox(width: spacing32),
                                  Icon(
                                    Icons.edit_note_outlined,
                                    color: ColorConst.backgroundBlackColor,
                                    size: spacing24,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacing8),
                  // Token progress section
                  ProgressTracker(
                    today: usedToken,
                    total: totalToken,
                  ),
                ],
              ),
            ),

            // My bots section
            Expanded(
              child: Container(
                color: ColorConst.backgroundGrayColor2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing20, vertical: spacing12),
                      child: Text(
                        'My bots',
                        style: AppFontStyles.poppinsTitleSemiBold(fontSize: fontSize18),
                      ),
                    ),
                    // Dynamically render bot list
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: spacing8),
                        itemCount: _aiModels.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _aiModels.length) {
                            return buildLoadingIndicator(hasMore: _hasMore);
                          }

                          Map<String, String> botAvatar = MockData.aiModels[index % MockData.aiModels.length];

                          return GestureDetector(
                            onTapUp: (TapUpDetails details) {
                              botSelectedId = _aiModels[index]['id'] ?? "";
                              print("botSelectedId: $botSelectedId");

                              _showBotMenu(context, index, details.globalPosition);
                            },
                            onTapDown: (_) {
                              botSelectedId = "";
                            },
                            child: AiBotItem(
                              botData: _aiModels[index],
                              avatarValue: botAvatar['value'],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
