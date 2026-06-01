import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';
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
  String selectedTripRoomTitle = '';

  void moveToScheduleTab() {
    setState(() {
      currentIndex = 1;
    });
  }

  void changeTripRoom(int tripRoomId, String tripRoomTitle) {
    setState(() {
      selectedTripRoomId = tripRoomId;
      selectedTripRoomTitle = tripRoomTitle;
    });
  }

  void clearTripRoom() {
    setState(() {
      selectedTripRoomId = 0;
      selectedTripRoomTitle = '';
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
        onTripRoomClear: clearTripRoom,
        onScheduleButtonPressed: moveToScheduleTab,
      ),
      ScheduleScreen(tripRoomId: selectedTripRoomId),
      TravelScreen(tripRoomId: selectedTripRoomId, loginUser: widget.loginUser),
      ExpenseScreen(tripRoomId: selectedTripRoomId),
      MyScreen(
        tripRoomId: selectedTripRoomId,
        tripRoomTitle: selectedTripRoomTitle,
        loginUser: widget.loginUser,
      ),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(index: 0, icon: Icons.home_rounded, label: '홈'),
              _buildNavItem(
                index: 1,
                icon: Icons.calendar_month_rounded,
                label: '일정',
              ),
              _buildNavItem(index: 2, icon: Icons.map_rounded, label: '여행'),
              _buildNavItem(
                index: 3,
                icon: Icons.account_balance_wallet_rounded,
                label: '정산',
              ),
              _buildNavItem(index: 4, icon: Icons.person_rounded, label: '마이'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          moveToTab(index);
        },
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: isSelected ? 34 : 30,
                height: isSelected ? 30 : 28,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.lightBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: isSelected ? 21 : 20,
                  color: isSelected
                      ? AppColors.primaryDark
                      : AppColors.iconGray,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.1,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryDark
                      : AppColors.subtitle,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
