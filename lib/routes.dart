import 'package:eco_chat_bot/src/pages/authentication/views/welcome.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  // // Introduction
  // SplashView.routeName: (context) => const SplashView(),
  // IntroView.routeName: (context) => const IntroView(),

  // // Authentication
  // SignInView.routeName: (context) => const SignInView(),
  // SignUpView.routeName: (context) => const SignUpView(),
  // ResetPasswordView.routeName: (context) => const ResetPasswordView(),

  // Home
  WelcomePage.routeName: (context) => const WelcomePage(),
};
