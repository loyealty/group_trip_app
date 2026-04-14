import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_menu_card.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_stat_card.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const AppSectionHeader(
              title: '마이 페이지',
              subtitle: '내 여행 정보와 활동 내역을 확인해보세요',
            ),
            const SizedBox(height: 24),
            _buildProfileCard(),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: AppStatCard(
                    icon: Icons.card_travel_rounded,
                    title: '참여 중 여행',
                    value: '3개',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: AppStatCard(
                    icon: Icons.payments_rounded,
                    title: '등록한 지출',
                    value: '5건',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '내 메뉴',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 14),
            const AppMenuCard(
              icon: Icons.group_rounded,
              title: '내 여행방 관리',
              subtitle: '참여 중인 여행방과 초대 내역을 확인할 수 있어요',
            ),
            const SizedBox(height: 12),
            const AppMenuCard(
              icon: Icons.notifications_rounded,
              title: '알림 설정',
              subtitle: '일정 변경, 초대 요청, 정산 알림을 관리할 수 있어요',
            ),
            const SizedBox(height: 12),
            const AppMenuCard(
              icon: Icons.settings_rounded,
              title: '앱 설정',
              subtitle: '테마, 계정, 기타 설정을 변경할 수 있어요',
            ),
            const SizedBox(height: 12),
            const AppMenuCard(
              icon: Icons.help_outline_rounded,
              title: '도움말',
              subtitle: '서비스 이용 방법과 자주 묻는 질문을 확인할 수 있어요',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '로그아웃',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF7FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primaryDark,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '김지윤',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'group_trip_user@email.com',
                  style: TextStyle(fontSize: 14, color: AppColors.subtitle),
                ),
                SizedBox(height: 6),
                Text(
                  '함께하는 여행을 더 편하게 관리해보세요',
                  style: TextStyle(fontSize: 13, color: AppColors.subtitle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
