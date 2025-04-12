import 'package:eco_chat_bot/src/constants/mock_data.dart';
import 'package:eco_chat_bot/src/constants/share_preferences/local_storage_key.dart';
import 'package:eco_chat_bot/src/pages/ai_bot/widgets/ai_bot_item.dart';
import 'package:eco_chat_bot/src/pages/chat/widgets/create_bot_modal.dart';
import 'package:eco_chat_bot/src/widgets/animations/animation_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_profile.dart';
import 'package:flutter/material.dart';
import '../../../constants/styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? selectedBotIndex;
  String? userId;
  String? email;

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Nếu không có email, mặc định hiển thị "Guest"
      email = prefs.getString(LocalStorageKey.email) ?? "Guest";
      // Nếu không có userId, có thể để rỗng hoặc hiển thị "Guest" tùy ý
      userId = prefs.getString(LocalStorageKey.userId) ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _showBotMenu(BuildContext context, int index, Offset tapPosition) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

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
          onTap: () {
            Navigator.of(context)
                .push(AnimationModal.fadeInModal(CreateBotModal()));
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.delete, color: ColorConst.backgroundRedColor),
              const SizedBox(width: spacing8),
              Text('Remove Bot',
                  style: TextStyle(color: ColorConst.textRedColor)),
            ],
          ),
          onTap: () {
            // Add remove functionality
          },
        ),
      ],
      elevation: 8,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: spacing44,
        elevation: 1,
        shadowColor: ColorConst.backgroundLightGrayColor,
        backgroundColor: ColorConst.backgroundWhiteColor,
        centerTitle: false,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: ColorConst.primaryColorArray,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            'EcoChatBot',
            style: AppFontStyles.poppinsTitleSemiBold(
                fontSize: fontSize24, color: ColorConst.textWhiteColor),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              // Điều hướng sang SettingsScreen và đợi kết quả trả về
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsScreen()));
              // Sau khi trở về, load lại thông tin người dùng
              _loadUserData();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Profile section
            Container(
              color: ColorConst.backgroundWhiteColor,
              padding: const EdgeInsets.symmetric(vertical: spacing16),
              child: Row(
                children: [
                  const SizedBox(width: spacing20),
                  // Profile image
                  CircleAvatar(
                    radius: spacing40,
                    backgroundImage: AssetImage(AssetPath.logoApp),
                  ),
                  const SizedBox(width: spacing20),
                  // Profile info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email != null && email != "Guest"
                            ? (email!.length > 10
                                ? '${email!.substring(0, 10)}...'
                                : email!)
                            : 'Guest',
                        style: AppFontStyles.poppinsTitleSemiBold(
                            fontSize: fontSize20),
                      ),
                      Text(
                        userId != null && userId!.isNotEmpty
                            ? 'ID ${userId!.length > 5 ? '${userId!.substring(0, 5)}...' : userId!}'
                            : 'ID: ',
                        style: AppFontStyles.poppinsRegular(
                          fontSize: fontSize14,
                          color: ColorConst.textGrayColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // My bots section
            Expanded(
              child: Container(
                color: ColorConst.backgroundGrayColor2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(spacing20),
                      child: Text(
                        'My bots',
                        style: AppFontStyles.poppinsTitleSemiBold(
                            fontSize: fontSize18),
                      ),
                    ),
                    // Dynamically render bot list
                    ...List.generate(MockData.selfAiModels.length, (index) {
                      final bot = MockData.selfAiModels[index];
                      return GestureDetector(
                        onTapUp: (TapUpDetails details) {
                          setState(() {
                            selectedBotIndex = index;
                          });
                          _showBotMenu(context, index, details.globalPosition);
                        },
                        child: AiBotItem(
                          botData: bot,
                          selfAI: true,
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
}
