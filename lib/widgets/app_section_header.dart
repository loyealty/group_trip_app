import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AppSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w900,
              color: AppColors.title,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: AppColors.subtitle,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
