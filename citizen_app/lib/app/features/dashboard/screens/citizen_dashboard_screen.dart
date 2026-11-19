import 'package:material_ui/material_ui.dart';
import '../../health/screens/my_health_screen.dart';
import '../../health/screens/health_report_screen.dart';
import '../../trends/screens/health_trends_screen.dart';
import '../../updates/screens/citizen_updates_screen.dart';
import '../../profile/screens/citizen_profile_screen.dart';
import '../../authentication/screens/citizen_login_screen.dart';
import '../../health/screens/healthy_guidance_screen.dart';
import '../../updates/screens/add_reminder_screen.dart';

class CitizenDashboardScreen extends StatefulWidget {
  const CitizenDashboardScreen({super.key});

  @override
  State<CitizenDashboardScreen> createState() =>
      _CitizenDashboardScreenState();
}

class _CitizenDashboardScreenState
    extends State<CitizenDashboardScreen> {
  static const Color navy = Color(0xFF15385B);
  static const Color blue = Color(0xFF2864ED);
  static const Color teal = Color(0xFF009D91);
  static const Color background = Color(0xFFF3F7FC);
  static const Color muted = Color(0xFF71829B);

  int selectedIndex = 0;

  final String citizenName = 'Rajesh';
  final String healthId = 'SH-2025-00124';

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
            child: Row(
              children: [
                if (isDesktop) _buildDesktopNavigation(),
                if (isTablet) _buildTabletNavigation(),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280),
                      child: IndexedStack(
                        index: selectedIndex,
                        children: [
                          _buildHomePage(),
                          const HealthReportScreen(),
                          const HealthTrendsScreen(),
                          CitizenUpdatesScreen(
                            onReturnToHome: () {
                              setState(() {
                                selectedIndex = 0;
                              });
                            },
                          ),
                          CitizenProfileScreen(
                            onSignOut: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const CitizenLoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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

  void _selectNavigation(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget _buildDesktopNavigation() {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.favorite_border_rounded, Icons.favorite_rounded, 'My Health'),
      (Icons.show_chart_rounded, Icons.show_chart_rounded, 'Trends'),
      (Icons.notifications_none_rounded, Icons.notifications_rounded, 'Updates'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];

    return Container(
      width: 238,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE8EDF4))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 16, 28),
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
                        'MY COMMUNITY',
                        style: TextStyle(
                          color: muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'SwasthyaSetu',
                        style: TextStyle(
                          color: navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 16, 10),
            child: Text(
              'MY HEALTH',
              style: TextStyle(
                color: muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          for (var i = 0; i < items.length; i++)
            _desktopNavItem(
              i,
              items[i].$1,
              items[i].$2,
              items[i].$3,
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Your community health information in one place.',
                style: TextStyle(color: muted, fontSize: 10, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _desktopNavItem(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    final selected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected ? const Color(0xFFEAF0FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _selectNavigation(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            child: Row(
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  size: 19,
                  color: selected ? blue : muted,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? blue : navy,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
        border: Border(right: BorderSide(color: Color(0xFFE8EDF4))),
      ),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: _selectNavigation,
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
            icon: Icon(Icons.favorite_border_rounded),
            label: Text('My Health'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.show_chart_rounded),
            label: Text('Trends'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.notifications_none_rounded),
            label: Text('Updates'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: Text('Profile'),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // HOME DASHBOARD
  // =====================================================

  Widget _buildHomePage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 900 ? 30.0 : 18.0;
        return CustomScrollView(
          slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),

        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            18,
            horizontalPadding,
            25,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildWelcome(),

              const SizedBox(height: 22),

              _buildScreeningStatus(),

              const SizedBox(height: 18),

              _buildNextScreening(),

              const SizedBox(height: 29),

              _sectionHeading(
                'YOUR RESULTS',
                'Health risk overview',
                action: 'Learn more',
                onAction: () => setState(() {
                  selectedIndex = 1;
                }),
              ),

              const SizedBox(height: 15),

              _buildRiskCard(
                title: 'DIABETES',
                risk: 'Medium risk',
                description:
                    'Your blood glucose and family history are important factors.',
                icon: Icons.water_drop_outlined,
                iconColor: const Color(0xFF8057E8),
                backgroundColor: const Color(0xFFF1EBFF),
                riskColor: const Color(0xFFB87500),
                riskBackground: const Color(0xFFFFF3D8),
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const MyHealthScreen(
        assessmentType: HealthAssessmentType.diabetes,
      ),
    ),
  );
},
              ),

              const SizedBox(height: 12),

              _buildRiskCard(
                title: 'HEART HEALTH',
                risk: 'Low risk',
                description:
                    'Your recent measurements are within the screening range.',
                icon: Icons.favorite_outline,
                iconColor: const Color(0xFFFF5267),
                backgroundColor: const Color(0xFFFFEDEF),
                riskColor: const Color(0xFF13834B),
                riskBackground: const Color(0xFFE8F8EF),
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const MyHealthScreen(
        assessmentType: HealthAssessmentType.cardiovascular,
      ),
    ),
  );
},
              ),

              const SizedBox(height: 29),

              _sectionHeading(
                'EXPLORE',
                'Your health tools',
              ),

              const SizedBox(height: 15),

              _buildHealthTool(
                Icons.description_outlined,
                'View health report',
                'Your latest measurements',
                () => setState(() {
                  selectedIndex = 1;
                }),
              ),

              const SizedBox(height: 11),

              _buildHealthTool(
                Icons.show_chart_rounded,
                'Understand health trends',
                'See changes over time',
                () => setState(() {
                  selectedIndex = 2;
                }),
              ),

              const SizedBox(height: 11),

             _buildHealthTool(
  Icons.directions_walk_outlined,
  'Healthy living guidance',
  'Simple steps for you',
  () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HealthyGuidanceScreen(
          focus: 'diabetes',
        ),
      ),
    );
  },
),
              const SizedBox(height: 17),

              _buildDisclaimer(),

              const SizedBox(height: 15),
            ]),
          ),
        ),
          ],
        );
      },
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE9EEF5),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 37,
            width: 37,
            decoration: BoxDecoration(
              color: navy,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MY COMMUNITY',
                  style: TextStyle(
                    color: muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'SwasthyaSetu',
                  style: TextStyle(
                    color: navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () => setState(() {
              selectedIndex = 3;
            }),
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: navy,
            ),
          ),

          const SizedBox(width: 5),

          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE3EDFA),
            child: Text(
              citizenName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: navy,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // WELCOME
  // =====================================================

  Widget _buildWelcome() {
    final now = DateTime.now();

    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL',
      'MAY', 'JUNE', 'JULY', 'AUGUST',
      'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];

    const days = [
      'MONDAY', 'TUESDAY', 'WEDNESDAY',
      'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}',
          style: const TextStyle(
            color: teal,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          'Vanakkam, $citizenName',
          style: const TextStyle(
            color: navy,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Here is your latest health screening overview.',
          style: TextStyle(
            color: muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // SCREENING STATUS
  // =====================================================

  Widget _buildScreeningStatus() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: teal,
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.favorite_outline,
              color: Color(0xFF66D9CD),
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCREENING STATUS',
                  style: TextStyle(
                    color: Color(0xFF64DCD0),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Your screening is complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 7),

                Text(
                  'Reviewed on 18 June 2025',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          const CircleAvatar(
            radius: 12,
            backgroundColor: Color(0xFF17A85B),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // NEXT SCREENING
  // =====================================================

  Widget _buildNextScreening() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2EAF3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            color: blue,
            size: 23,
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR NEXT ROUTINE SCREENING',
                  style: TextStyle(
                    color: muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  '18 December 2025',
                  style: TextStyle(
                    color: navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const AddReminderScreen(),
    ),
  );

  if (!mounted || result == null) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Your screening reminder has been saved.'),
      behavior: SnackBarBehavior.floating,
    ),
  );
},
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFEAF0FF),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 9,
              ),
            ),
            child: const Text(
              'Add reminder',
              style: TextStyle(
                color: blue,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SECTION HEADING
  // =====================================================

  Widget _sectionHeading(
    String eyebrow,
    String title, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              eyebrow,
              style: const TextStyle(
                color: blue,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),

            if (action != null)
              TextButton(
                onPressed: onAction,
                child: Text(
                  action,
                  style: const TextStyle(
                    color: blue,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),

        Text(
          title,
          style: const TextStyle(
            color: navy,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // RISK CARD
  // =====================================================

  Widget _buildRiskCard({
    required String title,
    required String risk,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color riskColor,
    required Color riskBackground,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFE2EAF3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        risk,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 13),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: riskBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                        color: riskColor,
                        shape: BoxShape.circle,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      risk,
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                description,
                style: const TextStyle(
                  color: muted,
                  fontSize: 10,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Text(
                    'See what this means',
                    style: TextStyle(
                      color: blue,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Icon(
                    Icons.chevron_right,
                    color: blue,
                    size: 17,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // HEALTH TOOLS
  // =====================================================

  Widget _buildHealthTool(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: const Color(0xFFE2EAF3),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 39,
                width: 39,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: blue,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: navy,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // DISCLAIMER
  // =====================================================

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: Color(0xFF54799F),
            size: 20,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A note about your results',
                  style: TextStyle(
                    color: navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'These results support screening and are not a diagnosis. A qualified healthcare professional will guide you on any next steps.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 9,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
 
  // =====================================================
  // BOTTOM NAVIGATION
  // =====================================================

  Widget _buildBottomNavigation() {
    const items = [
      Icons.home_rounded,
      Icons.favorite_border_rounded,
      Icons.show_chart_rounded,
      Icons.notifications_none_rounded,
      Icons.person_outline_rounded,
    ];

    const labels = [
      'Home',
      'My Health',
      'Trends',
      'Updates',
      'Profile',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE8EDF4),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = selectedIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[index],
                        color: selected ? blue : muted,
                        size: 23,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        labels[index],
                        style: TextStyle(
                          color: selected ? blue : muted,
                          fontSize: 9,
                          fontWeight: selected
                              ? FontWeight.w900
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

 
}
