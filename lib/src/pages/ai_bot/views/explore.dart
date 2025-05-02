import 'dart:convert';

import 'package:eco_chat_bot/src/constants/services/bot.service.dart';
import 'package:eco_chat_bot/src/widgets/debouncer.dart';
import 'package:eco_chat_bot/src/widgets/loading_indicator.dart';
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
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  final TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  bool _isTextFieldFocused = false;
  List<dynamic> _aiModels = [];

  int _currentPage = 0;
  final int _limit = 10; // Number of items to load per request
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isTextFieldFocused = _focusNode.hasFocus;
      });
    });

    _scrollController.addListener(_scrollListener);

    _searchController.addListener(() {
      _debouncer.run(() {
        print('Search query: ${_searchController.text}');

        // If the search field is focused and the text is not empty, perform search
        if (_focusNode.hasFocus && _searchController.text.isNotEmpty) {
          if (_searchController.text.isNotEmpty) {
            _performSearch(_searchController.text);
          } else {
            fetchAiModels(reset: true);
          }
        }
      });
    });

    fetchAiModels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
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

  Future<void> _performSearch(String query) async {
    // Call your API with search query and initial offset
    await fetchAiModels(searchQuery: query, reset: true);
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

        // print('AI models fetched successfully: ${jsonResponse['data']}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: ColorConst.backgroundLightGrayColor,
        backgroundColor: ColorConst.backgroundWhiteColor,
        title: RefreshIndicator(
          color: ColorConst.textHighlightColor,
          onRefresh: () async {
            await fetchAiModels(reset: true);
          },
          child: Container(
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
                      controller: _searchController,
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
        ),
        actions: (_isTextFieldFocused || _searchController.text.isNotEmpty)
            ? [
                IconButton(
                  icon: Icon(Icons.clear, color: ColorConst.textGrayColor),
                  onPressed: () {
                    _focusNode.unfocus();
                    _searchController.clear();

                    fetchAiModels(reset: true);
                  },
                ),
              ]
            : null,
      ),
      body: Container(
        color: ColorConst.backgroundGrayColor,
        child: ListView.builder(
          controller: _scrollController, // Add the scroll controller
          padding: const EdgeInsets.symmetric(vertical: padding8),
          itemCount: _aiModels.length + (_hasMore ? 1 : 0), // Add one more item for loading indicator
          itemBuilder: (context, index) {
            if (index >= _aiModels.length) {
              return buildLoadingIndicator(hasMore: _hasMore);
            }

            Map<String, String> botAvatar = MockData.aiModels[index % MockData.aiModels.length];

            return AiBotItem(
              botData: _aiModels[index],
              avatarValue: botAvatar['value'],
              onTap: () {
                // Your onTap logic
              },
            );
          },
        ),
      ),
    );
  }


}
