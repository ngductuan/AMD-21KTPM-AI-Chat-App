import 'package:eco_chat_bot/src/constants/enum.dart';
import 'package:eco_chat_bot/src/pages/ai_bot/views/explore.dart';
import 'package:eco_chat_bot/src/pages/chat/views/chat_list.dart';
import 'package:eco_chat_bot/src/pages/chat/views/chat_thread.dart';
import 'package:eco_chat_bot/src/pages/profile/views/profile.dart';
import 'package:eco_chat_bot/src/widgets/layouts/bottom_nav_bar.dart';
import 'package:eco_chat_bot/src/widgets/toast/app_toast.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final tabs = [
    ChatListScreen(),
    ExploreScreen(),
    const Center(child: Text('Create')),
    const Center(child: Text('Message')),
    ProfilePage(),
  ];

  void onTabChanged(int page) {
    if (page == 2) {
      Navigator.of(context).pushNamed(ChatThreadScreen.routeName, arguments: {'chatStatus': ChatThreadStatus.new_});
      return;
    } else if (page == 3) {
      AppToast(
        context: context,
        message: 'Coming soon!',
        mode: AppToastMode.info,
      ).show(context);
      return;
    }

    setState(() {
      _currentIndex = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: AppBottomNavBar(onTabChanged: onTabChanged),
    );
  }
}
