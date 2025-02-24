import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/learning_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'NeuroLearn',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: settings.darkMode ? Brightness.dark : Brightness.light,
              fontFamily: 'Poppins',
              scaffoldBackgroundColor: settings.darkMode ? Colors.grey[900] : Colors.white,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4A90E2),
                primary: const Color(0xFF4A90E2),
                secondary: const Color(0xFF7C4DFF),
                background: settings.darkMode ? Colors.grey[900]! : Colors.white,
                brightness: settings.darkMode ? Brightness.dark : Brightness.light,
              ),
              useMaterial3: true,
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
