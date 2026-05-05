import 'package:flutter/material.dart';
import '../models/destination_candidate.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

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
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.title,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditMode ? '여행지 후보 수정' : '여행지 후보 추가'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.title,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            inputField(
              controller: nameController,
              label: '여행지명',
              hintText: '예: 광안리 해수욕장',
            ),
            const SizedBox(height: 14),
            inputField(
              controller: regionController,
              label: '지역',
              hintText: '예: 부산 수영구',
            ),
            const SizedBox(height: 14),
            inputField(
              controller: descriptionController,
              label: '설명',
              hintText: '예: 야경과 해변 산책을 즐길 수 있는 후보지입니다.',
              maxLines: 4,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveDestination,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditMode ? '여행지 후보 수정' : '여행지 후보 저장',
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
