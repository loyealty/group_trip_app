import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_stat_card.dart';
import '../widgets/app_summary_card.dart';
import 'add_expense_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  late Future<List<Expense>> expenseFuture;

  @override
  void initState() {
    super.initState();
    expenseFuture = ApiService.getExpensesByTripRoomId(1);
  }

  void refreshExpenses() {
    setState(() {
      expenseFuture = ApiService.getExpensesByTripRoomId(1);
    });
  }

  Future<void> moveToAddExpenseScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddExpenseScreen(tripRoomId: 1),
      ),
    );

    if (result == true) {
      refreshExpenses();
    }
  }

  Future<void> moveToEditExpenseScreen(Expense item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddExpenseScreen(tripRoomId: item.tripRoomId, expense: item),
      ),
    );

    if (result == true) {
      refreshExpenses();
    }
  }

  Future<void> deleteExpense(Expense item) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('지출 내역 삭제'),
        content: Text('${item.title} 내역을 삭제하시겠습니까?'),
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
      await ApiService.deleteExpense(item.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('지출 내역이 삭제되었습니다.')));

      refreshExpenses();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('지출 삭제 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<Expense>>(
          future: expenseFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('에러: ${snapshot.error}'));
            }

            final expenses = snapshot.data ?? [];

            final int totalAmount = expenses.fold(
              0,
              (sum, item) => sum + item.amount,
            );

            const int memberCount = 4;

            final int perPersonAmount = expenses.isEmpty
                ? 0
                : totalAmount ~/ memberCount;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                const AppSectionHeader(
                  title: '비용 정산',
                  subtitle: '여행 비용과 정산 내역을 한눈에 확인해보세요',
                ),
                const SizedBox(height: 24),
                AppSummaryCard(
                  icon: Icons.account_balance_wallet_rounded,
                  title: '부산 여행 정산 요약',
                  line1: '총 지출 ${_formatAmount(totalAmount)}원',
                  line2: '1인당 ${_formatAmount(perPersonAmount)}원',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppStatCard(
                        icon: Icons.group_rounded,
                        title: '참여 인원',
                        value: '${memberCount}명',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppStatCard(
                        icon: Icons.receipt_long_rounded,
                        title: '지출 건수',
                        value: '${expenses.length}건',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildListTitle('지출 내역'),
                const SizedBox(height: 14),
                if (expenses.isEmpty)
                  _buildEmptyCard('등록된 지출 내역이 없습니다.')
                else
                  ...expenses.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildExpenseCard(item),
                    ),
                  ),
                const SizedBox(height: 10),
                AppPrimaryButton(
                  text: '지출 추가',
                  icon: Icons.add_rounded,
                  onPressed: moveToAddExpenseScreen,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Expense item) {
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEAF4FF), Color(0xFFDCEBFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: AppColors.primaryDark,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                        color: AppColors.title,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.category} · ${item.payer} 결제',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.subtitle,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_formatAmount(item.amount)}원',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTextActionButton(
                text: '수정',
                icon: Icons.edit_rounded,
                color: AppColors.primaryDark,
                onPressed: () {
                  moveToEditExpenseScreen(item);
                },
              ),
              const SizedBox(width: 14),
              _buildTextActionButton(
                text: '삭제',
                icon: Icons.delete_outline_rounded,
                color: AppColors.danger,
                onPressed: () {
                  deleteExpense(item);
                },
              ),
            ],
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

  static String _formatAmount(int amount) {
    final text = amount.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final reverseIndex = text.length - i;
      buffer.write(text[i]);

      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }
}
