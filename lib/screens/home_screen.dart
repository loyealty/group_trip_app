import 'package:flutter/material.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const TripSummary trip = TripSummary(
      title: '부산 여행',
      dateRange: '4월 10일 - 4월 12일',
      location: '부산',
      memberCountText: '5명 참여 중',
      statusText: '일정 조율 진행 중',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1200&auto=format&fit=crop',
    );

    const UpcomingSchedule schedule = UpcomingSchedule(
      monthDay: '4/10',
      title: '부산 여행 일정 조율',
      location: '부산',
      participantCount: 5,
    );

    const List<DestinationCandidate> destinations = [
      DestinationCandidate(
        title: '광안리 해수욕장',
        voteText: '4/5',
        extraCount: 2,
        imageUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1200&auto=format&fit=crop',
      ),
      DestinationCandidate(
        title: '해동용궁사',
        voteText: '5/5',
        extraCount: 3,
        imageUrl:
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=1200&auto=format&fit=crop',
      ),
    ];

    const ExpenseSummary expense = ExpenseSummary(
      totalText: '₩ 250,000',
      title: '부산 여행 정산',
      subtitle: '그룹 경비',
      buttonText: '정산하기',
    );

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FBFF), Color(0xFFEEF6FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 20),
                    _buildSectionShell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            title: '나의 그룹 여행',
                            icon: Icons.public_rounded,
                            showMore: false,
                          ),
                          const SizedBox(height: 14),
                          const _TripHeroCard(trip: trip),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildSectionShell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            title: '다가오는 일정',
                            icon: Icons.auto_awesome_rounded,
                          ),
                          const SizedBox(height: 14),
                          const _ScheduleCard(schedule: schedule),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildSectionShell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            title: '여행지 후보',
                            icon: Icons.map_outlined,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _DestinationCard(item: destinations[0]),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DestinationCard(item: destinations[1]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildSectionShell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            title: '비용 정산',
                            icon: Icons.wallet_travel_rounded,
                            trailingText: expense.buttonText,
                          ),
                          const SizedBox(height: 14),
                          const _ExpenseCard(expense: expense),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            '함께하는 여행',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF334155),
              letterSpacing: -0.8,
            ),
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF99BCE3).withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            image: const DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=400&auto=format&fit=crop',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionShell({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB6D4F0).withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    bool showMore = true,
    String? trailingText,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(width: 6),
        Icon(icon, color: const Color(0xFF7AB6F9), size: 20),
        const Spacer(),
        if (showMore || trailingText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F7FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailingText ?? '더보기',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5B8EC5),
              ),
            ),
          ),
      ],
    );
  }
}

class _TripHeroCard extends StatelessWidget {
  final TripSummary trip;

  const _TripHeroCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBFD8EF).withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(trip.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.72),
              Colors.white.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trip.title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${trip.dateRange} | ${trip.location}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${trip.memberCountText} · ${trip.statusText}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const _AvatarStack(),
                const Spacer(),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6EB5F8),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  child: const Text('일정 조율하기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final UpcomingSchedule schedule;

  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFEFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5F0FA)),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F7FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD7E9FB)),
            ),
            child: Center(
              child: Text(
                schedule.monthDay,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4D7FB5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.location,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                const _AvatarRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final DestinationCandidate item;

  const _DestinationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFEFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5F0FA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                Image.network(
                  item.imageUrl,
                  height: 128,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      item.voteText,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF4C7EAF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(child: _MiniAvatarRow()),
                    Text(
                      '+${item.extraCount}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseSummary expense;

  const _ExpenseCard({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFF2F8FF), Color(0xFFEAF4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFDCEBFA)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF6EADE8),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            expense.totalText,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 122,
      height: 40,
      child: Stack(
        children: const [
          _CircleAvatarItem(
            left: 0,
            imageUrl: 'https://i.pravatar.cc/100?img=32',
          ),
          _CircleAvatarItem(
            left: 26,
            imageUrl: 'https://i.pravatar.cc/100?img=12',
          ),
          _CircleAvatarItem(
            left: 52,
            imageUrl: 'https://i.pravatar.cc/100?img=15',
          ),
          Positioned(
            left: 78,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Text(
                '+2',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarRow extends StatelessWidget {
  const _AvatarRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=32'),
        ),
        SizedBox(width: 6),
        CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=12'),
        ),
        SizedBox(width: 6),
        CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=15'),
        ),
        SizedBox(width: 6),
        CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=23'),
        ),
        SizedBox(width: 6),
        Text(
          '+1',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}

class _MiniAvatarRow extends StatelessWidget {
  const _MiniAvatarRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        CircleAvatar(
          radius: 11,
          backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=32'),
        ),
        SizedBox(width: 4),
        CircleAvatar(
          radius: 11,
          backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=12'),
        ),
        SizedBox(width: 4),
        CircleAvatar(
          radius: 11,
          backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=15'),
        ),
      ],
    );
  }
}

class _CircleAvatarItem extends StatelessWidget {
  final double left;
  final String imageUrl;

  const _CircleAvatarItem({required this.left, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 17,
          backgroundImage: NetworkImage(imageUrl),
        ),
      ),
    );
  }
}

class TripSummary {
  final String title;
  final String dateRange;
  final String location;
  final String memberCountText;
  final String statusText;
  final String imageUrl;

  const TripSummary({
    required this.title,
    required this.dateRange,
    required this.location,
    required this.memberCountText,
    required this.statusText,
    required this.imageUrl,
  });
}

class UpcomingSchedule {
  final String monthDay;
  final String title;
  final String location;
  final int participantCount;

  const UpcomingSchedule({
    required this.monthDay,
    required this.title,
    required this.location,
    required this.participantCount,
  });
}

class DestinationCandidate {
  final String title;
  final String voteText;
  final int extraCount;
  final String imageUrl;

  const DestinationCandidate({
    required this.title,
    required this.voteText,
    required this.extraCount,
    required this.imageUrl,
  });
}

class ExpenseSummary {
  final String totalText;
  final String title;
  final String subtitle;
  final String buttonText;

  const ExpenseSummary({
    required this.totalText,
    required this.title,
    required this.subtitle,
    required this.buttonText,
  });
}
