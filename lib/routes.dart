import 'package:eco_chat_bot/src/constants/enum.dart';
import 'package:eco_chat_bot/src/emails/pages/email_thread.dart';
import 'package:eco_chat_bot/src/integration/views/app_integration.dart';
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
  ChatThreadScreen.routeName: (context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String conversationId = args['id'] ?? '';
    final String avatarPath = args['avatarPath'] ?? '';
    final String title = args['title'] ?? '';
    final ChatThreadStatus chatStatus = args['chatStatus'] ?? ChatThreadStatus.new_;
    final String botId = args['botId'] ?? '';

    return ChatThreadScreen(
      conversationId: conversationId,
      avatarPath: avatarPath,
      title: title,
      chatStatus: chatStatus,
      botId: botId,
    );
  },

  // Email
  EmailThreadScreen.routeName: (context) => const EmailThreadScreen(),

  // Explore
  ExploreScreen.routeName: (context) => const ExploreScreen(),

  // Data source
  DataScreen.routeName: (context) {
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

  // Integration
  AppIntegration.routeName: (context) => const AppIntegration(),
};
