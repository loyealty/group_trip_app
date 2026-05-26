import 'package:flutter/material.dart';
import '../models/user.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'travel_screen.dart';
import 'expense_screen.dart';
import 'my_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final AppUser loginUser;

  const MainNavigationScreen({super.key, required this.loginUser});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;
  int selectedTripRoomId = 0;

  void moveToScheduleTab() {
    setState(() {
      currentIndex = 1;
    });
  }

  void changeTripRoom(int tripRoomId) {
    setState(() {
      selectedTripRoomId = tripRoomId;
    });
  }

  void moveToTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        loginUser: widget.loginUser,
        selectedTripRoomId: selectedTripRoomId,
        onTripRoomSelected: changeTripRoom,
        onScheduleButtonPressed: moveToScheduleTab,
      ),
      ScheduleScreen(tripRoomId: selectedTripRoomId),
      TravelScreen(tripRoomId: selectedTripRoomId, loginUser: widget.loginUser),
      ExpenseScreen(tripRoomId: selectedTripRoomId),
      MyScreen(tripRoomId: selectedTripRoomId, loginUser: widget.loginUser),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        height: 74,
        selectedIndex: currentIndex,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDCEEFF),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: moveToTab,
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
