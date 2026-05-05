import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const AppStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 21),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: AppColors.subtitle,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              height: 1.2,
              fontWeight: FontWeight.w900,
              color: AppColors.title,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}
