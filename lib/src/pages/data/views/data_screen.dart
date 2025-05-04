import 'package:eco_chat_bot/src/constants/services/knowledge.service.dart';
import 'package:eco_chat_bot/src/widgets/toast/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/helpers/image_helpers.dart';
import 'package:eco_chat_bot/src/widgets/gradient_form_button.dart';
import 'package:eco_chat_bot/src/pages/data/widgets/create_knowledge_popup.dart';
import 'package:eco_chat_bot/src/pages/data/widgets/knowledge_info_popup.dart';

import 'package:eco_chat_bot/src/constants/api/api_base.dart';

class DataScreen extends StatefulWidget {
  const DataScreen(
      {super.key,
      this.isGotKnowledgeForEachBot = false,
      this.assistantId = ''});
  static const String routeName = '/data';

  final bool isGotKnowledgeForEachBot;
  final String assistantId;

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

    if (widget.isGotKnowledgeForEachBot) {
      // fetch knowledge by botId
      _fetchKnowledgeByBotId(widget.assistantId);
    } else {
      // fetch all knowledges
      _fetchKnowledges();
    }

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
            'numUnits': e['numUnits'],
            'totalSize': e['totalSize']
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching all knowledges: $e');
      AppToast(
        context: context,
        duration: Duration(seconds: 1),
        message: 'Error fetching all knowledges',
        mode: AppToastMode.error,
      ).show(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchKnowledgeByBotId(String assistantId) async {
    try {
      // 3. Gọi API; có thể truyền tham số nếu cần
      final resp = await KnowledgeServiceApi.getImportedSourceByBotId(
        assistantId,
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
      print('Error fetching knowledge by botId: $e');
      AppToast(
        context: context,
        duration: Duration(seconds: 1),
        message: 'Error fetching knowledge by botId',
        mode: AppToastMode.error,
      ).show(context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatSize(dynamic bytes) {
    final double b = (bytes is num) ? bytes.toDouble() : 0;
    final double kb = b / 1024;
    return '${kb.toStringAsFixed(2)} KB';
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
      // backgroundColor: ColorConst.backgroundGrayColor,
      backgroundColor: ColorConst.backgroundWhiteColor,
      body: Container(
        color: ColorConst.backgroundGrayColor,
        child: Padding(
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
                        hintText: 'Find knowledge base',
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
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: spacing8),
                                leading: ImageHelper.loadFromAsset(
                                  AssetPath.icoDatabase,
                                  width: spacing24,
                                  height: spacing24,
                                ),
                                title: Text(
                                  item['knowledgeName'] as String,
                                  style: AppFontStyles.poppinsTextBold(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1) Dòng mô tả
                                    Text(
                                      item['description'] as String? ?? '',
                                      style: AppFontStyles.poppinsRegular(
                                        color: ColorConst.textGrayColor,
                                        fontSize: fontSize12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    // 2) Dòng pills Units + Total Size
                                    Row(
                                      children: [
                                        // Units pill
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .green, // hoặc dùng ColorConst nếu có
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${item['numUnits'] ?? 0} units',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Total Size pill
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .purple, // hoặc dùng ColorConst nếu có
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _formatSize(item['totalSize'] ?? 0),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
                                              content:
                                                  Text('Knowledge deleted')),
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
      ),
    );
  }
}
