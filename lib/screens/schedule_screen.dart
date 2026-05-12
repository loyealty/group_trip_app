import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_summary_card.dart';
import 'add_schedule_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final int tripRoomId;

  const ScheduleScreen({super.key, required this.tripRoomId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late Future<List<Schedule>> scheduleFuture;

  @override
  void initState() {
    super.initState();
    scheduleFuture = ApiService.getSchedulesByTripRoomId(widget.tripRoomId);
  }

  @override
  void didUpdateWidget(covariant ScheduleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tripRoomId != widget.tripRoomId) {
      refreshSchedules();
    }
  }

  void refreshSchedules() {
    setState(() {
      scheduleFuture = ApiService.getSchedulesByTripRoomId(widget.tripRoomId);
    });
  }

  Future<void> moveToAddScheduleScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddScheduleScreen(tripRoomId: widget.tripRoomId),
      ),
    );

    if (result == true) {
      refreshSchedules();
    }
  }

  Future<void> moveToEditScheduleScreen(Schedule item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddScheduleScreen(tripRoomId: item.tripRoomId, schedule: item),
      ),
    );

    if (result == true) {
      refreshSchedules();
    }
  }

  Future<void> deleteSchedule(Schedule item) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일정 삭제'),
        content: Text('${item.title} 일정을 삭제하시겠습니까?'),
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
      await ApiService.deleteSchedule(item.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('일정이 삭제되었습니다.')));

      refreshSchedules();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('일정 삭제 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<Schedule>>(
          future: scheduleFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('에러: ${snapshot.error}'));
            }

            final schedules = snapshot.data ?? [];

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                const AppSectionHeader(
                  title: '여행 일정',
                  subtitle: '선택한 여행방의 일정을 확인하고 계획을 정리해보세요',
                ),
                const SizedBox(height: 24),
                AppSummaryCard(
                  icon: Icons.calendar_month_rounded,
                  title: '선택한 여행 일정',
                  line1: '여행방 번호 ${widget.tripRoomId}',
                  line2: '총 ${schedules.length}개의 일정이 등록되어 있습니다',
                ),
                const SizedBox(height: 24),
                _buildListTitle('일정 목록'),
                const SizedBox(height: 14),
                if (schedules.isEmpty)
                  _buildEmptyCard('등록된 일정이 없습니다.')
                else
                  ...schedules.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildScheduleCard(item),
                    ),
                  ),
                const SizedBox(height: 10),
                AppPrimaryButton(
                  text: '일정 추가',
                  icon: Icons.add_rounded,
                  onPressed: moveToAddScheduleScreen,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScheduleCard(Schedule item) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEAF4FF), Color(0xFFDCEBFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  _formatMonthDay(item.scheduleDate),
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.scheduleTime,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.subtitle,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                    color: AppColors.title,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 16,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.location,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.body,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
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
                        moveToEditScheduleScreen(item);
                      },
                    ),
                    const SizedBox(width: 14),
                    _buildTextActionButton(
                      text: '삭제',
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.danger,
                      onPressed: () {
                        deleteSchedule(item);
                      },
                    ),
                  ],
                ),
              ],
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

  String _formatMonthDay(String date) {
    if (date.length >= 10) {
      final month = date.substring(5, 7);
      final day = date.substring(8, 10);
      return '${int.parse(month)}/${int.parse(day)}';
    }
    return date;
  }
}
