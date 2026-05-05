import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, required this.tripRoomId, this.expense});

  final int tripRoomId;
  final Expense? expense;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController payerController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool isLoading = false;

  bool get isEditMode => widget.expense != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      categoryController.text = widget.expense!.category;
      titleController.text = widget.expense!.title;
      payerController.text = widget.expense!.payer;
      amountController.text = widget.expense!.amount.toString();
    }
  }

  Future<void> saveExpense() async {
    if (categoryController.text.trim().isEmpty ||
        titleController.text.trim().isEmpty ||
        payerController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 입력해주세요.')));
      return;
    }

    final int? amount = int.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('금액은 숫자로 입력해주세요.')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isEditMode) {
        await ApiService.updateExpense(
          id: widget.expense!.id,
          tripRoomId: widget.tripRoomId,
          category: categoryController.text.trim(),
          title: titleController.text.trim(),
          payer: payerController.text.trim(),
          amount: amount,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('지출 내역이 수정되었습니다.')));
      } else {
        await ApiService.createExpense(
          tripRoomId: widget.tripRoomId,
          category: categoryController.text.trim(),
          title: titleController.text.trim(),
          payer: payerController.text.trim(),
          amount: amount,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('지출 내역이 추가되었습니다.')));
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
    categoryController.dispose();
    titleController.dispose();
    payerController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
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
        title: Text(isEditMode ? '지출 수정' : '지출 추가'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.title,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            inputField(
              controller: categoryController,
              label: '카테고리',
              hintText: '예: 식비',
            ),
            const SizedBox(height: 14),
            inputField(
              controller: titleController,
              label: '지출 제목',
              hintText: '예: 저녁 식사',
            ),
            const SizedBox(height: 14),
            inputField(
              controller: payerController,
              label: '결제자',
              hintText: '예: 김지윤',
            ),
            const SizedBox(height: 14),
            inputField(
              controller: amountController,
              label: '금액',
              hintText: '예: 48000',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveExpense,
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
                        isEditMode ? '지출 수정' : '지출 저장',
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
