import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/constants/asset_path.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});
  static const String routeName = '/data';

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Dummy knowledge-base data
  final List<Map<String, String>> _knowledgeData = [
    {
      "createdAt": "2019-08-24T14:15:22.123Z",
      "updatedAt": "2019-08-24T14:15:22.123Z",
      "createdBy": "alice",
      "updatedBy": "alice",
      "userId": "u1",
      "knowledgeName": "Flutter Basics",
      "description": "Introduction to Flutter development"
    },
    {
      "createdAt": "2020-01-10T09:30:00.000Z",
      "updatedAt": "2020-01-11T10:00:00.000Z",
      "createdBy": "bob",
      "updatedBy": "bob",
      "userId": "u2",
      "knowledgeName": "Dart Async",
      "description": "Futures, Streams and async/await in Dart"
    },
    // thêm các mục thực tế ở đây...
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lọc theo tên
    final filtered = _knowledgeData.where((item) {
      final name = item['knowledgeName']!.toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Knowledge Base',
          style: AppFontStyles.poppinsTitleBold(fontSize: fontSize20),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: ColorConst.backgroundWhiteColor,
        shadowColor: ColorConst.backgroundLightGrayColor,
      ),
      backgroundColor: ColorConst.backgroundGrayColor,
      body: Padding(
        padding: const EdgeInsets.all(padding16),
        child: Column(
          children: [
            // Search field + Create button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search knowledge base',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: ColorConst.backgroundWhiteColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: spacing12),
                GradientFormButton(
                  text: 'Create',
                  isActiveButton: true,
                  onPressed: () {
                    // TODO: Navigate to create-knowledge screen or show modal
                  },
                ),
              ],
            ),

            const SizedBox(height: spacing16),

            // Nội dung danh sách hoặc placeholder
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ImageHelper.loadFromAsset(
                            AssetPath.noData,
                            width: 120,
                            height: 120,
                          ),
                          const SizedBox(height: spacing16),
                          Text(
                            'No knowledge found',
                            style: AppFontStyles.poppinsTextBold(
                                fontSize: fontSize16),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: ColorConst.backgroundLightGrayColor,
                      ),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return ListTile(
                          title: Text(
                            item['knowledgeName']!,
                            style: AppFontStyles.poppinsTextBold(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            item['description']!,
                            style: AppFontStyles.poppinsRegular(
                              color: ColorConst.textGrayColor,
                              fontSize: fontSize12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            // TODO: Mở chi tiết knowledge
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
