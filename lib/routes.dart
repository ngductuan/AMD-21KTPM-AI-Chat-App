import 'package:eco_chat_bot/src/pages/authentication/views/login.dart';
import 'package:eco_chat_bot/src/pages/authentication/views/welcome.dart';
import 'package:eco_chat_bot/src/pages/chat/views/chat_list.dart';
import 'package:eco_chat_bot/src/pages/general/views/home.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  // General
  HomeScreen.routeName: (context) => const HomeScreen(),

  // Authentication
  WelcomeScreen.routeName: (context) => const WelcomeScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),

  // Chat
  ChatListScreen.routeName: (context) => const ChatListScreen(),
};
