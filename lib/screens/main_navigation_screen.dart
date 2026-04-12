import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'travel_screen.dart';
import 'expense_screen.dart';
import 'my_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  void moveToScheduleTab() {
    setState(() {
      currentIndex = 1;
    });
  }

  late final List<Widget> pages = [
    HomeScreen(onScheduleButtonPressed: moveToScheduleTab),
    const ScheduleScreen(),
    const TravelScreen(),
    const ExpenseScreen(),
    const MyScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        height: 74,
        selectedIndex: currentIndex,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDCEEFF),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            selectedIcon: Icon(Icons.home_rounded),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_rounded),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: '일정',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_rounded),
            selectedIcon: Icon(Icons.map_rounded),
            label: '여행',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_rounded),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: '정산',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: '마이',
          ),
        ],
      ),
    );
  }
}
