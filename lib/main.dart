import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const KnittersEyeApp());
}

class KnittersEyeApp extends StatelessWidget {
  const KnittersEyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Knitter's Eye",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4), // Deep purple
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD0BCFF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
