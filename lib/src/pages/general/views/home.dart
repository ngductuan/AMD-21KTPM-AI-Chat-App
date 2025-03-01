import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static String routeName = '/home_view';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  final tabs = [
    const Center(child: Text('Account')),
    const Center(child: Text('Setting'))
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
      // bottomNavigationBar: AppBottomNavBar(onTabChanged: onTabChanged),
    );
  }
}
