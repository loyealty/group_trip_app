import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(title: '일정', icon: Icons.calendar_month_rounded);
  }
}

class SimplePage extends StatelessWidget {
  final String title;
  final IconData icon;

  const SimplePage({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: const Color(0xFF7AB6F9)),
            const SizedBox(height: 16),
            Text(
              '$title 페이지',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
