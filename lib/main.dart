import 'package:eco_chat_bot/routes.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        // theme: getThemeData(context, isDarkTheme: false),
        debugShowCheckedModeBanner: false,
        routes: routes,
        home: const SizedBox());
  }
}
