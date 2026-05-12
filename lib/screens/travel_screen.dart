import 'package:flutter/material.dart';
import '../models/destination_candidate.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_summary_card.dart';
import 'add_destination_screen.dart';

class TravelScreen extends StatefulWidget {
  final int tripRoomId;

  const TravelScreen({super.key, required this.tripRoomId});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  late Future<List<DestinationCandidate>> destinationFuture;

  @override
  void initState() {
    super.initState();
    destinationFuture = ApiService.getDestinationCandidatesByTripRoomId(
      widget.tripRoomId,
    );
  }

  @override
  void didUpdateWidget(covariant TravelScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tripRoomId != widget.tripRoomId) {
      refreshDestinations();
    }
  }

  void refreshDestinations() {
    setState(() {
      destinationFuture = ApiService.getDestinationCandidatesByTripRoomId(
        widget.tripRoomId,
      );
    });
  }

  Future<void> moveToAddDestinationScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddDestinationScreen(tripRoomId: widget.tripRoomId),
      ),
    );

    if (result == true) {
      refreshDestinations();
    }
  }

  Future<void> moveToEditDestinationScreen(DestinationCandidate item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDestinationScreen(
          tripRoomId: item.tripRoomId,
          destinationCandidate: item,
        ),
      ),
    );

    if (result == true) {
      refreshDestinations();
    }
  }

  Future<void> deleteDestination(DestinationCandidate item) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('여행지 후보 삭제'),
        content: Text('${item.name} 후보를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result != true) {
      return;
    }

    try {
      await ApiService.deleteDestinationCandidate(item.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('여행지 후보가 삭제되었습니다.')));

      refreshDestinations();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('여행지 후보 삭제 실패: $e')));
    }
  }

  Future<void> voteDestination(DestinationCandidate item) async {
    try {
      await ApiService.voteDestinationCandidate(item.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('투표가 완료되었습니다.')));

      refreshDestinations();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('투표 실패: $e')));
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                const AppSectionHeader(
                  title: '여행지 후보',
                  subtitle: '선택한 여행방의 후보지를 등록하고 투표로 선택해보세요',
                ),
                const SizedBox(height: 24),
                AppSummaryCard(
                  icon: Icons.map_rounded,
                  title: '선택한 여행 후보지',
                  line1: '여행방 번호 ${widget.tripRoomId}',
                  line2: '총 ${destinations.length}개의 후보지가 등록되어 있습니다',
                ),
                const SizedBox(height: 24),
                _buildListTitle('후보 목록'),
                const SizedBox(height: 14),
                if (destinations.isEmpty)
                  _buildEmptyCard('등록된 여행지 후보가 없습니다.')
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
                  icon: Icons.add_location_alt_rounded,
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
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.07),
            blurRadius: 22,
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
                  Icons.place_rounded,
                  color: AppColors.primaryDark,
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
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                        color: AppColors.title,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.region,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.subtitle,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              _buildVoteChip(item.votes),
            ],
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppColors.subtitle,
                letterSpacing: -0.2,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTextActionButton(
                text: '수정',
                icon: Icons.edit_rounded,
                color: AppColors.primaryDark,
                onPressed: () {
                  moveToEditDestinationScreen(item);
                },
              ),
              const SizedBox(width: 14),
              _buildTextActionButton(
                text: '삭제',
                icon: Icons.delete_outline_rounded,
                color: AppColors.danger,
                onPressed: () {
                  deleteDestination(item);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.mainGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  voteDestination(item);
                },
                icon: const Icon(Icons.thumb_up_alt_rounded, size: 18),
                label: const Text('투표하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(text),
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildVoteChip(int votes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$votes표',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.chipText,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildListTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w900,
        color: AppColors.title,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildEmptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.subtitle,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
