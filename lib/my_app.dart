import 'package:flutter/material.dart';
import 'package:lea_store_office/screens/lock_screen.dart';
import 'package:lea_store_office/screens/home_screen.dart';
import 'package:lea_store_office/widgets/app_initialiser.dart';

class MyApp extends StatelessWidget {
  final bool isLocked;

  const MyApp({super.key, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppInitializer.run(context);
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lea Store Office',
      theme: ThemeData.light(),
      initialRoute: isLocked ? '/lock' : '/home',
      routes: {
        '/lock': (_) => const LockScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}

