import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key, required this.tripRoomId, this.schedule});

  final int tripRoomId;
  final Schedule? schedule;

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController memoController = TextEditingController();

  bool isLoading = false;

  bool get isEditMode => widget.schedule != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      titleController.text = widget.schedule!.title;
      dateController.text = widget.schedule!.scheduleDate;
      timeController.text = widget.schedule!.scheduleTime;
      placeController.text = widget.schedule!.location;
      memoController.text = widget.schedule!.description;
    }
  }

  Future<void> saveSchedule() async {
    if (titleController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty ||
        placeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('필수 항목을 입력해주세요.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isEditMode) {
        await ApiService.updateSchedule(
          id: widget.schedule!.id,
          tripRoomId: widget.tripRoomId,
          title: titleController.text.trim(),
          location: placeController.text.trim(),
          description: memoController.text.trim(),
          scheduleDate: dateController.text.trim(),
          scheduleTime: timeController.text.trim(),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('일정이 수정되었습니다.')));
      } else {
        await ApiService.createSchedule(
          tripRoomId: widget.tripRoomId,
          title: titleController.text.trim(),
          location: placeController.text.trim(),
          description: memoController.text.trim(),
          scheduleDate: dateController.text.trim(),
          scheduleTime: timeController.text.trim(),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('일정이 추가되었습니다.')));
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 4, 10),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      dateController.text =
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> selectTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );

    if (selectedTime != null) {
      timeController.text =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    dateController.dispose();
    timeController.dispose();
    placeController.dispose();
    memoController.dispose();
    super.dispose();
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.title,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          onTap: onTap,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.title,
            letterSpacing: -0.2,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.subtitle,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 14 : 0),
              child: Icon(icon, color: AppColors.primaryDark, size: 21),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 46,
              minHeight: 46,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.primaryDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.primaryDark,
              size: 26,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? '일정 정보 수정' : '새 일정 등록',
                  style: const TextStyle(
                    fontSize: 19,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                    color: AppColors.title,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isEditMode ? '등록된 여행 일정을 수정해보세요' : '여행 중 필요한 일정을 등록해보세요',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subtitle,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          inputField(
            controller: titleController,
            label: '일정 제목',
            hintText: '예: 해운대 방문',
            icon: Icons.edit_calendar_rounded,
          ),
          const SizedBox(height: 16),
          inputField(
            controller: dateController,
            label: '날짜',
            hintText: '예: 2026-04-10',
            icon: Icons.date_range_rounded,
            readOnly: true,
            onTap: selectDate,
          ),
          const SizedBox(height: 16),
          inputField(
            controller: timeController,
            label: '시간',
            hintText: '예: 10:00',
            icon: Icons.access_time_rounded,
            readOnly: true,
            onTap: selectTime,
          ),
          const SizedBox(height: 16),
          inputField(
            controller: placeController,
            label: '장소',
            hintText: '예: 해운대 해수욕장',
            icon: Icons.place_rounded,
          ),
          const SizedBox(height: 16),
          inputField(
            controller: memoController,
            label: '메모',
            hintText: '예: 점심 먹고 이동',
            icon: Icons.notes_rounded,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditMode ? '일정 수정' : '일정 추가'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.title,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          children: [
            buildHeader(),
            const SizedBox(height: 20),
            buildFormCard(),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : AppPrimaryButton(
                    text: isEditMode ? '일정 수정' : '일정 저장',
                    icon: isEditMode ? Icons.check_rounded : Icons.add_rounded,
                    onPressed: saveSchedule,
                  ),
          ],
        ),
      ),
    );
  }
}
