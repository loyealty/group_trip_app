import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xFFF4F8FF),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '비용 정산',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A3A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '여행 중 사용한 비용과 정산 내역을 확인해보세요',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),

            _buildSummaryCard(totalAmount, perPersonAmount),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSmallInfoCard(
                    icon: Icons.group_rounded,
                    title: '참여 인원',
                    value: '$memberCount명',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSmallInfoCard(
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
                color: Color(0xFF1E2A3A),
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF60A5FA),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '지출 추가',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int totalAmount, int perPersonAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF7FBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5EEF9)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFDCEEFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Color(0xFF3B82F6),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '부산 여행 정산 요약',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A3A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '총 지출 ${_formatAmount(totalAmount)}원',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1인당 ${_formatAmount(perPersonAmount)}원',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5EEF9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF60A5FA), size: 24),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2A3A),
            ),
          ),
        ],
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
        border: Border.all(color: const Color(0xFFE5EEF9)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: Color(0xFF60A5FA),
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
                    color: Color(0xFF1E2A3A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.category} · ${item.payer} 결제',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
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
              color: Color(0xFF3B82F6),
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
