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
              padding: const EdgeInsets.all(20),
              children: [
                const AppSectionHeader(
                  title: '비용 정산',
                  subtitle: '여행 중 사용한 비용과 정산 내역을 확인해보세요',
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
                const Text(
                  '지출 내역',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 14),
                if (expenses.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      '등록된 지출 내역이 없습니다.',
                      style: TextStyle(fontSize: 14, color: AppColors.subtitle),
                    ),
                  )
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.lightBlue2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.category} · ${item.payer} 결제',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.subtitle,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_formatAmount(item.amount)}원',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
        ],
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
