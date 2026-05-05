import 'package:flutter/material.dart';
import '../models/trip_room.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onScheduleButtonPressed;

  const HomeScreen({super.key, required this.onScheduleButtonPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<TripRoom>>(
          future: ApiService.getTripRooms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('에러: ${snapshot.error}'));
            }

            final tripRooms = snapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroHeader(),
                  const SizedBox(height: 22),
                  _buildSectionTitle('나의 여행방', '진행 중인 그룹 여행을 확인해보세요'),
                  const SizedBox(height: 12),
                  if (tripRooms.isEmpty)
                    _buildEmptyTripCard()
                  else
                    ...tripRooms.map((trip) => _buildTripCard(trip)),
                  const SizedBox(height: 24),
                  _buildQuickSection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('여행 준비 현황', '일정과 정산 상태를 한눈에 확인해요'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.calendar_today_rounded,
                    title: '다가오는 일정',
                    subtitle: '등록된 일정을 확인하고 여행 계획을 정리해보세요.',
                    badgeText: '일정',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.account_balance_wallet_rounded,
                    title: '비용 정산',
                    subtitle: '여행 비용과 분담 내역을 관리할 수 있어요.',
                    badgeText: '정산',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -26,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.13),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: -42,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.11),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.28)),
                ),
                child: const Text(
                  'GROUP TRIP PLANNER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '함께 계획하고,\n함께 떠나는 여행',
                style: TextStyle(
                  fontSize: 27,
                  height: 1.18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '일정, 여행지 후보, 비용 정산까지\n한 번에 관리해보세요.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.86),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(TripRoom trip) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEAF4FF), Color(0xFFDCEBFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.flight_takeoff_rounded,
                  color: AppColors.primaryDark,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: AppColors.title,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      trip.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.subtitle,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(_getKoreanStatus(trip.status)),
            ],
          ),
          const SizedBox(height: 18),
          _buildDetailBox(
            icon: Icons.place_rounded,
            label: '여행지',
            value: trip.destination,
          ),
          const SizedBox(height: 10),
          _buildDetailBox(
            icon: Icons.date_range_rounded,
            label: '여행 기간',
            value:
                '${_formatDate(trip.startDate)} ~ ${_formatDate(trip.endDate)}',
          ),
          const SizedBox(height: 18),
          AppPrimaryButton(
            text: '일정 조율하기',
            icon: Icons.arrow_forward_rounded,
            onPressed: onScheduleButtonPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSection() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickCard(
            icon: Icons.event_available_rounded,
            title: '일정',
            value: '공동 관리',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickCard(
            icon: Icons.how_to_vote_rounded,
            title: '여행지',
            value: '투표 선택',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickCard(
            icon: Icons.payments_rounded,
            title: '정산',
            value: '비용 관리',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 23),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.subtitle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.title,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTripCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Text(
          '여행방 데이터가 없습니다.',
          style: TextStyle(fontSize: 15, color: AppColors.subtitle),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.title,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.subtitle,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badgeText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.chipText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBox({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryDark),
          const SizedBox(width: 9),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.body,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.subtitle,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.chipText,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: AppColors.title,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.subtitle,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  String _getKoreanStatus(String status) {
    switch (status) {
      case 'PLANNING':
        return '계획 중';
      case 'CONFIRMED':
        return '확정';
      case 'COMPLETED':
        return '완료';
      default:
        return status;
    }
  }

  String _formatDate(String date) {
    return date.replaceAll('-', '.');
  }
}
