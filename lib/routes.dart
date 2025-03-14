import 'package:eco_chat_bot/src/pages/ai_bot/views/explore.dart';
import 'package:eco_chat_bot/src/pages/authentication/views/login.dart';
import 'package:eco_chat_bot/src/pages/authentication/views/welcome.dart';
import 'package:eco_chat_bot/src/pages/chat/views/chat_list.dart';
import 'package:eco_chat_bot/src/pages/chat/views/chat_thread.dart';
import 'package:eco_chat_bot/src/pages/general/views/home.dart';
import 'package:eco_chat_bot/src/pages/knowledge_source/widgets/select_knowledge_source_popup.dart';
import 'package:eco_chat_bot/src/pages/profile/views/profile.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  // General
  HomeScreen.routeName: (context) => const HomeScreen(),

  // Authentication
  WelcomeScreen.routeName: (context) => const WelcomeScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),

  // Chat
  ChatListScreen.routeName: (context) => const ChatListScreen(),
  ChatThreadScreen.routeName: (context) => const ChatThreadScreen(),

  // Explore
  ExploreScreen.routeName: (context) => const ExploreScreen(),

  // Profile
  ProfilePage.routeName: (context) => const ProfilePage(),
};
