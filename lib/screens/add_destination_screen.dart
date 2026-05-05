import 'package:flutter/material.dart';
import '../models/destination_candidate.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';

class AddDestinationScreen extends StatefulWidget {
  const AddDestinationScreen({
    super.key,
    required this.tripRoomId,
    this.destinationCandidate,
  });

  final int tripRoomId;
  final DestinationCandidate? destinationCandidate;

  @override
  State<AddDestinationScreen> createState() => _AddDestinationScreenState();
}

class _AddDestinationScreenState extends State<AddDestinationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController regionController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;

  bool get isEditMode => widget.destinationCandidate != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      nameController.text = widget.destinationCandidate!.name;
      regionController.text = widget.destinationCandidate!.region;
      descriptionController.text = widget.destinationCandidate!.description;
    }
  }

  Future<void> saveDestination() async {
    if (nameController.text.trim().isEmpty ||
        regionController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 입력해주세요.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isEditMode) {
        await ApiService.updateDestinationCandidate(
          id: widget.destinationCandidate!.id,
          tripRoomId: widget.tripRoomId,
          name: nameController.text.trim(),
          region: regionController.text.trim(),
          description: descriptionController.text.trim(),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('여행지 후보가 수정되었습니다.')));
      } else {
        await ApiService.createDestinationCandidate(
          tripRoomId: widget.tripRoomId,
          name: nameController.text.trim(),
          region: regionController.text.trim(),
          description: descriptionController.text.trim(),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('여행지 후보가 추가되었습니다.')));
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

  @override
  void dispose() {
    nameController.dispose();
    regionController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
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
          maxLines: maxLines,
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
              Icons.map_rounded,
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
                  isEditMode ? '후보 정보 수정' : '새 여행지 등록',
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
                  isEditMode
                      ? '등록된 여행지 후보 정보를 수정해보세요'
                      : '함께 가고 싶은 장소를 후보로 등록해보세요',
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
            controller: nameController,
            label: '여행지명',
            hintText: '예: 광안리 해수욕장',
            icon: Icons.place_rounded,
          ),
          const SizedBox(height: 16),
          inputField(
            controller: regionController,
            label: '지역',
            hintText: '예: 부산 수영구',
            icon: Icons.location_city_rounded,
          ),
          const SizedBox(height: 16),
          inputField(
            controller: descriptionController,
            label: '설명',
            hintText: '예: 야경과 해변 산책을 즐길 수 있는 후보지입니다.',
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
        title: Text(isEditMode ? '여행지 후보 수정' : '여행지 후보 추가'),
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
                    text: isEditMode ? '여행지 후보 수정' : '여행지 후보 저장',
                    icon: isEditMode
                        ? Icons.check_rounded
                        : Icons.add_location_alt_rounded,
                    onPressed: saveDestination,
                  ),
          ],
        ),
      ),
    );
  }
}
