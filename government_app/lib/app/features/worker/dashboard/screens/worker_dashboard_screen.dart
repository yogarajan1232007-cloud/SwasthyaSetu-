import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import '../../../officer/assignments/data/assignment_data_store.dart';
import '../../../officer/households/data/household_data_store.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() =>
      _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color teal = Color(0xFF0D998D);
  static const Color background = Color(0xFFF3F7FC);
  static const Color muted = Color(0xFF718096);

  int selectedIndex = 0;

  final String workerName = 'Kavitha';
  final String workerInitials = 'SK';
  final String area = 'Ukkadam North';

  static const String workerId = 'HW-2048';

List<Map<String, dynamic>> get assignedHouseholds {
  final assignments =
      AssignmentDataStore.getWorkerAssignments(workerId);

  final result = <Map<String, dynamic>>[];

  for (final assignment in assignments) {
    if (assignment['status'] == 'Cancelled') continue;

    final records =
        assignment['householdProgress'] as List<dynamic>? ?? [];

    for (final record in records) {
      final householdId = record['householdId']?.toString();

      if (householdId == null) continue;

      final household =
          HouseholdDataStore.getHouseholdById(householdId);

      if (household == null) continue;

      result.add({
        ...household,
        'assignmentId': assignment['id'],
        'progress': record,
      });
    }
  }

  return result;
}

