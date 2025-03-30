import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eco_chat_bot/src/widgets/no_data_gadget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final TextEditingController _promptController = TextEditingController();

  bool _isEditing = false;
  int _editingIndex = -1;
  bool _isLoadingPrompts = false;

  final List<Map<String, dynamic>> _prompts = [];
  final List<Map<String, dynamic>> _customPrompts = [];
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchPublicPrompts();
  }

  Future<void> fetchPublicPrompts([String category = 'All']) async {
    setState(() => _isLoadingPrompts = true);
    const String baseUrl = 'https://api.jarvis.cx/api/v1/prompts';
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    if (accessToken == null || accessToken.isEmpty) return;

    var headers = {'Authorization': 'Bearer $accessToken'};
    final url = category == 'All'
        ? '$baseUrl?query=&isPublic=true&limit=10&offset=0'
        : '$baseUrl?query=$category&isPublic=true&limit=10&offset=0';

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _prompts.clear();
          _prompts.addAll((data['items'] as List).map((item) {
            return {
              'title': item['title'],
              'description': item['description'] ?? '',
              'prompt': item['content'],
              'isFavorite': item['isFavorite'] ?? false,
            };
          }));
        });
      }
    } finally {
      setState(() => _isLoadingPrompts = false);
    }
  }

  void _addOrEditPrompt() {
    final promptData = {
      'title': _nameController.text,
      'description': 'Custom Prompt',
      'prompt': _promptController.text,
      'isFavorite': false,
    };
    setState(() {
      if (_isEditing) {
        _customPrompts[_editingIndex] = promptData;
      } else {
        _customPrompts.add(promptData);
      }
    });
    Navigator.pop(context);
  }

  void _showPromptDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_isEditing ? 'Edit Prompt' : 'New Prompt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _promptController,
                decoration: InputDecoration(labelText: 'Prompt'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: Text(_isEditing ? 'Update' : 'Add'),
              onPressed: _addOrEditPrompt,
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Prompt'),
          content: Text('Are you sure you want to delete this prompt?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _customPrompts.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndCategoryBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Search bar
          Expanded(
            flex: 7, // Chiếm 3/4 không gian
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          SizedBox(width: 8), // Khoảng cách giữa Search và Category
          // Category select
          Expanded(
            flex: 4, // Chiếm 1/4 không gian
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

  Widget _buildPromptItem(Map<String, dynamic> prompt, bool isCustom) {
    return ListTile(
      title: Text(prompt['title']),
      subtitle: Text(prompt['description']),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCustom)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _isEditing = true;
                _nameController.text = prompt['title'];
                _promptController.text = prompt['prompt'];
                _editingIndex = _customPrompts.indexOf(prompt);
                _showPromptDialog();
              },
            ),
          if (isCustom)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () =>
                  _showDeleteConfirmation(_customPrompts.indexOf(prompt)),
            ),
          IconButton(
            icon: Icon(
              prompt['isFavorite'] ? Icons.star : Icons.star_border,
              color: prompt['isFavorite'] ? Colors.yellow : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                prompt['isFavorite'] = !prompt['isFavorite'];
              });
            },
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context, {
          'title': prompt['title'],
          'prompt': prompt['prompt'],
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchText = _searchController.text.toLowerCase();
    return Scaffold(
      appBar: AppBar(
        title: Text('Prompt Library'),
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
          Column(
            children: [
              _buildSearchAndCategoryBar(),
              Expanded(
                child: _isLoadingPrompts
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _prompts.length,
                        itemBuilder: (context, index) {
                          return _buildPromptItem(_prompts[index], false);
                        },
                      ),
              ),
            ],
          ),
          ListView.builder(
            itemCount: _customPrompts.length,
            itemBuilder: (context, index) {
              return _buildPromptItem(_customPrompts[index], true);
            },
          ),
          Center(child: Text('Favorite Prompts')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _isEditing = false;
          _nameController.clear();
          _promptController.clear();
          _showPromptDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
