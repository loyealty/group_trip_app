import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/api_service.dart';

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
    bool readOnly = false,
    int maxLines = 1,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        title: Text(isEditMode ? '일정 수정' : '일정 추가'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            inputField(
              controller: titleController,
              label: '일정 제목',
              hintText: '예: 해운대 방문',
            ),
            const SizedBox(height: 14),
            inputField(
              controller: dateController,
              label: '날짜',
              hintText: '예: 2026-04-10',
              readOnly: true,
              onTap: selectDate,
            ),
            const SizedBox(height: 14),
            inputField(
              controller: timeController,
              label: '시간',
              hintText: '예: 10:00',
              readOnly: true,
              onTap: selectTime,
            ),
            const SizedBox(height: 14),
            inputField(
              controller: placeController,
              label: '장소',
              hintText: '예: 해운대 해수욕장',
            ),
            const SizedBox(height: 14),
            inputField(
              controller: memoController,
              label: '메모',
              hintText: '예: 점심 먹고 이동',
              maxLines: 4,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditMode ? '일정 수정' : '일정 저장',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
