import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_stat_card.dart';
import '../widgets/app_summary_card.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ExpenseItem> expenses = [
      const ExpenseItem(
        category: '숙소',
        title: '해운대 호텔',
        payer: '김지윤',
        amount: 180000,
      ),
      const ExpenseItem(
        category: '식비',
        title: '광안리 점심 식사',
        payer: '민수',
        amount: 72000,
      ),
      const ExpenseItem(
        category: '교통',
        title: '택시 이동',
        payer: '지윤',
        amount: 28000,
      ),
      const ExpenseItem(
        category: '카페',
        title: '브런치 카페',
        payer: '수빈',
        amount: 36000,
      ),
    ];

    const int totalAmount = 316000;
    const int memberCount = 4;
    const int perPersonAmount = totalAmount ~/ memberCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
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
                    value: '$memberCount명',
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
            ...expenses.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildExpenseCard(item),
              ),
            ),
            const SizedBox(height: 10),
            AppPrimaryButton(text: '지출 추가', onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseItem item) {
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

class ExpenseItem {
  final String category;
  final String title;
  final String payer;
  final int amount;

  const ExpenseItem({
    required this.category,
    required this.title,
    required this.payer,
    required this.amount,
  });
}
