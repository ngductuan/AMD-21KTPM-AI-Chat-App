import 'package:eco_chat_bot/routes.dart';
import 'package:eco_chat_bot/src/helpers/local_storage_helper.dart';
import 'package:eco_chat_bot/src/pages/authentication/views/login.dart';
import 'package:eco_chat_bot/src/pages/general/views/home.dart';
import 'package:eco_chat_bot/src/pages/prompt/prompt_libary.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  // Local storage
  await Hive.initFlutter();
  await LocalStorageHelper.initLocalStorageHelper();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo', debugShowCheckedModeBanner: false, routes: routes, home: const HomeScreen());
  }
}
