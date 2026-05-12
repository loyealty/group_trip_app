import 'package:flutter/material.dart';
import '../models/trip_member.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_menu_card.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_stat_card.dart';

class MyScreen extends StatefulWidget {
  final int tripRoomId;

  const MyScreen({super.key, required this.tripRoomId});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late Future<List<TripMember>> memberFuture;

  @override
  void initState() {
    super.initState();
    memberFuture = ApiService.getTripMembersByTripRoomId(widget.tripRoomId);
  }

  @override
  void didUpdateWidget(covariant MyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tripRoomId != widget.tripRoomId) {
      refreshMembers();
    }
  }

  void refreshMembers() {
    setState(() {
      memberFuture = ApiService.getTripMembersByTripRoomId(widget.tripRoomId);
    });
  }

  Future<void> showAddMemberDialog() async {
    String memberName = '';

    final String? result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('멤버 추가'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '멤버 이름',
              hintText: '예: 민수',
            ),
            onChanged: (value) {
              memberName = value.trim();
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
                if (memberName.isNotEmpty) {
                  Navigator.pop(dialogContext, memberName);
                }
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );

    if (result == null || result.trim().isEmpty) {
      return;
    }

    try {
      await ApiService.createTripMember(
        tripRoomId: widget.tripRoomId,
        memberName: result.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('멤버가 추가되었습니다.')));

      refreshMembers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('멤버 추가 실패: $e')));
    }
  }

  String getKoreanRole(String role) {
    switch (role) {
      case 'OWNER':
        return '방장';
      case 'MEMBER':
        return '멤버';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<TripMember>>(
          future: memberFuture,
          builder: (context, snapshot) {
            final members = snapshot.data ?? [];

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const AppSectionHeader(
                  title: '마이 페이지',
                  subtitle: '내 여행 정보와 활동 내역을 확인해보세요',
                ),
                const SizedBox(height: 24),
                _buildProfileCard(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppStatCard(
                        icon: Icons.card_travel_rounded,
                        title: '선택 여행방',
                        value: '${widget.tripRoomId}번',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppStatCard(
                        icon: Icons.group_rounded,
                        title: '참여 멤버',
                        value: '${members.length}명',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildMemberSection(snapshot),
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMemberSection(AsyncSnapshot<List<TripMember>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          '멤버 정보를 불러오지 못했습니다.\n${snapshot.error}',
          style: const TextStyle(fontSize: 14, color: AppColors.subtitle),
        ),
      );
    }

    final members = snapshot.data ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '여행방 멤버',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.title,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: AppColors.primaryDark,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '현재 여행방 ${widget.tripRoomId}번의 참여 멤버',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (members.isEmpty)
                _buildEmptyMemberCard()
              else
                ...members.map((member) => _buildMemberItem(member)),
              const SizedBox(height: 14),
              AppPrimaryButton(
                text: '멤버 추가',
                icon: Icons.person_add_rounded,
                onPressed: showAddMemberDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyMemberCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        '아직 등록된 멤버가 없습니다.',
        style: TextStyle(fontSize: 14, color: AppColors.subtitle),
      ),
    );
  }

  Widget _buildMemberItem(TripMember member) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primaryDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member.memberName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.title,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              getKoreanRole(member.role),
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
