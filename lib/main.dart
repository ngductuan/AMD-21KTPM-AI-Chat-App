import 'package:eco_chat_bot/firebase_options.dart';
import 'package:eco_chat_bot/routes.dart';
// import 'package:eco_chat_bot/src/constants/api/env_key.dart';
import 'package:eco_chat_bot/src/constants/share_preferences/local_storage_key.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:eco_chat_bot/src/helpers/local_storage_helper.dart';
import 'package:eco_chat_bot/src/pages/authentication/views/welcome.dart';
import 'package:eco_chat_bot/src/pages/general/views/home.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- Thêm dòng này

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Check required variables
  // if (dotenv.get(EnvKey.authApi).isEmpty) {
  //   throw Exception('${EnvKey.authApi} is missing in .env');
  // }

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Local storage
    await Hive.initFlutter();
    await LocalStorageHelper.initLocalStorageHelper();

    // Check if user has seen welcome screen
    final prefs = await SharedPreferences.getInstance();
    final hasSeenWelcome = prefs.getBool(LocalStorageKey.hasSeenWelcome) ?? false;

    runApp(MyApp(
      initialScreen: hasSeenWelcome ? const HomeScreen() : const WelcomeScreen(),
    ));
  } catch (e) {
    // Handle initialization errors
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app: $e'),
          ),
        ),
      ),
    );
  }
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
