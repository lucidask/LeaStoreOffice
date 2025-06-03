import 'package:flutter/material.dart';
import 'package:lea_store_office/screens/lock_screen.dart';
import 'package:lea_store_office/screens/home_screen.dart';

class MyApp extends StatelessWidget {
  final bool isLocked;

  const MyApp({super.key, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lea Store Office',
      theme: ThemeData.light(), // À adapter avec tes thèmes
      initialRoute: isLocked ? '/lock' : '/home',
      routes: {
        '/lock': (_) => const LockScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
