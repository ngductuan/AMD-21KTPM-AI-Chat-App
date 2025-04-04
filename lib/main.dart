import 'package:eco_chat_bot/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eco_chat_bot/src/helpers/local_storage_helper.dart';
import 'package:eco_chat_bot/src/pages/authentication/views/welcome.dart';
import 'package:eco_chat_bot/src/pages/general/views/home.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- Thêm dòng này

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Local storage
  await Hive.initFlutter();
  await LocalStorageHelper.initLocalStorageHelper();

  // Kiểm tra xem đã từng vào app chưa
  final prefs = await SharedPreferences.getInstance();
  final hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;

  runApp(MyApp(
      initialScreen:
          hasSeenWelcome ? const HomeScreen() : const WelcomeScreen()));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Chat Bot',
      debugShowCheckedModeBanner: false,
      routes: routes,
      home: initialScreen,
    );
  }
}
