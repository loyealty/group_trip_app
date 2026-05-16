import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/trip_member.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_stat_card.dart';
import '../widgets/app_summary_card.dart';
import 'add_expense_screen.dart';

class ExpenseScreen extends StatefulWidget {
  final int tripRoomId;

  const ExpenseScreen({super.key, required this.tripRoomId});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  late Future<List<Expense>> expenseFuture;
  late Future<List<TripMember>> memberFuture;

  @override
  void initState() {
    super.initState();
    expenseFuture = _loadExpenses();
    memberFuture = _loadMembers();
  }

  Future<List<Expense>> _loadExpenses() {
    if (widget.tripRoomId == 0) {
      return Future.value([]);
    }

    return ApiService.getExpensesByTripRoomId(widget.tripRoomId);
  }

  Future<List<TripMember>> _loadMembers() {
    if (widget.tripRoomId == 0) {
      return Future.value([]);
    }

    return ApiService.getTripMembersByTripRoomId(widget.tripRoomId);
  }

  @override
  void didUpdateWidget(covariant ExpenseScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.tripRoomId != widget.tripRoomId) {
      refreshData();
    }
  }

  void refreshData() {
    setState(() {
      expenseFuture = _loadExpenses();
      memberFuture = _loadMembers();
    });
  }

  void refreshExpenses() {
    refreshData();
  }

  Future<void> moveToAddExpenseScreen() async {
    if (widget.tripRoomId == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('먼저 홈 화면에서 여행방을 선택해주세요.')));
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(tripRoomId: widget.tripRoomId),
      ),
    );

    if (result == true) {
      refreshData();
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
      refreshData();
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

      refreshData();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('지출 삭제 실패: $e')));
    }
  }

  List<SettlementResult> calculateSettlementResults({
    required List<Expense> expenses,
    required List<TripMember> members,
  }) {
    if (expenses.isEmpty || members.isEmpty) {
      return [];
    }

    final List<String> memberNames = members
        .map((member) => member.memberName.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (memberNames.isEmpty) {
      return [];
    }

    final Map<String, int> balanceMap = {
      for (final name in memberNames) name: 0,
    };

    for (final expense in expenses) {
      final String payer = expense.payer.trim();

      if (payer.isEmpty || !balanceMap.containsKey(payer)) {
        continue;
      }

      final int memberCount = memberNames.length;
      final int shareAmount = expense.amount ~/ memberCount;
      final int remainder = expense.amount % memberCount;

      balanceMap[payer] = balanceMap[payer]! + expense.amount;

      for (int i = 0; i < memberNames.length; i++) {
        final String memberName = memberNames[i];
        final int extra = i < remainder ? 1 : 0;
        balanceMap[memberName] = balanceMap[memberName]! - shareAmount - extra;
      }
    }

    final List<MapEntry<String, int>> receivers = balanceMap.entries
        .where((entry) => entry.value > 0)
        .toList();

    final List<MapEntry<String, int>> payers = balanceMap.entries
        .where((entry) => entry.value < 0)
        .map((entry) => MapEntry(entry.key, -entry.value))
        .toList();

    final List<SettlementResult> results = [];

    int payerIndex = 0;
    int receiverIndex = 0;

    while (payerIndex < payers.length && receiverIndex < receivers.length) {
      final currentPayer = payers[payerIndex];
      final currentReceiver = receivers[receiverIndex];

      final int amount = currentPayer.value < currentReceiver.value
          ? currentPayer.value
          : currentReceiver.value;

      if (amount > 0) {
        results.add(
          SettlementResult(
            fromMember: currentPayer.key,
            toMember: currentReceiver.key,
            amount: amount,
          ),
        );
      }

      final int remainPayerAmount = currentPayer.value - amount;
      final int remainReceiverAmount = currentReceiver.value - amount;

      if (remainPayerAmount == 0) {
        payerIndex++;
      } else {
        payers[payerIndex] = MapEntry(currentPayer.key, remainPayerAmount);
      }

      if (remainReceiverAmount == 0) {
        receiverIndex++;
      } else {
        receivers[receiverIndex] = MapEntry(
          currentReceiver.key,
          remainReceiverAmount,
        );
      }
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tripRoomId == 0) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            children: [
              const AppSectionHeader(
                title: '비용 정산',
                subtitle: '여행방을 선택하면 정산 내역을 확인할 수 있어요',
              ),
              const SizedBox(height: 24),
              _buildEmptyCard('선택된 여행방이 없습니다.\n홈 화면에서 여행방을 먼저 선택해주세요.'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<Expense>>(
          future: expenseFuture,
          builder: (context, expenseSnapshot) {
            if (expenseSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (expenseSnapshot.hasError) {
              return Center(child: Text('에러: ${expenseSnapshot.error}'));
            }

            final expenses = expenseSnapshot.data ?? [];

            return FutureBuilder<List<TripMember>>(
              future: memberFuture,
              builder: (context, memberSnapshot) {
                if (memberSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final members = memberSnapshot.data ?? [];

                final int totalAmount = expenses.fold(
                  0,
                  (sum, item) => sum + item.amount,
                );

                final int memberCount = members.length;

                final int perPersonAmount = expenses.isEmpty || memberCount == 0
                    ? 0
                    : totalAmount ~/ memberCount;

                final settlementResults = calculateSettlementResults(
                  expenses: expenses,
                  members: members,
                );

                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    const AppSectionHeader(
                      title: '비용 정산',
                      subtitle: '선택한 여행방의 비용과 정산 내역을 확인해보세요',
                    ),
                    const SizedBox(height: 24),
                    AppSummaryCard(
                      icon: Icons.account_balance_wallet_rounded,
                      title: '선택한 여행 정산 요약',
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
                    if (memberSnapshot.hasError) ...[
                      const SizedBox(height: 14),
                      _buildEmptyCard('멤버 정보를 불러오지 못해 참여 인원이 0명으로 표시됩니다.'),
                    ],
                    const SizedBox(height: 24),
                    _buildListTitle('최종 정산 결과'),
                    const SizedBox(height: 14),
                    _buildSettlementSection(settlementResults),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettlementSection(List<SettlementResult> results) {
    if (results.isEmpty) {
      return _buildEmptyCard('정산할 내역이 없습니다.');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
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
        children: results
            .map(
              (result) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildSettlementItem(result),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSettlementItem(SettlementResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.cardSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.swap_horiz_rounded,
              color: AppColors.primaryDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${result.fromMember} → ${result.toMember}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.title,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${_formatAmount(result.amount)}원',
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
          height: 1.5,
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

class SettlementResult {
  final String fromMember;
  final String toMember;
  final int amount;

  SettlementResult({
    required this.fromMember,
    required this.toMember,
    required this.amount,
  });
}
