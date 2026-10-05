import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/artworks_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // грузим настройки до запуска, чтобы тема не мигала при старте
  final settings = SettingsProvider();
  final favorites = FavoritesProvider();
  await Future.wait([settings.load(), favorites.load()]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: favorites),
        ChangeNotifierProvider(create: (_) => ArtworksProvider()),
      ],
      child: const ArtApp(),
    ),
  );
}

class ArtApp extends StatelessWidget {
  const ArtApp({super.key});

  ThemeData _theme(Brightness b) => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E3B46),
          brightness: b,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<SettingsProvider>().themeMode;
    return MaterialApp(
      title: 'Art Gallery',
      debugShowCheckedModeBanner: false,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      themeMode: mode,
      home: const HomeScreen(),
    );
  }
}
