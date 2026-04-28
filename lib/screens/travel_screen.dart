import 'package:flutter/material.dart';
import '../models/destination_candidate.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_summary_card.dart';
import 'add_destination_screen.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  late Future<List<DestinationCandidate>> destinationFuture;

  @override
  void initState() {
    super.initState();
    destinationFuture = ApiService.getDestinationCandidatesByTripRoomId(1);
  }

  void refreshDestinations() {
    setState(() {
      destinationFuture = ApiService.getDestinationCandidatesByTripRoomId(1);
    });
  }

  Future<void> moveToAddDestinationScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddDestinationScreen(tripRoomId: 1),
      ),
    );

    if (result == true) {
      refreshDestinations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<DestinationCandidate>>(
          future: destinationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('에러: ${snapshot.error}'));
            }

            final destinations = snapshot.data ?? [];

            return ListView(
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
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 14),
                if (destinations.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      '등록된 여행지 후보가 없습니다.',
                      style: TextStyle(fontSize: 14, color: AppColors.subtitle),
                    ),
                  )
                else
                  ...destinations.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildDestinationCard(item),
                    ),
                  ),
                const SizedBox(height: 10),
                AppPrimaryButton(
                  text: '여행지 후보 추가',
                  onPressed: moveToAddDestinationScreen,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDestinationCard(DestinationCandidate item) {
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
        border: Border.all(color: AppColors.border),
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
                  color: AppColors.lightBlue2,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.place_rounded,
                  color: AppColors.primary,
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
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.region,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.subtitle,
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
            style: const TextStyle(fontSize: 14, color: AppColors.subtitle),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
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
                    backgroundColor: AppColors.primary,
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
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$votes표',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.chipText,
        ),
      ),
    );
  }
}
