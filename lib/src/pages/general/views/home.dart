import 'package:eco_chat_bot/src/pages/ai_bot/views/explore.dart';
import 'package:eco_chat_bot/src/pages/chat/views/chat_list.dart';
import 'package:eco_chat_bot/src/widgets/layouts/bottom_nav_bar.dart';
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
    const Center(child: Text('Me'))
  ];

  void onTabChanged(int page) {
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
