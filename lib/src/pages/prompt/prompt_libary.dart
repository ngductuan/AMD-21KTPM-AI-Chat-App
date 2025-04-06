import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eco_chat_bot/src/widgets/no_data_gadget.dart';
import 'package:flutter/material.dart';
import 'package:eco_chat_bot/src/constants/styles.dart';
import 'package:eco_chat_bot/src/constants/api/api_base.dart';
import 'package:eco_chat_bot/src/constants/share_preferences/local_storage_key.dart';

class PromptLibrary extends StatefulWidget {
  const PromptLibrary({Key? key}) : super(key: key);

  @override
  State<PromptLibrary> createState() => _PromptLibraryState();
}

class _PromptLibraryState extends State<PromptLibrary>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();

  bool _isEditing = false;
  String? _editingPromptId;
  bool _isLoadingPrompts = false;

  // Danh sách prompt Public hoặc Favorite
  final List<Map<String, dynamic>> _prompts = [];
  // Danh sách prompt Custom (riêng tư)
  final List<Map<String, dynamic>> _customPrompts = [];

  // Danh sách category cho Public Prompt
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Marketing',
    'Business',
    'SEO',
    'Writing',
    'Coding',
    'Career',
    'Chatbot',
    'Education',
    'Fun',
    'Productivity',
    'Other'
  ];

  final ApiBase api = ApiBase();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Mặc định load prompt public ban đầu
    fetchPublicPrompts();

    // Lắng nghe sự kiện thay đổi tab
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        fetchPublicPrompts(_selectedCategory);
      } else if (_tabController.index == 1) {
        _searchController.clear(); // Xoá search khi chuyển tab
        fetchCustomPrompts();
      } else if (_tabController.index == 2) {
        _searchController.clear(); // Xoá search khi chuyển tab
        fetchFavoritePrompts();
      }
    });
  }

  // Hàm tạo URL chung cho tất cả loại prompt
  Uri _buildPromptUrl(
      {required bool isPublic, bool isFavorite = false, String category = ''}) {
    final baseUrl = Uri.parse('${ApiBase.jarvisUrl}/api/v1/prompts');
    final queryParams = {
      'query': category == 'All' ? '' : category,
      'isPublic': isPublic ? 'true' : 'false',
      'isFavorite': isFavorite ? 'true' : 'false',
      'limit': '15',
      'offset': '0',
    };
    return baseUrl.replace(queryParameters: queryParams);
  }

  // PUBLIC PROMPTS
  Future<void> fetchPublicPrompts([String category = 'All']) async {
    setState(() => _isLoadingPrompts = true);
    try {
      final response = await api.authenticatedGet(
        _buildPromptUrl(isPublic: true, isFavorite: false, category: category),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _prompts
            ..clear()
            ..addAll((data['items'] as List).map((item) {
              return {
                'id': item['_id'],
                'title': item['title'],
                'description': item['description'] ?? '',
                'prompt': item['content'],
                'isFavorite': item['isFavorite'] ?? false,
              };
            }));
        });
      } else {
        print(
            'Error fetching prompts: ${response.statusCode} - ${response.reasonPhrase}');
        _showErrorSnackbar('Failed to load prompts. Please try again.');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorSnackbar('An unexpected error occurred.');
    } finally {
      setState(() => _isLoadingPrompts = false);
    }
  }

  // FAVORITE PROMPTS
  Future<void> fetchFavoritePrompts() async {
    setState(() => _isLoadingPrompts = true);
    try {
      final response = await api.authenticatedGet(
        _buildPromptUrl(isPublic: true, isFavorite: true, category: 'All'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _prompts
            ..clear()
            ..addAll((data['items'] as List).map((item) {
              return {
                'id': item['_id'],
                'title': item['title'],
                'description': item['description'] ?? '',
                'prompt': item['content'],
                'isFavorite': item['isFavorite'] ?? false,
              };
            }));
        });
      } else {
        print(
            'Error fetching favorite prompts: ${response.statusCode} - ${response.reasonPhrase}');
        _showErrorSnackbar(
            'Failed to load favorite prompts. Please try again.');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorSnackbar(
          'An unexpected error occurred while loading favorites.');
    } finally {
      setState(() => _isLoadingPrompts = false);
    }
  }

  // CUSTOM PROMPTS
  Future<void> fetchCustomPrompts() async {
    setState(() => _isLoadingPrompts = true);
    try {
      final response = await api.authenticatedGet(
        _buildPromptUrl(isPublic: false, category: 'All'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _customPrompts
            ..clear()
            ..addAll((data['items'] as List).map((item) {
              return {
                'id': item['_id'],
                'title': item['title'],
                'description': item['description'] ?? '',
                'prompt': item['content'],
                'isFavorite': item['isFavorite'] ?? false,
              };
            }));
        });
      } else {
        print(
            'Error fetching custom prompts: ${response.statusCode} - ${response.reasonPhrase}');
        _showErrorSnackbar('Failed to load custom prompts. Please try again.');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorSnackbar('An unexpected error occurred while loading customs.');
    } finally {
      setState(() => _isLoadingPrompts = false);
    }
  }

  // TOGGLE FAVORITE
  Future<void> toggleFavorite(String promptId, bool isCurrentlyFavorite) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    if (accessToken == null || accessToken.isEmpty) return;

    var headers = {
      'x-jarvis-guid': 'c18d173d-bb4e-49f9-b4d8-f9a302bf89ff',
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };

    // Hàm tạo URL yêu thích
    Uri _buildFavoriteUrl(String promptId) {
      return Uri.parse(
          '${ApiBase.jarvisUrl}/api/v1/prompts/$promptId/favorite');
    }

    try {
      final response = isCurrentlyFavorite
          ? await http.post(_buildFavoriteUrl(promptId), headers: headers)
          : await http.delete(_buildFavoriteUrl(promptId), headers: headers);

      final message = isCurrentlyFavorite
          ? 'Added to favorites.'
          : 'Removed from favorites.';
      print(message);
      _showSuccessSnackbar(message);
    } catch (e) {
      print('Error toggling favorite: $e');
      _showErrorSnackbar('An unexpected error occurred.');
    }
  }

  // Hàm hiển thị thông báo thành công
  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppFontStyles.poppinsRegular(color: ColorConst.textWhiteColor),
        ),
        backgroundColor: ColorConst.blueColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Hàm hiển thị lỗi qua Snackbar
  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppFontStyles.poppinsRegular(color: ColorConst.textWhiteColor),
        ),
        backgroundColor: ColorConst.backgroundRedColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // THÊM HOẶC CHỈNH SỬA CUSTOM PROMPT
  Future<void> _addOrEditPrompt() async {
    try {
      // Thông tin body gửi lên
      final bodyData = {
        "title": _nameController.text,
        "content": _promptController.text,
        "description": _descriptionController.text,
        "isPublic": false
      };

      if (_isEditing) {
        // CHỈNH SỬA (PATCH)
        if (_editingPromptId == null) return;
        final url =
            'https://api.dev.jarvis.cx/api/v1/prompts/$_editingPromptId';
        final request = http.Request('PATCH', Uri.parse(url));
        request.body = json.encode(bodyData);
        request.headers.addAll(await api.getAuthHeaders());

        final response = await request.send();
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final updatedData = jsonDecode(responseBody);

          // Tìm prompt cũ trong _customPrompts và update
          final indexToUpdate = _customPrompts.indexWhere(
            (p) => p['id'] == _editingPromptId,
          );
          if (indexToUpdate != -1) {
            setState(() {
              _customPrompts[indexToUpdate] = {
                'id': updatedData['_id'],
                'title': updatedData['title'] ?? '',
                'description': updatedData['description'] ?? '',
                'prompt': updatedData['content'] ?? '',
                'isFavorite': updatedData['isFavorite'] ?? false,
              };
            });
          }
          print('Prompt updated successfully.');
        } else {
          print('Error updating prompt: ${response.reasonPhrase}');
        }
      } else {
        // TẠO MỚI (POST)
        final url = 'https://api.dev.jarvis.cx/api/v1/prompts';
        final response = await http.post(
          Uri.parse(url),
          headers: await api.getAuthHeaders(),
          body: json.encode(bodyData),
        );

        if (response.statusCode == 200) {
          final newPrompt = jsonDecode(response.body);
          // Thêm ngay vào danh sách custom local
          setState(() {
            _customPrompts.add({
              'id': newPrompt['_id'],
              'title': newPrompt['title'] ?? '',
              'description': newPrompt['description'] ?? '',
              'prompt': newPrompt['content'] ?? '',
              'isFavorite': newPrompt['isFavorite'] ?? false,
            });
          });
          print('Prompt created successfully.');
        } else {
          print('Error creating prompt: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      print('Error in add/edit prompt: $e');
    }
    Navigator.pop(context);
  }

  // XOÁ CUSTOM PROMPT
  Future<void> _deleteCustomPrompt(String promptId) async {
    try {
      final url = 'https://api.dev.jarvis.cx/api/v1/prompts/$promptId';
      final response = await api.authenticatedDelete(Uri.parse(url));

      if (response.statusCode == 200) {
        // Xoá luôn trong danh sách local
        setState(() {
          _customPrompts.removeWhere((p) => p['id'] == promptId);
        });
        print('Prompt deleted successfully.');
      } else {
        print('Error deleting prompt: ${response.reasonPhrase}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error deleting prompt: $e');
    }
  }

  // HIỂN THỊ DIALOG THÊM/SỬA (cập nhật UI, thêm gợi ý, hint,...)
  void _showPromptDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Sử dụng SingleChildScrollView để tránh tràn nội dung khi bàn phím hiển thị
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Text(
            _isEditing ? 'Edit Prompt' : 'New Prompt',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter prompt title...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12.0),

                // Description
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Short description for your prompt...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12.0),

                // Phần hướng dẫn hiển thị gợi ý
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Use square brackets [ ] to specify user input in Prompt!\n',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 13.5,
                    ),
                  ),
                ),

                // Prompt content
                TextField(
                  controller: _promptController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Prompt',
                    hintText:
                        'E.g. "Write an article about [TOPIC], make sure to include these keywords: [KEYWORDS]"',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(_isEditing ? 'Update' : 'Add'),
              onPressed: _addOrEditPrompt,
            ),
          ],
        );
      },
    );
  }

  // HIỂN THỊ DIALOG XÁC NHẬN XÓA
  void _showDeleteConfirmation(int index) {
    final prompt = _customPrompts[index];
    final promptId = prompt['id'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Prompt'),
          content: const Text('Are you sure you want to delete this prompt?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog trước
                _deleteCustomPrompt(promptId);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // UI HIỂN THỊ SEARCH VÀ CATEGORY (CHO PUBLIC)
  Widget _buildSearchAndCategoryBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Search bar
          Expanded(
            flex: 7,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 8),
          // Category select
          Expanded(
            flex: 4,
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              items: _categories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                  fetchPublicPrompts(_selectedCategory);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // UI HIỂN THỊ SEARCH CHO CUSTOM PROMPT
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: ColorConst.backgroundGrayColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  // BUILD TILE HIỂN THỊ PROMPT
  Widget _buildPromptItem(Map<String, dynamic> prompt, bool isCustom) {
    return Card(
      margin:
          const EdgeInsets.symmetric(horizontal: spacing8, vertical: spacing16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(spacing16),
      ),
      elevation: 4,
      child: ListTile(
        title: Text(
          prompt['title'] ?? 'No Title',
          style: AppFontStyles.poppinsTitleBold(
            color: ColorConst.textBlackColor,
            fontSize: spacing16,
          ),
        ),
        subtitle: Text(
          prompt['description'] ?? 'No Description',
          style: AppFontStyles.poppinsRegular(
            color: ColorConst.textGrayColor,
            fontSize: spacing14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nếu là Custom Prompt, hiển thị nút chỉnh sửa và xóa
            if (isCustom) ...[
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  _isEditing = true;
                  _editingPromptId = prompt['id']; // Lưu lại ID để update

                  // Điền dữ liệu vào TextField
                  _nameController.text = prompt['title'] ?? '';
                  _descriptionController.text = prompt['description'] ?? '';
                  _promptController.text = prompt['prompt'] ?? '';

                  _showPromptDialog();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
                    _showDeleteConfirmation(_customPrompts.indexOf(prompt)),
              ),
            ],

            // Nếu là Public/Favorite Prompt, hiển thị nút yêu thích
            if (!isCustom)
              IconButton(
                icon: Icon(
                  prompt['isFavorite'] ? Icons.star : Icons.star_border,
                  color: prompt['isFavorite'] ? Colors.yellow : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    prompt['isFavorite'] = !prompt['isFavorite'];
                  });
                  toggleFavorite(prompt['id'], prompt['isFavorite']);
                },
              ),
          ],
        ),
        onTap: () {
          // Khi bấm vào prompt thì trả kết quả về
          Navigator.pop(context, {
            'title': prompt['title'],
            'prompt': prompt['prompt'],
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchText = _searchController.text.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text('Prompt Library',
            style: AppFontStyles.poppinsTitleBold(fontSize: fontSize20)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Public'),
            Tab(text: 'Custom'),
            Tab(text: 'Favorite'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB PUBLIC
          Column(
            children: [
              _buildSearchAndCategoryBar(),
              Expanded(
                child: _isLoadingPrompts
                    ? const Center(child: CircularProgressIndicator())
                    : _prompts.isEmpty
                        ? const Center(child: Text("No prompts available"))
                        : ListView.builder(
                            itemCount: _prompts.length,
                            itemBuilder: (context, index) {
                              final prompt = _prompts[index];
                              // Lọc theo từ khoá tìm kiếm (nếu cần)
                              if (searchText.isNotEmpty) {
                                if (!(prompt['title'] ?? '')
                                    .toLowerCase()
                                    .contains(searchText)) {
                                  return const SizedBox.shrink();
                                }
                              }
                              return _buildPromptItem(prompt, false);
                            },
                          ),
              ),
            ],
          ),

          // TAB CUSTOM
          Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: _isLoadingPrompts
                    ? const Center(child: CircularProgressIndicator())
                    : _prompts.isEmpty
                        ? const Center(child: Text("No prompts available"))
                        : _customPrompts.isEmpty
                            ? const NoDataGadget()
                            : ListView.builder(
                                itemCount: _customPrompts.length,
                                itemBuilder: (context, index) {
                                  final prompt = _customPrompts[index];
                                  // Lọc theo từ khoá tìm kiếm (nếu cần)
                                  if (searchText.isNotEmpty) {
                                    if (!(prompt['title'] ?? '')
                                        .toLowerCase()
                                        .contains(searchText)) {
                                      return const SizedBox.shrink();
                                    }
                                  }
                                  return _buildPromptItem(prompt, true);
                                },
                              ),
              ),
            ],
          ),

          // TAB FAVORITE
          Column(
            children: [
              Expanded(
                child: _isLoadingPrompts
                    ? const Center(child: CircularProgressIndicator())
                    : _prompts.isEmpty
                        ? const Center(child: Text("No prompts available"))
                        : ListView.builder(
                            itemCount: _prompts.length,
                            itemBuilder: (context, index) {
                              final prompt = _prompts[index];
                              // Nếu tab Favorite, ta hiển thị prompt đã đánh dấu isFavorite
                              if (searchText.isNotEmpty) {
                                if (!(prompt['title'] ?? '')
                                    .toLowerCase()
                                    .contains(searchText)) {
                                  return const SizedBox.shrink();
                                }
                              }
                              return _buildPromptItem(prompt, false);
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Chuẩn bị thêm mới Custom Prompt
          _isEditing = false;
          _editingPromptId = null;

          _nameController.clear();
          _descriptionController.clear();
          _promptController.clear();

          _showPromptDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
