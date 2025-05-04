import 'package:eco_chat_bot/src/pages/ai_bot/views/explore.dart';
import 'package:eco_chat_bot/src/pages/authentication/views/login.dart';
import 'package:eco_chat_bot/src/pages/authentication/views/welcome.dart';
import 'package:eco_chat_bot/src/pages/chat/views/chat_list.dart';
import 'package:eco_chat_bot/src/pages/chat/views/chat_thread.dart';
import 'package:eco_chat_bot/src/pages/data/views/data_screen.dart';
import 'package:eco_chat_bot/src/pages/general/views/home.dart';
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

  // Data source
  DataScreen.routeName: (context){
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final bool isGotKnowledgeForEachBot = args['isGotKnowledgeForEachBot'] as bool? ?? false;
    final String assistantId = args['assistantId'] as String;

    return DataScreen(
      isGotKnowledgeForEachBot: isGotKnowledgeForEachBot,
      assistantId: assistantId,
    );
  },

  // Profile
  ProfilePage.routeName: (context) => const ProfilePage(),
};
