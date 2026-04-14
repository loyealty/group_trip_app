import 'package:flutter/material.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_summary_card.dart';

class TravelScreen extends StatelessWidget {
  const TravelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DestinationItem> destinations = [
      const DestinationItem(
        name: '해운대 해수욕장',
        region: '부산 해운대구',
        description: '바다 풍경과 산책을 즐기기 좋은 대표 여행지',
        votes: 4,
      ),
      const DestinationItem(
        name: '광안리 해수욕장',
        region: '부산 수영구',
        description: '야경과 맛집이 많아 저녁 일정으로 좋은 장소',
        votes: 3,
      ),
      const DestinationItem(
        name: '해동용궁사',
        region: '부산 기장군',
        description: '바다와 함께 볼 수 있는 유명한 사찰 명소',
        votes: 2,
      ),
      const DestinationItem(
        name: '감천문화마을',
        region: '부산 사하구',
        description: '사진 촬영과 산책 코스로 인기 있는 여행지',
        votes: 1,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const AppSectionHeader(
              title: '여행지 후보',
              subtitle: '함께 갈 여행지를 비교하고 선택해보세요',
            ),
            const SizedBox(height: 24),
            AppSummaryCard(
              icon: Icons.map_rounded,
              title: '부산 여행 후보지',
              line1: '투표를 통해 여행지를 정할 수 있어요',
              line2: '총 ${destinations.length}개의 후보지가 등록되어 있습니다',
            ),
            const SizedBox(height: 24),
            const Text(
              '후보 목록',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A3A),
              ),
            ),
            const SizedBox(height: 14),
            ...destinations.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildDestinationCard(item),
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
                  '여행지 후보 추가',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(DestinationItem item) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.place_rounded,
                  color: Color(0xFF60A5FA),
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2A3A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.region,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              _buildVoteChip(item.votes),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.description,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF60A5FA),
                    side: const BorderSide(color: Color(0xFFBFDBFE)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '상세 보기',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF60A5FA),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '투표하기',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoteChip(int votes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$votes표',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0284C7),
        ),
      ),
    );
  }
}

class DestinationItem {
  final String name;
  final String region;
  final String description;
  final int votes;

  const DestinationItem({
    required this.name,
    required this.region,
    required this.description,
    required this.votes,
  });
}
