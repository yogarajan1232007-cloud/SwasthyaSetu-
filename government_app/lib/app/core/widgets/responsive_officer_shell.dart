import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class ResponsiveOfficerShell extends StatelessWidget {
  final Widget child;

  const ResponsiveOfficerShell({
    super.key,
    required this.child,
  });

  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F7FC);

  static const double desktopBreakpoint = 1100;
  static const double tabletBreakpoint = 700;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Mobile: preserve the existing screen layout.
        if (width < tabletBreakpoint) {
          return child;
        }

        // Tablet and desktop: display responsive navigation.
        final isDesktop = width >= desktopBreakpoint;

        return Scaffold(
          backgroundColor: background,
          body: Row(
            children: [
              _buildNavigation(
                context,
                expanded: isDesktop,
              ),

              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(context),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 1500,
                          ),
                          child: SizedBox.expand(
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigation(
    BuildContext context, {
    required bool expanded,
  }) {
    return Container(
      width: expanded ? 250 : 76,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
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

                if (expanded) ...[
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'SWASTHYASETU',
                      style: TextStyle(
                        color: navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 30),

          _navItem(
            context,
            Icons.dashboard_outlined,
            'Dashboard',
            '/dashboard',
            expanded,
          ),

          _navItem(
            context,
            Icons.people_outline,
            'Health Workers',
            '/workers',
            expanded,
          ),

          _navItem(
            context,
            Icons.groups_outlined,
            'Individuals',
            '/individuals',
            expanded,
          ),

          _navItem(
            context,
            Icons.warning_amber_outlined,
            'Alerts',
            '/alerts',
            expanded,
          ),

          _navItem(
            context,
            Icons.analytics_outlined,
            'Reports & Analytics',
            '/reports',
            expanded,
          ),

          _navItem(
            context,
            Icons.medical_services_outlined,
            'Screening Monitoring',
            '/screening-monitoring',
            expanded,
          ),

          _navItem(
            context,
            Icons.home_work_outlined,
            'Households',
            '/households',
            expanded,
          ),

          _navItem(
            context,
            Icons.assignment_outlined,
            'Assignments',
            '/assignments',
            expanded,
          ),

          _navItem(
            context,
            Icons.menu_book_outlined,
            'All Services',
            '/all-services',
            expanded,
          ),

          const Spacer(),

          const Divider(),

          _navItem(
            context,
            Icons.settings_outlined,
            'More',
            '/all-services',
            expanded,
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
    bool expanded,
  ) {
    final currentPath = GoRouterState.of(context).uri.path;

    final selected = currentPath == route;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.go(route),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFEAF1FF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 21,
                color: selected ? blue : Colors.blueGrey,
              ),

              if (expanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selected ? blue : navy,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE7EDF5),
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Government Health Programme',
            style: TextStyle(
              color: navy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const Spacer(),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: navy,
            ),
          ),

          const SizedBox(width: 8),

          const CircleAvatar(
            radius: 19,
            backgroundColor: Color(0xFFE2EDFC),
            child: Text(
              'AM',
              style: TextStyle(
                color: navy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}