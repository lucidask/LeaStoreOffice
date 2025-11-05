import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ pour les délégations
import 'package:lea_store_office/screens/lock_screen.dart';
import 'package:lea_store_office/screens/home_screen.dart';
import 'package:lea_store_office/widgets/app_initialiser.dart';
import 'package:provider/provider.dart';
import 'package:lea_store_office/theme/theme.dart'; // ✅ ton fichier de thème
import 'package:lea_store_office/providers/theme_provider.dart'; // ✅ ton provider

class MyApp extends StatelessWidget {
  final bool isLocked;

  const MyApp({super.key, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    // App initialization après le premier build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppInitializer.run(context);
    });

    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lea Store Office',
      theme: AppThemes.lightTheme, // ✅ Thème clair personnalisé
      darkTheme: AppThemes.darkTheme, // ✅ Thème sombre personnalisé
      themeMode: themeProvider.themeMode, // ✅ Dynamique selon le provider
      initialRoute: isLocked ? '/lock' : '/home',
      routes: {
        '/lock': (_) => const LockScreen(),
        '/home': (_) => const HomeScreen(),
      },
      supportedLocales: const [
        Locale('fr', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('fr'),
    );
  }
}
