import 'package:flutter/material.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_summary_card.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ScheduleItem> schedules = [
      const ScheduleItem(
        date: '4/10',
        time: '10:00',
        title: '부산 도착 및 체크인',
        location: '해운대 호텔',
        description: '숙소 체크인 후 근처 카페 방문',
      ),
      const ScheduleItem(
        date: '4/11',
        time: '09:30',
        title: '광안리 해수욕장',
        location: '광안리',
        description: '해변 산책 및 점심 식사',
      ),
      const ScheduleItem(
        date: '4/11',
        time: '15:00',
        title: '해동용궁사 방문',
        location: '기장',
        description: '사진 촬영 및 자유 일정',
      ),
      const ScheduleItem(
        date: '4/12',
        time: '11:00',
        title: '브런치 후 복귀',
        location: '서면',
        description: '브런치 후 서울로 이동',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const AppSectionHeader(
              title: '여행 일정',
              subtitle: '현재 등록된 일정을 확인해보세요',
            ),
            const SizedBox(height: 24),
            AppSummaryCard(
              icon: Icons.calendar_month_rounded,
              title: '부산 여행 일정',
              line1: '2026.04.10 ~ 2026.04.12',
              line2: '총 ${schedules.length}개의 일정이 등록되어 있습니다',
            ),
            const SizedBox(height: 24),
            const Text(
              '일정 목록',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A3A),
              ),
            ),
            const SizedBox(height: 14),
            ...schedules.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildScheduleCard(item),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF60A5FA),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '일정 추가',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5EEF9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.time,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A3A),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 16,
                      color: Color(0xFF60A5FA),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.location,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5B8EC5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduleItem {
  final String date;
  final String time;
  final String title;
  final String location;
  final String description;

  const ScheduleItem({
    required this.date,
    required this.time,
    required this.title,
    required this.location,
    required this.description,
  });
}
