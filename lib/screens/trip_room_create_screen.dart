import 'package:flutter/material.dart';
import '../models/trip_room.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';

class TripRoomCreateScreen extends StatefulWidget {
  final TripRoom? tripRoom;

  const TripRoomCreateScreen({super.key, this.tripRoom});

  @override
  State<TripRoomCreateScreen> createState() => _TripRoomCreateScreenState();
}

class _TripRoomCreateScreenState extends State<TripRoomCreateScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;

  bool isLoading = false;

  bool get isEditMode => widget.tripRoom != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      final trip = widget.tripRoom!;

      titleController.text = trip.title;
      destinationController.text = trip.destination;
      descriptionController.text = trip.description;
      startDate = DateTime.tryParse(trip.startDate);
      endDate = DateTime.tryParse(trip.endDate);
    }
  }

  String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        startDate = picked;

        if (endDate != null && endDate!.isBefore(startDate!)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  Future<void> saveTripRoom() async {
    if (isLoading) {
      return;
    }

    if (titleController.text.trim().isEmpty ||
        destinationController.text.trim().isEmpty ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('필수 정보를 모두 입력해주세요.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isEditMode) {
        await ApiService.updateTripRoom(
          id: widget.tripRoom!.id,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          destination: destinationController.text.trim(),
          startDate: formatDate(startDate!),
          endDate: formatDate(endDate!),
          status: widget.tripRoom!.status,
        );
      } else {
        await ApiService.createTripRoom(
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          destination: destinationController.text.trim(),
          startDate: formatDate(startDate!),
          endDate: formatDate(endDate!),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditMode ? '여행방이 수정되었습니다.' : '여행방이 생성되었습니다.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditMode ? '여행방 수정 실패: $e' : '여행방 생성 실패: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    destinationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: maxLines > 1 ? 48 : 0),
            child: Icon(icon, color: AppColors.primary),
          ),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget buildDateButton({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isLoading ? () {} : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date == null ? title : formatDate(date),
                style: TextStyle(
                  fontSize: 15,
                  color: date == null ? AppColors.subtitle : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.subtitle),
          ],
        ),
      ),
    );
  }

  Widget buildGuideCard() {
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
            child: Icon(
              isEditMode ? Icons.edit_rounded : Icons.travel_explore_rounded,
              color: AppColors.primaryDark,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? '여행방 정보 수정' : '새로운 여행방 생성',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.title,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isEditMode
                      ? '여행방 정보를 수정하면 홈 화면에 바로 반영됩니다.'
                      : '여행 정보를 입력하면 홈 화면에 바로 추가됩니다.',
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
        ],
      ),
    );
  }

  Widget buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          buildInputField(
            controller: titleController,
            label: '여행방 제목',
            icon: Icons.flight_takeoff_rounded,
          ),
          buildInputField(
            controller: destinationController,
            label: '여행지',
            icon: Icons.place_rounded,
          ),
          buildDateButton(
            title: '시작일 선택',
            date: startDate,
            onTap: selectStartDate,
          ),
          buildDateButton(title: '종료일 선택', date: endDate, onTap: selectEndDate),
          buildInputField(
            controller: descriptionController,
            label: '여행 설명',
            icon: Icons.notes_rounded,
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          AppPrimaryButton(
            text: isLoading
                ? isEditMode
                      ? '수정 중...'
                      : '생성 중...'
                : isEditMode
                ? '여행방 수정하기'
                : '여행방 생성하기',
            icon: isEditMode ? Icons.edit_rounded : Icons.add_rounded,
            onPressed: () {
              if (!isLoading) {
                saveTripRoom();
              }
            },
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
        title: Text(
          isEditMode ? '여행방 수정' : '여행방 만들기',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.title,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: Column(
          children: [
            buildGuideCard(),
            const SizedBox(height: 18),
            buildFormCard(),
          ],
        ),
      ),
    );
  }
}
