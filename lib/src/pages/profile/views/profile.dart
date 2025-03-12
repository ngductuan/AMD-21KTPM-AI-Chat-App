import 'package:flutter/material.dart';
import '../../../constants/styles.dart';
import 'settings_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static const String routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? selectedBotIndex;

  final List<Map<String, dynamic>> botList = const [
    {
      "title": "Creative WritingsE",
      "subtitle": "Hello! I can provide assistance with your writing needs.",
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
    Future.delayed(Duration.zero, () {
      showMenu(
        context: context,
        position: RelativeRect.fromRect(
          tapPosition & const Size(spacing40, spacing40),
          Offset.zero & overlay.size,
        ),
        items: [
          PopupMenuItem(
            child: Row(
              children: const [
                Icon(Icons.edit, color: Colors.black),
                SizedBox(width: spacing8),
                Text('Edit Bot'),
              ],
            ),
            onTap: () {},
          ),
          PopupMenuItem(
            child: Row(
              children: [
                const Icon(Icons.delete, color: ColorConst.backgroundRedColor),
                const SizedBox(width: 8),
                Text('Remove Bot',
                    style: AppFontStyles.poppinsTextBold(
                        color: ColorConst.textRedColor)),
              ],
            ),
            onTap: () {},
          ),
        ],
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.blue, Colors.purple, Colors.red],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds),
                    child: const Text(
                      'EcoChatBot',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: spacing2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(spacing8),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsScreen()),
                          );
                        },
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: spacing16),
              child: Row(
                children: [
                  const SizedBox(width: spacing20),
                  CircleAvatar(
                    radius: spacing40,
                    backgroundImage: AssetImage(AssetPath.logoApp),
                    backgroundColor: Colors.lightBlue[100],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('StarrySia',
                          style: AppFontStyles.poppinsTitleBold(
                              fontSize: fontSize28)),
                      Text('ID 845289347',
                          style: AppFontStyles.poppinsRegular(
                              fontSize: fontSize16, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 8,
              color: ColorConst.BackgroundGreyColor,
            ),
            Expanded(
              child: Container(
                color: ColorConst.BackgroundGreyColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(spacing20),
                      child: Text(
                        'My bots',
                        style: AppFontStyles.poppinsTitleBold(
                            fontSize: fontSize24),
                      ),
                    ),
                    ...List.generate(botList.length, (index) {
                      final bot = botList[index];
                      return GestureDetector(
                        onTapUp: (TapUpDetails details) {
                          setState(() => selectedBotIndex = index);
                          _showBotMenu(context, index, details.globalPosition);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: _buildBotItem(
                            bot["title"],
                            bot["subtitle"],
                            bot["color"],
                            bot["icon"],
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppFontStyles.poppinsTitleBold(fontSize: 18)),
                  Text(
                    description,
                    style: AppFontStyles.poppinsRegular(
                        fontSize: 14, color: Colors.grey[500]!),
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
