import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF3F7FC);

  static const Color title = Color(0xFF172033);
  static const Color subtitle = Color(0xFF64748B);
  static const Color body = Color(0xFF334155);

  static const Color primary = Color(0xFF4F8EF7);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primarySoft = Color(0xFFEAF3FF);

  static const Color sky = Color(0xFF38BDF8);
  static const Color mint = Color(0xFF2DD4BF);
  static const Color purple = Color(0xFF8B5CF6);

  static const Color card = Color(0xFFFFFFFF);
  static const Color cardSoft = Color(0xFFF8FBFF);
  static const Color border = Color(0xFFE2EAF5);

  static const Color lightBlue = Color(0xFFDDEEFF);
  static const Color lightBlue2 = Color(0xFFEAF4FF);

  static const Color chipBackground = Color(0xFFE0F2FE);
  static const Color chipText = Color(0xFF0284C7);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFFFFEEEE);

  static const Color iconGray = Color(0xFF94A3B8);

  static LinearGradient mainGradient = const LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient cardGradient = const LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FBFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient heroGradient = const LinearGradient(
    colors: [Color(0xFF4F8EF7), Color(0xFF38BDF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
