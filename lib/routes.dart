import 'package:eco_chat_bot/src/pages/authentication/views/login.dart';
import 'package:eco_chat_bot/src/pages/authentication/views/welcome.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  // // Authentication
  WelcomeScreen.routeName: (context) => const WelcomeScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),

  // Chat

};
