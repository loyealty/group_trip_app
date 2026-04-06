import 'package:flutter/material.dart';
import 'schedule_screen.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      title: '정산',
      icon: Icons.account_balance_wallet_rounded,
    );
  }
}
