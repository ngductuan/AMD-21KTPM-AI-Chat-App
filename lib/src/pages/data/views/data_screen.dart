import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';
import 'package:eco_chat_bot/src/pages/data/widgets/create_knowledge_popup.dart';
import 'package:eco_chat_bot/src/pages/data/widgets/knowledge_info_popup.dart';

import 'package:eco_chat_bot/src/constants/api/api_base.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});
  static const String routeName = '/data';

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Danh sách knowledges và loading flag
  List<Map<String, dynamic>> _knowledgeData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // gọi fetch ngay khi khởi tạo
    _fetchKnowledges();
    // lắng nghe thay đổi search
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _fetchKnowledges() async {
    try {
      final api = ApiBase();
      // 3. Gọi API; có thể truyền tham số nếu cần
      final resp = await api.getKnowledges(
        q: '',
        order: 'DESC',
        orderField: 'createdAt',
        offset: 0,
        limit: 45,
      );
      // Giả định API trả về JSON với key 'data' là list các knowledge
      final data = resp['data'] as List<dynamic>;
      setState(() {
        _knowledgeData = data.map((e) {
          return {
            'id': e['id'],
            'knowledgeName': e['knowledgeName'],
            'description': e['description'],
            'createdAt': e['createdAt'],
            'updatedAt': e['updatedAt'],
            'createdBy': e['createdBy'],
            'updatedBy': e['updatedBy'],
            'userId': e['userId'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      // TODO: xử lý lỗi (hiện snackbar, retry, v.v.)
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4. Lọc theo tên
    final filtered = _knowledgeData.where((item) {
      final name = (item['knowledgeName'] as String).toLowerCase();
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
            // Search + Create
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
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
                    // mở modal tạo mới và thêm kết quả vào danh sách
                    showDialog(
                        context: context,
                        builder: (_) =>
                            CreateKnowledgePopup(onCreated: (newKb) {
                              setState(() {
                                // map trực tiếp các trường từ API về structure của _knowledgeData
                                _knowledgeData.insert(0, {
                                  'id': newKb['knowledgeId'] ?? newKb['id'],
                                  'knowledgeName': newKb['knowledgeName'],
                                  'description': newKb['description'],
                                  'createdAt': newKb['createdAt'],
                                  'updatedAt': newKb['updatedAt'],
                                  'createdBy': newKb['createdBy'],
                                  'updatedBy': newKb['updatedBy'],
                                  'userId': newKb['userId'],
                                });
                              });
                            }));
                  },
                ),
              ],
            ),

            const SizedBox(height: spacing16),

            // Nội dung
            Expanded(
              child: _isLoading
                  // loading indicator
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
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
                                item['knowledgeName'] as String,
                                style: AppFontStyles.poppinsTextBold(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                item['description'] as String,
                                style: AppFontStyles.poppinsRegular(
                                  color: ColorConst.textGrayColor,
                                  fontSize: fontSize12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => KnowledgeInfoPopup(
                                    knowledge: item,
                                    onDeleted: () {
                                      setState(() {
                                        _knowledgeData.removeWhere(
                                            (e) => e['id'] == item['id']);
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Knowledge deleted')),
                                      );
                                    },
                                  ),
                                );
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
