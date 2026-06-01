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

  String getTripMoodImage(TripRoom trip) {
    final text = '${trip.title} ${trip.destination} ${trip.description}'
        .toLowerCase();

    if (text.contains('바다') ||
        text.contains('해변') ||
        text.contains('해수욕장') ||
        text.contains('휴양') ||
        text.contains('제주') ||
        text.contains('제주도') ||
        text.contains('부산') ||
        text.contains('해운대') ||
        text.contains('광안리') ||
        text.contains('강릉') ||
        text.contains('속초') ||
        text.contains('여수') ||
        text.contains('괌') ||
        text.contains('오키나와') ||
        text.contains('다낭') ||
        text.contains('beach')) {
      return 'assets/images/beach.png';
    }

    if (text.contains('서울') ||
        text.contains('도시') ||
        text.contains('도심') ||
        text.contains('야경') ||
        text.contains('홍대') ||
        text.contains('강남') ||
        text.contains('도쿄') ||
        text.contains('오사카') ||
        text.contains('뉴욕') ||
        text.contains('방콕') ||
        text.contains('싱가포르') ||
        text.contains('city')) {
      return 'assets/images/city.png';
    }

    if (text.contains('산') ||
        text.contains('숲') ||
        text.contains('호수') ||
        text.contains('자연') ||
        text.contains('캠핑') ||
        text.contains('트레킹') ||
        text.contains('등산') ||
        text.contains('설악') ||
        text.contains('스위스') ||
        text.contains('알프스') ||
        text.contains('nature')) {
      return 'assets/images/nature.png';
    }

    if (text.contains('문화') ||
        text.contains('역사') ||
        text.contains('전통') ||
        text.contains('한옥') ||
        text.contains('경주') ||
        text.contains('전주') ||
        text.contains('교토') ||
        text.contains('로마') ||
        text.contains('파리') ||
        text.contains('프라하') ||
        text.contains('culture')) {
      return 'assets/images/culture.png';
    }

    return 'assets/images/default.png';
  }

  String getTripMoodTag(TripRoom trip) {
    final text = '${trip.title} ${trip.destination} ${trip.description}'
        .toLowerCase();

    if (text.contains('바다') ||
        text.contains('해변') ||
        text.contains('제주') ||
        text.contains('부산') ||
        text.contains('강릉') ||
        text.contains('속초') ||
        text.contains('여수')) {
      return '#해변여행';
    }

    if (text.contains('서울') ||
        text.contains('도시') ||
        text.contains('도심') ||
        text.contains('야경') ||
        text.contains('도쿄') ||
        text.contains('오사카')) {
      return '#도시여행';
    }

    if (text.contains('산') ||
        text.contains('숲') ||
        text.contains('호수') ||
        text.contains('자연') ||
        text.contains('캠핑')) {
      return '#자연여행';
    }

    if (text.contains('문화') ||
        text.contains('역사') ||
        text.contains('전통') ||
        text.contains('한옥') ||
        text.contains('경주') ||
        text.contains('전주') ||
        text.contains('교토')) {
      return '#문화여행';
    }

    return '#함께여행';
  }

  TripRoom? getSelectedTrip(List<TripRoom> tripRooms) {
    if (tripRooms.isEmpty) {
      return null;
    }

    for (final trip in tripRooms) {
      if (trip.id == widget.selectedTripRoomId) {
        return trip;
      }
    }

    return tripRooms.first;
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
            final selectedTrip = getSelectedTrip(tripRooms);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroHeader(selectedTrip),
                  const SizedBox(height: 20),
                  _buildTripActionButtons(),
                  const SizedBox(height: 22),
                  _buildSectionTitle(
                    title: '나의 여행방',
                    subtitle: '내가 만들거나 참여한 그룹 여행을 선택해보세요',
                    actionText: tripRooms.length > 1
                        ? '전체 ${tripRooms.length}개'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  if (tripRooms.isEmpty)
                    _buildEmptyTripCard()
                  else
                    ...tripRooms.map((trip) => _buildTripCard(trip)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroHeader(TripRoom? selectedTrip) {
    final String title = '${widget.loginUser.name}님의 여행 준비';

    final String subtitle = selectedTrip == null
        ? '함께 떠날 여행을 친구들과 계획해보세요.'
        : '${selectedTrip.title}을 친구들과 함께 준비해보세요.';

    final String imagePath = selectedTrip == null
        ? 'assets/images/default.png'
        : getTripMoodImage(selectedTrip);

    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.cover)),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.86),
                      Colors.white.withOpacity(0.64),
                      Colors.white.withOpacity(0.20),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.70),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withOpacity(0.85)),
                    ),
                    child: const Text(
                      'GROUP TRIP PLANNER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 25,
                      height: 1.18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.title,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: AppColors.body,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(17),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: AppColors.title,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trip.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.subtitle,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildSmallTag(getTripMoodTag(trip)),
                        if (isSelected) _buildSmallTag('선택중'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                children: [
                  _buildStatusChip(isOwner ? '방장' : '참여중'),
                  if (isOwner) _buildTripRoomPopupMenu(trip),
                ],
              ),
            ],
          ),
          const SizedBox(height: 17),
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

  Widget _buildSmallTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.primaryDark,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildTripRoomPopupMenu(TripRoom trip) {
    return PopupMenuButton<String>(
      tooltip: '여행방 관리',
      color: Colors.white,
      surfaceTintColor: Colors.white,
      icon: const Icon(
        Icons.more_vert_rounded,
        color: AppColors.iconGray,
        size: 22,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (value) {
        if (value == 'edit') {
          moveToEditTripRoom(trip);
        }

        if (value == 'delete') {
          deleteTripRoom(trip);
        }
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: AppColors.primaryDark,
                ),
                SizedBox(width: 10),
                Text('수정'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppColors.danger,
                ),
                SizedBox(width: 10),
                Text('삭제', style: TextStyle(color: AppColors.danger)),
              ],
            ),
          ),
        ];
      },
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

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
    String? actionText,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
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
          ),
        ),
        if (actionText != null) ...[
          const SizedBox(width: 10),
          Text(
            actionText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.subtitle,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(String date) {
    return date.replaceAll('-', '.');
  }
}
