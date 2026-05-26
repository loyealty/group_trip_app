import 'package:flutter/material.dart';
import '../models/destination_candidate.dart';
import '../models/trip_room.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_summary_card.dart';
import 'add_destination_screen.dart';
import 'add_schedule_screen.dart';

class TravelScreen extends StatefulWidget {
  final int tripRoomId;
  final AppUser loginUser;

  const TravelScreen({
    super.key,
    required this.tripRoomId,
    required this.loginUser,
  });

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  late Future<List<DestinationCandidate>> destinationFuture;
  bool isOwner = false;
  bool isPermissionLoading = false;

  @override
  void initState() {
    super.initState();
    destinationFuture = _loadDestinations();
    loadOwnerPermission();
  }

  Future<List<DestinationCandidate>> _loadDestinations() {
    if (widget.tripRoomId == 0) {
      return Future.value([]);
    }

    return ApiService.getDestinationCandidatesByTripRoomId(widget.tripRoomId);
  }

  Future<void> loadOwnerPermission() async {
    if (widget.tripRoomId == 0) {
      setState(() {
        isOwner = false;
      });
      return;
    }

    setState(() {
      isPermissionLoading = true;
    });

    try {
      final TripRoom tripRoom = await ApiService.getTripRoomById(
        widget.tripRoomId,
      );

      if (!mounted) return;

      setState(() {
        isOwner = tripRoom.ownerId == widget.loginUser.id;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isOwner = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          isPermissionLoading = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant TravelScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tripRoomId != widget.tripRoomId) {
      refreshDestinations();
      loadOwnerPermission();
    }
  }

  void refreshDestinations() {
    setState(() {
      destinationFuture = _loadDestinations();
    });
  }

  Future<void> moveToAddDestinationScreen() async {
    if (widget.tripRoomId == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('먼저 홈 화면에서 여행방을 선택해주세요.')));
      return;
    }

    if (!isOwner) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('방장만 여행지 후보를 추가할 수 있습니다.')));
      return;
    }

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
    if (!isOwner) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('방장만 여행지 후보를 수정할 수 있습니다.')));
      return;
    }

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

  Future<void> moveToAddScheduleFromDestination(
    DestinationCandidate item,
  ) async {
    if (!isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방장만 확정 여행지를 일정에 추가할 수 있습니다.')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddScheduleScreen(
          tripRoomId: item.tripRoomId,
          initialTitle: '${item.name} 방문',
          initialLocation: item.name,
          initialDescription: '확정된 여행지 방문 일정',
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('확정 여행지가 일정에 추가되었습니다.')));
    }
  }

  Future<void> deleteDestination(DestinationCandidate item) async {
    if (!isOwner) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('방장만 여행지 후보를 삭제할 수 있습니다.')));
      return;
    }

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

  Future<void> voteDestination(
    DestinationCandidate item,
    bool isVoteClosed,
  ) async {
    if (isVoteClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최종 여행지가 확정되어 투표가 마감되었습니다.')),
      );
      return;
    }

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

  Future<void> confirmDestination(DestinationCandidate item) async {
    if (!isOwner) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('방장만 최종 여행지를 확정할 수 있습니다.')));
      return;
    }

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('여행지 확정'),
        content: Text('${item.name} 후보를 최종 여행지로 확정할까요?'),
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
            child: const Text('확정'),
          ),
        ],
      ),
    );

    if (result != true) {
      return;
    }

    try {
      await ApiService.confirmDestinationCandidate(item.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${item.name} 여행지가 확정되었습니다.')));

      refreshDestinations();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('여행지 확정 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tripRoomId == 0) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              const AppSectionHeader(
                title: '여행지 후보',
                subtitle: '여행방을 선택하면 후보지를 확인할 수 있어요',
              ),
              const SizedBox(height: 24),
              _buildEmptyCard('선택된 여행방이 없습니다.\n홈 화면에서 여행방을 먼저 선택해주세요.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<DestinationCandidate>>(
          future: destinationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                isPermissionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('에러: ${snapshot.error}'));
            }

            final destinations = snapshot.data ?? [];
            final confirmedDestinations = destinations
                .where((item) => item.confirmed)
                .toList();
            final bool isVoteClosed = confirmedDestinations.isNotEmpty;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                AppSectionHeader(
                  title: '여행지 후보',
                  subtitle: isOwner
                      ? '방장은 후보를 관리하고 최종 여행지를 확정할 수 있어요'
                      : '참여자는 여행지 후보를 확인하고 투표할 수 있어요',
                ),
                const SizedBox(height: 14),
                _buildRoleInfoCard(),
                const SizedBox(height: 18),
                AppSummaryCard(
                  icon: Icons.map_rounded,
                  title: '선택한 여행 후보지',
                  line1: confirmedDestinations.isEmpty
                      ? '아직 확정된 여행지가 없습니다'
                      : '확정 여행지 ${confirmedDestinations.first.name}',
                  line2: isVoteClosed
                      ? '최종 여행지가 확정되어 투표가 마감되었습니다'
                      : '총 ${destinations.length}개의 후보지가 등록되어 있습니다',
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
                      child: _buildDestinationCard(item, isVoteClosed),
                    ),
                  ),
                const SizedBox(height: 10),
                if (isOwner)
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

  Widget _buildRoleInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            isOwner ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
            color: AppColors.primaryDark,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isOwner
                  ? '현재 계정은 이 여행방의 방장입니다. 후보 추가, 수정, 삭제, 확정이 가능합니다.'
                  : '현재 계정은 참여자입니다. 여행지 후보 조회와 투표만 가능합니다.',
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.subtitle,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(DestinationCandidate item, bool isVoteClosed) {
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
        border: Border.all(
          color: item.confirmed ? AppColors.primaryDark : AppColors.border,
          width: item.confirmed ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.confirmed) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.chipBackground,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '확정된 여행지',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.chipText,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
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
                child: Icon(
                  item.confirmed ? Icons.verified_rounded : Icons.place_rounded,
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
          if (isOwner)
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
                const SizedBox(width: 14),
                _buildTextActionButton(
                  text: item.confirmed ? '확정됨' : '확정',
                  icon: item.confirmed
                      ? Icons.verified_rounded
                      : Icons.check_circle_rounded,
                  color: item.confirmed
                      ? AppColors.subtitle
                      : AppColors.primaryDark,
                  onPressed: item.confirmed
                      ? () {}
                      : () {
                          confirmDestination(item);
                        },
                ),
              ],
            ),
          if (item.confirmed && isOwner) ...[
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
                    moveToAddScheduleFromDestination(item);
                  },
                  icon: const Icon(Icons.event_available_rounded, size: 18),
                  label: const Text('일정에 추가'),
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: isVoteClosed
                    ? const LinearGradient(
                        colors: [Color(0xFFE5E7EB), Color(0xFFD1D5DB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : AppColors.mainGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isVoteClosed
                        ? Colors.black.withOpacity(0.06)
                        : AppColors.primary.withOpacity(0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: isVoteClosed
                    ? null
                    : () {
                        voteDestination(item, isVoteClosed);
                      },
                icon: Icon(
                  isVoteClosed
                      ? Icons.lock_rounded
                      : Icons.thumb_up_alt_rounded,
                  size: 18,
                ),
                label: Text(isVoteClosed ? '투표 마감' : '투표하기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
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
          height: 1.5,
        ),
      ),
    );
  }
}
