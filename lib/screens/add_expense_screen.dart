import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';

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
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
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
            prefixIcon: Icon(icon, color: AppColors.primaryDark, size: 21),
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
              Icons.account_balance_wallet_rounded,
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
                  isEditMode ? '지출 정보 수정' : '새 지출 등록',
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
                  isEditMode ? '등록된 지출 내역을 수정해보세요' : '여행 중 사용한 비용을 입력해보세요',
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
            controller: categoryController,
            label: '카테고리',
            hintText: '예: 식비',
            icon: Icons.category_rounded,
          ),
          const SizedBox(height: 16),
          inputField(
            controller: titleController,
            label: '지출 제목',
            hintText: '예: 저녁 식사',
            icon: Icons.receipt_long_rounded,
          ),
          const SizedBox(height: 16),
          inputField(
            controller: payerController,
            label: '결제자',
            hintText: '예: 김지윤',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 16),
          inputField(
            controller: amountController,
            label: '금액',
            hintText: '예: 48000',
            icon: Icons.payments_rounded,
            keyboardType: TextInputType.number,
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
        title: Text(isEditMode ? '지출 수정' : '지출 추가'),
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
                    text: isEditMode ? '지출 수정' : '지출 저장',
                    icon: isEditMode ? Icons.check_rounded : Icons.add_rounded,
                    onPressed: saveExpense,
                  ),
          ],
        ),
      ),
    );
  }
}
