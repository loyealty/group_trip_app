import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GroupTripApp());
}

class GroupTripApp extends StatelessWidget {
  const GroupTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Group Trip',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8EC5FF),
          brightness: Brightness.light,
        ),
        fontFamily: 'sans-serif',
      ),
      home: const MainHomeScreen(),
    );
  }
}
