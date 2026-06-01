import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/destination_candidate.dart';
import '../models/trip_room.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';
import 'trip_room_create_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppUser loginUser;
  final int selectedTripRoomId;
  final void Function(int tripRoomId, String tripRoomTitle) onTripRoomSelected;
  final VoidCallback onTripRoomClear;
  final VoidCallback onScheduleButtonPressed;

  const HomeScreen({
    super.key,
    required this.loginUser,
    required this.selectedTripRoomId,
    required this.onTripRoomSelected,
    required this.onTripRoomClear,
    required this.onScheduleButtonPressed,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<TripRoom>> tripRoomsFuture;

  @override
  void initState() {
    super.initState();
    tripRoomsFuture = ApiService.getTripRoomsByUserId(widget.loginUser.id);
  }

  void refreshTripRooms() {
    setState(() {
      tripRoomsFuture = ApiService.getTripRoomsByUserId(widget.loginUser.id);
    });
  }

  Future<void> moveToCreateTripRoom() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripRoomCreateScreen(loginUser: widget.loginUser),
      ),
    );

    if (result == true) {
      refreshTripRooms();
    }
  }

  Future<void> moveToEditTripRoom(TripRoom trip) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TripRoomCreateScreen(loginUser: widget.loginUser, tripRoom: trip),
      ),
    );

    if (result == true) {
      refreshTripRooms();
    }
  }

  Future<void> showJoinTripRoomDialog() async {
    String inviteCode = '';

    final String? result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('여행방 참여'),
          content: TextField(
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: '초대 코드',
              hintText: '예: A7K92Q',
            ),
            onChanged: (value) {
              inviteCode = value.trim().toUpperCase();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (inviteCode.isNotEmpty) {
                  Navigator.pop(dialogContext, inviteCode);
                }
              },
              child: const Text('참여'),
            ),
          ],
        );
      },
    );

    if (result == null || result.trim().isEmpty) {
      return;
    }

    try {
      final joinedTripRoom = await ApiService.joinTripRoomByInviteCode(
        inviteCode: result.trim().toUpperCase(),
        userId: widget.loginUser.id,
        memberName: widget.loginUser.name,
      );

      if (!mounted) return;

      widget.onTripRoomSelected(joinedTripRoom.id, joinedTripRoom.title);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${joinedTripRoom.title} 여행방에 참여했습니다.')),
      );

      refreshTripRooms();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('여행방 참여 실패: $e')));
    }
  }

  Future<void> deleteTripRoom(TripRoom trip) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('여행방 삭제'),
          content: Text(
            '${trip.title} 여행방을 삭제할까요?\n관련 일정, 여행지 후보, 정산 내역, 멤버 정보도 함께 삭제됩니다.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    try {
      await ApiService.deleteTripRoom(trip.id);

      if (!mounted) return;

      if (trip.id == widget.selectedTripRoomId) {
        widget.onTripRoomClear();
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('여행방이 삭제되었습니다.')));

      refreshTripRooms();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('여행방 삭제 실패: $e')));
    }
  }

  void openTripSchedule(TripRoom trip) {
    widget.onTripRoomSelected(trip.id, trip.title);
    widget.onScheduleButtonPressed();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${trip.title} 여행방을 선택했습니다.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void copyInviteCode(String inviteCode) {
    if (inviteCode.isEmpty) {
      return;
    }

    Clipboard.setData(ClipboardData(text: inviteCode));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('초대 코드 $inviteCode 복사 완료')));
  }

  Future<DestinationCandidate?> getConfirmedDestination(int tripRoomId) async {
    final candidates = await ApiService.getDestinationCandidatesByTripRoomId(
      tripRoomId,
    );

    final confirmedList = candidates
        .where((candidate) => candidate.confirmed)
        .toList();

    if (confirmedList.isEmpty) {
      return null;
    }

    return confirmedList.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<TripRoom>>(
          future: tripRoomsFuture,
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
                  const SizedBox(height: 20),
                  _buildTripActionButtons(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('나의 여행방', '내가 만들거나 참여한 그룹 여행을 선택해보세요'),
                  const SizedBox(height: 12),
                  if (tripRooms.isEmpty)
                    _buildEmptyTripCard()
                  else
                    ...tripRooms.map((trip) => _buildTripCard(trip)),
                  const SizedBox(height: 24),
                  _buildQuickSection(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('여행 준비 현황', '선택한 여행방의 정보를 확인해요'),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.calendar_today_rounded,
                    title: '다가오는 일정',
                    subtitle: '선택한 여행방의 일정을 확인해요.',
                    badgeText: '일정',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.account_balance_wallet_rounded,
                    title: '비용 정산',
                    subtitle: '선택한 여행방의 정산 내역을 확인해요.',
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -24,
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 34,
            bottom: -38,
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(0.28)),
                ),
                child: const Text(
                  'GROUP TRIP PLANNER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${widget.loginUser.name}님의 여행',
                style: const TextStyle(
                  fontSize: 25,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '여행방을 만들거나 초대 코드로 참여해보세요.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
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

  Widget _buildTripActionButtons() {
    return Row(
      children: [
        Expanded(child: _buildCreateTripButton()),
        const SizedBox(width: 12),
        Expanded(child: _buildJoinTripButton()),
      ],
    );
  }

  Widget _buildCreateTripButton() {
    return InkWell(
      onTap: moveToCreateTripRoom,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 106,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A5F).withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.add_circle_rounded, color: AppColors.primaryDark),
            Spacer(),
            Text(
              '새 여행방',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.title,
              ),
            ),
            SizedBox(height: 3),
            Text(
              '직접 만들기',
              style: TextStyle(fontSize: 12, color: AppColors.subtitle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinTripButton() {
    return InkWell(
      onTap: showJoinTripRoomDialog,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 106,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A5F).withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.link_rounded, color: AppColors.primaryDark),
            Spacer(),
            Text(
              '여행방 참여',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.title,
              ),
            ),
            SizedBox(height: 3),
            Text(
              '초대 코드 입력',
              style: TextStyle(fontSize: 12, color: AppColors.subtitle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard(TripRoom trip) {
    final bool isSelected = trip.id == widget.selectedTripRoomId;
    final bool isOwner = trip.ownerId == widget.loginUser.id;

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
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSelected) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.chipBackground,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '선택 중인 여행방',
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
              _buildStatusChip(isOwner ? '방장' : '참여중'),
            ],
          ),
          const SizedBox(height: 18),
          _buildConfirmedDestinationBox(trip),
          const SizedBox(height: 10),
          _buildDetailBox(
            icon: Icons.date_range_rounded,
            label: '여행 기간',
            value:
                '${_formatDate(trip.startDate)} ~ ${_formatDate(trip.endDate)}',
          ),
          const SizedBox(height: 10),
          _buildInviteCodeBox(trip),
          const SizedBox(height: 14),
          if (isOwner)
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    moveToEditTripRoom(trip);
                  },
                  icon: const Icon(Icons.edit_rounded, size: 17),
                  label: const Text('수정'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    deleteTripRoom(trip);
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 17),
                  label: const Text('삭제'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
          if (isOwner) const SizedBox(height: 8),
          AppPrimaryButton(
            text: isSelected ? '선택한 여행 일정 보기' : '이 여행방 일정 보기',
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              openTripSchedule(trip);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCodeBox(TripRoom trip) {
    return InkWell(
      onTap: () {
        copyInviteCode(trip.inviteCode);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.cardSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.link_rounded,
              size: 18,
              color: AppColors.primaryDark,
            ),
            const SizedBox(width: 9),
            const Text(
              '초대 코드',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.body,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                trip.inviteCode.isEmpty ? '생성 전' : trip.inviteCode,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.copy_rounded, size: 16, color: AppColors.subtitle),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmedDestinationBox(TripRoom trip) {
    return FutureBuilder<DestinationCandidate?>(
      future: getConfirmedDestination(trip.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildDetailBox(
            icon: Icons.place_rounded,
            label: '여행지',
            value: '확인 중...',
          );
        }

        if (snapshot.hasError) {
          return _buildDetailBox(
            icon: Icons.place_rounded,
            label: '여행지',
            value: trip.destination,
          );
        }

        final confirmedDestination = snapshot.data;

        if (confirmedDestination == null) {
          return _buildDetailBox(
            icon: Icons.place_rounded,
            label: '여행지',
            value: trip.destination,
          );
        }

        return _buildDetailBox(
          icon: Icons.verified_rounded,
          label: '확정 여행지',
          value: confirmedDestination.name,
        );
      },
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
          '아직 참여 중인 여행방이 없습니다.',
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

  String _formatDate(String date) {
    return date.replaceAll('-', '.');
  }
}
