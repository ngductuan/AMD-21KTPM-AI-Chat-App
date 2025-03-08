import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[500],
            fontSize: 16,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          prompt['title'],
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          prompt['description'],
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: IconButton(
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mail_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No data',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
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
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.blue[400],
                ),
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
          _buildEmptyState(),
          // Favorite tab
          _buildEmptyState(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new prompt logic
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue[400],
      ),
    );
  }
}
