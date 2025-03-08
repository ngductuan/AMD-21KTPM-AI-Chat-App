import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/styles.dart';

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

  // Sample data - replace with your actual data model
  final List<Map<String, dynamic>> _prompts = [
    {
      'title': 'Grammar corrector',
      'description': 'Improve your spelling',
      'isFavorite': true,
    },
    {
      'title': 'Learn Code Fast',
      'description': 'Teach you code with understandable knowledge',
      'isFavorite': false,
    },
    {
      'title': 'Story generator',
      'description': 'Create your own fantasy story!',
      'isFavorite': false,
    },
    {
      'title': 'Easy Improver',
      'description': "Improve your content's effectiveness with ease",
      'isFavorite': false,
    },
  ];

  final List<Map<String, dynamic>> _customPrompts = [];

  final List<Map<String, dynamic>> _filteredPrompts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(spacing16),
      decoration: BoxDecoration(
        color: ColorConst.grayOverlayColor,
        borderRadius: BorderRadius.circular(spacing30),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {}); // Refresh UI to filter search results
        },
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[500],
            fontSize: fontSize16,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: spacing20, vertical: spacing12),
        ),
      ),
    );
  }

  Widget _buildPromptItem(Map<String, dynamic> prompt) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: spacing16, vertical: spacing8),
        title: Text(
          prompt['title'],
          style: GoogleFonts.poppins(
            fontSize: fontSize18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          prompt['description'],
          style: GoogleFonts.poppins(
            fontSize: fontSize14,
            color: Colors.grey[600],
          ),
        ),
        trailing: GestureDetector(
          onTap: () {
            setState(() {
              prompt['isFavorite'] = !prompt['isFavorite'];
            });
          },
          child: SvgPicture.asset(
            prompt['isFavorite'] ? AssetPath.yellow_star : AssetPath.black_star,
            width: spacing24, // Adjust size if needed
            height: spacing24,
          ),
        ),
      ),
    );
  }

  Widget _buildPromptList(bool isCustom) {
    final String searchText = _searchController.text.toLowerCase();
    final List<Map<String, dynamic>> filteredPrompts =
        (isCustom ? _customPrompts : [..._prompts, ..._customPrompts])
            .where((p) =>
                p['title'].toLowerCase().contains(searchText) ||
                p['description'].toLowerCase().contains(searchText))
            .toList();

    return filteredPrompts.isNotEmpty
        ? ListView.builder(
            itemCount: filteredPrompts.length,
            itemBuilder: (context, index) =>
                _buildPromptItem(filteredPrompts[index]),
          )
        : _buildEmptyState();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AssetPath.noDataIcon,
            width: 100,
            height: 100,
          )
        ],
      ),
    );
  }

  void _showNewPromptDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spacing20),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(spacing24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New prompt',
                        style: GoogleFonts.poppins(
                          fontSize: fontSize24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Name',
                        style: GoogleFonts.poppins(
                          fontSize: fontSize16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(spacing12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: spacing24),
                      Row(
                        children: [
                          Text(
                            'Prompt',
                            style: GoogleFonts.poppins(
                              fontSize: fontSize16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: spacing4),
                          Text(
                            '*',
                            style: GoogleFonts.poppins(
                              fontSize: fontSize16,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Use square brackets [ ] to specify user input.',
                        style: GoogleFonts.poppins(
                          fontSize: fontSize12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: spacing8),
                      TextField(
                        controller: _promptController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          hintText:
                              'e.g: Write an article about [TOPIC], make sure to include these keywords: [KEYWORDS]',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(spacing12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: spacing24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _nameController.clear();
                              _promptController.clear();
                            },
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(width: spacing16),
                          ElevatedButton(
                            onPressed: () {
                              if (_nameController.text.isNotEmpty &&
                                  _promptController.text.isNotEmpty) {
                                setState(() {
                                  _customPrompts.add({
                                    'title': _nameController.text,
                                    'description': _promptController.text,
                                    'isFavorite': false,
                                    'isCustom': true,
                                  });
                                });
                                Navigator.pop(context);
                                _nameController.clear();
                                _promptController.clear();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(spacing20),
                              ),
                            ),
                            child: Text(
                              'Create',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              _buildSearchBar(),
              TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                indicator: ShapeDecoration(
                  color: Colors.blue[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    child: Text(
                      'Public',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'My prompt',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Favorite',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Public tab
          _prompts.isNotEmpty
              ? ListView.builder(
                  itemCount: _prompts.length,
                  itemBuilder: (context, index) =>
                      _buildPromptItem(_prompts[index]),
                )
              : _buildEmptyState(),
          // My prompt tab
          _buildPromptList(true),
          // Favorite tab
          _buildPromptList(false),
        ],
      ),

      // Add new prompt button
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewPromptDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue[400],
      ),
    );
  }
}
