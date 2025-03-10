import 'package:flutter/material.dart';
import '../../../constants/styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? selectedBotIndex;

  // Bot list data
  final List<Map<String, dynamic>> botList = const [
    {
      "title": "Creative WritingsE",
      "subtitle": "Hello! l can provide assistance with your writing needs.",
      "icon": Icons.auto_awesome,
      "color": Colors.purple
    },
    {
      "title": "Doctorsage",
      "subtitle":
          "Dr. Sage answers uni med questions in a structured way - fi...",
      "icon": Icons.favorite,
      "color": Colors.green
    },
    {
      "title": "Photo CreateE",
      "subtitle":
          "This bot generates realistic, stock photos, style-photos or animal ph...",
      "icon": Icons.photo,
      "color": Colors.blue
    },
  ];

  void _showBotMenu(BuildContext context, int index, Offset tapPosition) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        tapPosition &
            const Size(40, 40), // Smaller rect for more precise positioning
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: const [
              Icon(Icons.edit, color: Colors.black),
              SizedBox(width: 8),
              Text('Edit Bot'),
            ],
          ),
          onTap: () {
            // Add edit functionality
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.delete, color: Colors.red),
              const SizedBox(width: 8),
              Text('Remove Bot', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () {
            // Add remove functionality
          },
        ),
      ],
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App name with gradient text
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.blue, Colors.purple, Colors.red],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds),
                    child: const Text(
                      'EcoChatBot',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Settings icon
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.settings_outlined),
                    ),
                  ),
                ],
              ),
            ),

            // Profile section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  // Profile image
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(AssetPath.logoApp),
                    backgroundColor: Colors.lightBlue[100],
                  ),
                  const SizedBox(width: 20),
                  // Profile info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'StarrySia',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID 845289347',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              height: 8,
              color: Colors.grey[200],
            ),

            // My bots section
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'My bots',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Dynamically render bot list
                    ...List.generate(botList.length, (index) {
                      final bot = botList[index];
                      return GestureDetector(
                        onTapUp: (TapUpDetails details) {
                          setState(() {
                            selectedBotIndex = index;
                          });
                          _showBotMenu(context, index, details.globalPosition);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: _buildBotItem(
                            bot["title"] as String,
                            bot["subtitle"] as String,
                            bot["color"] as Color,
                            bot["icon"] as IconData,
                            isSelected: selectedBotIndex == index,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotItem(
    String title,
    String description,
    Color color,
    IconData icon, {
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Bot icon
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Bot info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
