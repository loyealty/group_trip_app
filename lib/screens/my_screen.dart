import 'package:flutter/material.dart';
import '../models/trip_member.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_stat_card.dart';
import 'login_screen.dart';

class MyScreen extends StatefulWidget {
  final int tripRoomId;
  final String tripRoomTitle;
  final AppUser loginUser;

  const MyScreen({
    super.key,
    required this.tripRoomId,
    required this.tripRoomTitle,
    required this.loginUser,
  });

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

  bool isLoginUserOwner(List<TripMember> members) {
    return members.any(
      (member) =>
          member.userId == widget.loginUser.id && member.role == 'OWNER',
    );
  }

  String getSelectedTripRoomName() {
    if (widget.tripRoomTitle.trim().isEmpty) {
      return '선택 없음';
    }

    return widget.tripRoomTitle;
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void showReadySnackBar(String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title 기능은 준비 중입니다.')));
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

  Future<void> showEditMemberDialog(TripMember member) async {
    String memberName = member.memberName;

    final String? result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('멤버 수정'),
          content: TextField(
            autofocus: true,
            controller: TextEditingController(text: member.memberName),
            decoration: const InputDecoration(
              labelText: '멤버 이름',
              hintText: '예: 지윤',
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
              child: const Text('수정'),
            ),
          ],
        );
      },
    );

    if (result == null || result.trim().isEmpty) {
      return;
    }

    try {
      await ApiService.updateTripMember(
        id: member.id,
        tripRoomId: member.tripRoomId,
        memberName: result.trim(),
        role: member.role,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('멤버가 수정되었습니다.')));

      refreshMembers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('멤버 수정 실패: $e')));
    }
  }

  Future<void> deleteMember(TripMember member) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('멤버 삭제'),
          content: Text('${member.memberName} 멤버를 삭제할까요?\n정산 인원 수가 변경됩니다.'),
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
      await ApiService.deleteTripMember(member.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('멤버가 삭제되었습니다.')));

      refreshMembers();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('멤버 삭제 실패: $e')));
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
    if (widget.tripRoomId == 0) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const AppSectionHeader(
                title: '마이 페이지',
                subtitle: '여행방을 선택하면 멤버 정보를 확인할 수 있어요',
              ),
              const SizedBox(height: 24),
              _buildProfileCard(),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  '선택된 여행방이 없습니다.\n홈 화면에서 여행방을 선택해주세요.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.subtitle,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuSection(),
              const SizedBox(height: 20),
              _buildLogoutButton(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<TripMember>>(
          future: memberFuture,
          builder: (context, snapshot) {
            final members = snapshot.data ?? [];
            final bool isOwner = isLoginUserOwner(members);

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
                        value: getSelectedTripRoomName(),
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
                _buildMemberSection(snapshot, isOwner),
                const SizedBox(height: 24),
                _buildMenuSection(),
                const SizedBox(height: 20),
                _buildLogoutButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMemberSection(
    AsyncSnapshot<List<TripMember>> snapshot,
    bool isOwner,
  ) {
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
    final String tripRoomName = getSelectedTripRoomName();

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
              _buildMemberSectionHeader(tripRoomName, members.length),
              const SizedBox(height: 14),
              if (members.isEmpty)
                _buildEmptyMemberCard()
              else
                ...members.map((member) => _buildMemberItem(member, isOwner)),
              if (isOwner) ...[
                const SizedBox(height: 10),
                AppPrimaryButton(
                  text: '멤버 추가',
                  icon: Icons.person_add_rounded,
                  onPressed: showAddMemberDialog,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberSectionHeader(String tripRoomName, int memberCount) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.groups_rounded,
            color: AppColors.primaryDark,
            size: 24,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '참여 멤버',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.title,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$tripRoomName · ${memberCount}명',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.subtitle,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Text(
        '아직 등록된 멤버가 없습니다.',
        style: TextStyle(fontSize: 14, color: AppColors.subtitle),
      ),
    );
  }

  Widget _buildMemberItem(TripMember member, bool isOwner) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primaryDark,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member.memberName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.title,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildRoleChip(member.role),
          if (isOwner) ...[
            const SizedBox(width: 2),
            _buildMemberPopupMenu(member),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        getKoreanRole(role),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.chipText,
        ),
      ),
    );
  }

  Widget _buildMemberPopupMenu(TripMember member) {
    return PopupMenuButton<String>(
      tooltip: '멤버 관리',
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
          showEditMemberDialog(member);
        }

        if (value == 'delete') {
          deleteMember(member);
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

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '설정 및 안내',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.title,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
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
          child: Column(
            children: [
              _buildMenuItem(
                icon: Icons.group_rounded,
                title: '내 여행방 관리',
                subtitle: '참여 중인 여행방과 초대 내역 확인',
                badgeText: '보기',
                isReady: true,
                onTap: () {
                  showReadySnackBar('내 여행방 관리');
                },
              ),
              _buildMenuDivider(),
              _buildMenuItem(
                icon: Icons.notifications_rounded,
                title: '알림 설정',
                subtitle: '일정, 초대, 정산 알림 관리',
                badgeText: '준비 중',
                isReady: false,
                onTap: () {
                  showReadySnackBar('알림 설정');
                },
              ),
              _buildMenuDivider(),
              _buildMenuItem(
                icon: Icons.settings_rounded,
                title: '앱 설정',
                subtitle: '계정 및 화면 설정 관리',
                badgeText: '준비 중',
                isReady: false,
                onTap: () {
                  showReadySnackBar('앱 설정');
                },
              ),
              _buildMenuDivider(),
              _buildMenuItem(
                icon: Icons.help_outline_rounded,
                title: '도움말',
                subtitle: '서비스 이용 방법 확인',
                badgeText: '준비 중',
                isReady: false,
                onTap: () {
                  showReadySnackBar('도움말');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required bool isReady,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 22),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.title,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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
                color: isReady ? AppColors.chipBackground : AppColors.cardSoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isReady ? Colors.transparent : AppColors.border,
                ),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isReady ? AppColors.chipText : AppColors.subtitle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 69),
      child: Container(height: 1, color: AppColors.border.withOpacity(0.75)),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.loginUser.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.loginUser.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.subtitle,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
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

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: logout,
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
    );
  }
}