List<Map<String, dynamic>> get todayVisits {
  return assignedHouseholds.where((household) {
    final progress =
        household['progress'] as Map<String, dynamic>;

    return progress['status'] != 'Completed';
  }).toList();
}

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1100;
        final isTablet = width >= 700 && width < 1100;

        return Scaffold(
          backgroundColor: background,
          body: SafeArea(
            bottom: false,
            child: Row(
              children: [
                if (isDesktop) _buildDesktopNavigation(),
                if (isTablet) _buildTabletNavigation(),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            setState(() {});
                          },
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 1320,
                              ),
                              child: ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  _buildWelcomeSection(),
                                  _buildNextAssignment(),
                                  _buildStatistics(),
                                  _buildVisitPlan(),
                                  const SizedBox(height: 25),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              (!isDesktop && !isTablet) ? _buildBottomNavigation() : null,
        );
      },
    );
  }

  void _handleNavigationTap(int index) {
    if (index == 1) {
      context.push('/worker-households');
    } else if (index == 2) {
      context.push('/worker-visits');
    } else if (index == 3) {
      context.push('/worker-followups');
    } else if (index == 4) {
      context.push('/worker-profile');
    } else {
      setState(() {
        selectedIndex = 0;
      });
    }
  }

  Widget _buildDesktopNavigation() {
    return Container(
      width: 238,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE9EEF5)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 16, 24),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: navy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_outlined,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SWASTHYASETHU',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Health Worker',
                        style: TextStyle(color: muted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 16, 10),
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                color: muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          _desktopNavItem(0, Icons.home_rounded, 'Home'),
          _desktopNavItem(1, Icons.people_outline_rounded, 'Households'),
          _desktopNavItem(2, Icons.assignment_outlined, 'Visits'),
          _desktopNavItem(3, Icons.calendar_month_outlined, 'Follow-ups'),
          _desktopNavItem(4, Icons.person_outline_rounded, 'Profile'),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Community Health Screening',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktopNavItem(int index, IconData icon, String label) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: isSelected ? const Color(0xFFEAF0FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _handleNavigationTap(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: isSelected ? blue : muted,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? blue : navy,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabletNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE9EEF5)),
        ),
      ),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: _handleNavigationTap,
        labelType: NavigationRailLabelType.all,
        backgroundColor: Colors.white,
        selectedIconTheme: const IconThemeData(color: blue),
        unselectedIconTheme: const IconThemeData(color: muted),
        selectedLabelTextStyle: const TextStyle(
          color: blue,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: muted,
          fontSize: 10,
        ),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.people_outline_rounded),
            label: Text('Households'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.assignment_outlined),
            label: Text('Visits'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: Text('Follow-ups'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: Text('Profile'),
          ),
        ],
      ),
    );
  }

  // TOP BAR

  Widget _buildTopBar() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE9EEF5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 39,
            width: 39,
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'COIMBATORE DISTRICT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: muted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$area PHC',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: navy,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showMessage('Notifications will be available soon.');
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: navy,
              size: 24,
            ),
          ),
          Container(
            height: 37,
            width: 37,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFE3EDFA),
              shape: BoxShape.circle,
            ),
            child: Text(
              workerInitials,
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WELCOME SECTION

  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    final date = _formatDate(now);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 24),
      color: navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  date.toUpperCase(),
                  style: const TextStyle(
                    color: teal,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              const SizedBox(width: 25),
              const Column(
                children: [
                  Text(
                    '6',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'day streak',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Good morning, $workerName',
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'You have 8 home visits planned today.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // NEXT ASSIGNMENT

  Widget _buildNextAssignment() {
  final nextVisit = todayVisits.isNotEmpty
      ? todayVisits.first
      : null;

  final householdName =
      nextVisit?['householdName']?.toString() ?? 'No pending visits';

  final householdId =
      nextVisit?['id']?.toString() ?? '';

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
    child: Material(
      color: teal,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (nextVisit == null) {
            context.push('/worker-households');
            return;
          }

          context.push(
            '/worker-household-details/$householdId',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.directions_walk_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NEXT ASSIGNMENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      nextVisit == null
                          ? 'No pending home visits'
                          : 'Start home visit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      nextVisit == null
                          ? 'Check your assigned households'
                          : '$householdName · $householdId',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 27,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  // STATISTICS

  Widget _buildStatistics() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 1000
              ? 4
              : width < 360
                  ? 1
                  : 2;
          final aspectRatio = columns == 4
              ? 2.55
              : columns == 2
                  ? 2.15
                  : 4.0;

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspectRatio,
            children: [
              _statCard(
                icon: Icons.home_outlined,
                title: 'HOUSEHOLDS',
                value: '32',
                iconColor: blue,
                iconBackground: const Color(0xFFEAF0FF),
              ),
              _statCard(
                icon: Icons.check_rounded,
                title: 'COMPLETED',
                value: '18',
                iconColor: const Color(0xFF13A46B),
                iconBackground: const Color(0xFFEAF8EF),
              ),
              _statCard(
                icon: Icons.calendar_today_outlined,
                title: 'PENDING',
                value: '14',
                iconColor: const Color(0xFFE99A00),
                iconBackground: const Color(0xFFFFF6E5),
              ),
              _statCard(
                icon: Icons.warning_amber_rounded,
                title: 'FOLLOW-UPS',
                value: '5',
                iconColor: Colors.redAccent,
                iconBackground: const Color(0xFFFFEEEE),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE4EAF2)),
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TODAY'S VISIT PLAN

  Widget _buildVisitPlan() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.fromLTRB(17, 20, 17, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE3EAF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TODAY',
                style: TextStyle(
                  color: blue,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              TextButton(
                onPressed: () {
  context.push('/worker-visits');
},
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: blue,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const Text(
            'Visit plan',
            style: TextStyle(
              color: navy,
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFEDF1F5), height: 1),
          if (todayVisits.isEmpty)
  const Padding(
    padding: EdgeInsets.all(20),
    child: Center(
      child: Text(
        'No pending household visits.',
        style: TextStyle(
          color: muted,
          fontSize: 12,
        ),
      ),
    ),
  )
else
  ...List.generate(
    todayVisits.length,
    (index) => _visitRow(todayVisits[index], index),
  ),
        ],
      ),
    );
  }

 Widget _visitRow(
  Map<String, dynamic> visit,
  int index,
) {
  final progress =
      visit['progress'] as Map<String, dynamic>;

  final status = progress['status']?.toString() ?? 'Pending';

  final householdName =
      visit['householdName']?.toString() ?? 'Household';

  final householdId = visit['id'].toString();

  final members =
      HouseholdDataStore.getHouseholdMembers(householdId);

  final times = ['09:30', '11:00', '14:30', '15:30', '16:30'];

  final time = times[index % times.length];

  final isPriority = index == 0;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        context.push(
          '/worker-household-details/$householdId',
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFEDF1F5),
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 45,
              child: Text(
                time,
                style: const TextStyle(
                  color: navy,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Container(
              height: 9,
              width: 9,
              decoration: BoxDecoration(
                color: isPriority
                    ? teal
                    : const Color(0xFFB8C5D5),
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    householdName,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '$householdId · ${members.length} members · $status',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: navy,
              size: 23,
            ),
          ],
        ),
      ),
    ),
  );
}
  // BOTTOM NAVIGATION

 Widget _buildBottomNavigation() {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
    currentIndex: selectedIndex,
    elevation: 0,

    selectedItemColor: blue,
    unselectedItemColor: const Color(0xFF8A9AAF),

    selectedFontSize: 9,
    unselectedFontSize: 9,

    selectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w800,
    ),

    unselectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w500,
    ),

    showSelectedLabels: true,
    showUnselectedLabels: true,

    onTap: _handleNavigationTap,

    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people_outline_rounded),
        label: 'Households',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment_outlined),
        label: 'Visits',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month_outlined),
        label: 'Follow-ups',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline_rounded),
        label: 'Profile',
      ),
    ],
  );
}
  String _formatDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}