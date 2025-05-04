import 'dart:convert';

import 'package:eco_chat_bot/src/constants/enum.dart';
import 'package:eco_chat_bot/src/constants/mock_data.dart';
import 'package:eco_chat_bot/src/constants/services/bot.service.dart';
import 'package:eco_chat_bot/src/constants/services/token.service.dart';
import 'package:eco_chat_bot/src/constants/share_preferences/local_storage_key.dart';
import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:eco_chat_bot/src/pages/ai_bot/widgets/ai_bot_item.dart';
import 'package:eco_chat_bot/src/pages/chat/views/chat_thread.dart';
import 'package:eco_chat_bot/src/pages/chat/widgets/manage_bot_modal.dart';
import 'package:eco_chat_bot/src/pages/data/views/data_screen.dart';
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

  // subscription info
  String subscriptionName = '';
  int usedToken = 0;
  int totalToken = 0;

  List<dynamic> _aiModels = [];
  String botSelectedId = "";

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString(LocalStorageKey.email) ?? "Guest";
      userId = prefs.getString(LocalStorageKey.userId) ?? "";
    });
  }

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

  Future<void> fetchSubscriptionUsage() async {
    try {
      final api = ApiBase();
      final resp = await api.getSubscriptionUsage();
      setState(() {
        subscriptionName = resp['name'] ?? '';
        // dailyTokens là limit hàng ngày
        usedToken = resp['dailyTokens'] ?? 0;
        totalToken = resp['dailyTokens'] ?? 0; // lấy limit daily cho progress
      });
    } catch (e) {
      print('Error fetching subscription usage: $e');
      // fallback nếu lỗi
      setState(() {
        subscriptionName = 'Free';
        usedToken = 0;
        totalToken = 0;
      });
    }
  }

  int _currentPage = 0;
  final int _limit = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

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
      final response = await BotServiceApi.getAllBots(search: searchQuery, offset: offset, limit: _limit);
      final jsonResponse = json.decode(response) as Map<String, dynamic>;
      if (jsonResponse.containsKey('data')) {
        final newItems = jsonResponse['data'] as List<dynamic>;
        setState(() {
          _aiModels.addAll(newItems);
          _currentPage++;
          _hasMore = newItems.length == _limit;
        });
      }
    } catch (e) {
      print('Error fetching AI models: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<dynamic> fetchAiModelById() async {
    if (botSelectedId.isEmpty) return null;
    try {
      return await BotServiceApi.getBotById(botSelectedId);
    } catch (e) {
      print('Error fetching bot by ID: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();

    fetchTokenUsage();

    _scrollController.addListener(_scrollListener);
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
        !_scrollController.position.outOfRange &&
        !_isLoading &&
        _hasMore) {
      fetchAiModels();
    }
  }

  Future<void> updateBotData(dynamic body, Function endCallback) async {
    try {
      await BotServiceApi.updateBotById(botSelectedId, body);
      AppToast(
        context: context,
        duration: const Duration(seconds: 1),
        message: 'Bot updated successfully!',
        mode: AppToastMode.confirm,
      ).show(context);
    } catch (e) {
      print('Error updating bot: $e');
      AppToast(
        context: context,
        duration: const Duration(seconds: 1),
        message: 'Error updating bot',
        mode: AppToastMode.error,
      ).show(context);
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      endCallback();
      fetchAiModels(reset: true);
    }
  }

  void _showBotMenu(BuildContext context, int index, Offset tapPosition) {
    final overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      color: ColorConst.backgroundGrayColor2,
      position: RelativeRect.fromRect(tapPosition & const Size(spacing40, spacing40), Offset.zero & overlay.size),
      items: [
        PopupMenuItem(
          child: Row(children: const [
            Icon(Icons.edit, color: Colors.black),
            SizedBox(width: spacing8),
            Text('Edit Bot'),
          ]),
          onTap: () async {
            final data = await fetchAiModelById();
            if (data != null) {
              Navigator.of(context).push(
                AnimationModal.fadeInModal(
                  ManageBotModal(
                    botData: data,
                    endCallback: updateBotData,
                    activeButtonText: 'Update',
                  ),
                ),
              );
            }
          },
        ),
        PopupMenuItem(
          child: Row(children: const [
            Icon(Icons.chat_bubble_outline, color: Colors.black),
            SizedBox(width: spacing8),
            Text('Preview'),
          ]),
          onTap: () {
            Navigator.of(context).pushNamed(
              ChatThreadScreen.routeName,
              arguments: {
                'chatStatus': ChatThreadStatus.newExplore,
                'botId': _aiModels[index]['id'],
                'isVisibleGadget': false,
              },
            ).then((popValue) {
              if (popValue == true) fetchSubscriptionUsage();
            });
          },
        ),
        PopupMenuItem(
          child: Row(children: const [
            Icon(Icons.source_outlined, color: Colors.black),
            SizedBox(width: spacing8),
            Text('Edit knowledge'),
          ]),
          onTap: () {
            Navigator.of(context).pushNamed(
              DataScreen.routeName,
              arguments: {
                'isGotKnowledgeForEachBot': true,
                'assistantId': _aiModels[index]['id'],
              },
            );
          },
        ),
        PopupMenuItem(
          child: Row(children: [
            const Icon(Icons.delete, color: ColorConst.backgroundRedColor),
            const SizedBox(width: spacing8),
            Text('Remove Bot', style: TextStyle(color: ColorConst.textRedColor)),
          ]),
          onTap: () async {
            final confirmed =
                await buildShowConfirmDialog(context, 'Are you sure you want to remove this bot?', 'Confirm');
            if (confirmed == true) {
              try {
                final resp = await BotServiceApi.deleteBotById(botSelectedId);
                if (resp == 'true') {
                  AppToast(
                    context: context,
                    duration: const Duration(seconds: 1),
                    message: 'Bot removed successfully!',
                    mode: AppToastMode.confirm,
                  ).show(context);
                  fetchAiModels(reset: true);
                }
              } catch (e) {
                print('Error removing bot: $e');
                AppToast(
                  context: context,
                  duration: const Duration(seconds: 1),
                  message: 'Error removing bot',
                  mode: AppToastMode.error,
                ).show(context);
              }
            }
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
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
              _loadUserData();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Profile header
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
                  Row(children: [
                    const SizedBox(width: spacing20),
                    CircleAvatar(
                      radius: spacing40,
                      backgroundImage: AssetImage(AssetPath.logoApp),
                    ),
                    const SizedBox(width: spacing20),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: spacing16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              email != null && email != "Guest" ? email!.split('@').first : 'Guest',
                              style: AppFontStyles.poppinsTitleSemiBold(fontSize: fontSize20),
                            ),
                            Text(
                              userId != null && userId!.isNotEmpty ? 'ID: ${userId!.substring(0, 8)}' : 'ID:',
                              style: AppFontStyles.poppinsRegular(color: ColorConst.textGrayColor),
                            ),
                            const SizedBox(height: spacing4),
                            Row(children: [
                              Text(
                                'Token/request: 1',
                                style: AppFontStyles.poppinsTitleSemiBold(color: ColorConst.textGrayColor),
                              ),
                              SizedBox(width: spacing32),
                              Icon(
                                Icons.edit_note_outlined,
                                color: ColorConst.backgroundBlackColor,
                                size: spacing24,
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: spacing8),

                  // Chỉ show progress khi có totalToken > 0
                  if (totalToken > 0)
                    ProgressTracker(
                      today: usedToken,
                      total: totalToken,
                    ),
                ],
              ),
            ),

            // My bots
            Expanded(
              child: Container(
                color: ColorConst.backgroundGrayColor2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: spacing20, vertical: spacing12),
                      child: Text(
                        'My bots',
                        style: AppFontStyles.poppinsTitleSemiBold(fontSize: fontSize18),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: spacing8),
                        itemCount: _aiModels.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _aiModels.length) {
                            return buildLoadingIndicator(hasMore: _hasMore);
                          }
                          final botAvatar = MockData.aiModels[index % MockData.aiModels.length];
                          return GestureDetector(
                            onTapUp: (details) {
                              botSelectedId = _aiModels[index]['id'] ?? "";
                              _showBotMenu(context, index, details.globalPosition);
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
