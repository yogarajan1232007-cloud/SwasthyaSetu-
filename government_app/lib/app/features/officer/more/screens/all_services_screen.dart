import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  static const Color _background = Color(0xFFF4F7FC);
  static const Color _primary = Color(0xFF174A91);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _border = Color(0xFFE5ECF5);

  // ALL OFFICER SERVICES
  static const List<_ServiceItem> _services = [
    _ServiceItem(
      Icons.location_on_outlined,
      'Area management',
      'Manage programme areas',
      '/areas',
    ),
    _ServiceItem(
      Icons.people_outline,
      'Health workers',
      'Manage field workers',
      '/workers',
    ),
    _ServiceItem(
      Icons.add,
      'Create assignment',
      'Assign households to workers',
      '/create-assignment',
    ),
    _ServiceItem(
      Icons.person_outline,
      'Individuals',
      'Households and individuals',
      '/individuals',
    ),
    _ServiceItem(
      Icons.monitor_heart_outlined,
      'Screening monitoring',
      'Monitor community health screenings',
      '/screening-monitoring',
    ),
    _ServiceItem(
      Icons.folder_shared_outlined,
      'Medical reports',
      'View, upload and verify medical reports',
      '/medical-reports',
    ),
    _ServiceItem(
      Icons.show_chart,
      'AI risk monitoring',
      'Diabetes and CVD risk overview',
      '/risk-monitoring',
    ),
    _ServiceItem(
      Icons.warning_amber_outlined,
      'High-risk alerts',
      'Review priority cases',
      '/alerts',
    ),
    _ServiceItem(
      Icons.favorite_border,
      'Referral management',
      'Manage referrals and appointments',
      '/referrals',
    ),
    _ServiceItem(
      Icons.calendar_month_outlined,
      'Follow-up management',
      'Track follow-up activities',
      '/follow-ups',
    ),
    _ServiceItem(
      Icons.description_outlined,
      'Reports & analytics',
      'Programme reports and statistics',
      '/reports',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
          children: [
            const Text(
              'APPLICATION DIRECTORY',
              style: TextStyle(
                color: _blue,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'All services',
              style: TextStyle(
                color: _primary,
                fontSize: 23,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Access every module available for your role.',
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 23),

            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 520 ? 3 : 2;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _services.length,
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 11,
                    mainAxisSpacing: 11,
                    mainAxisExtent: 100,
                  ),
                  itemBuilder: (context, index) {
                    return _serviceCard(context, _services[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceCard(
    BuildContext context,
    _ServiceItem service,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.push(service.route),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF4FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  service.icon,
                  color: _blue,
                  size: 21,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: _primary,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String title;
  final String description;
  final String route;

  const _ServiceItem(
    this.icon,
    this.title,
    this.description,
    this.route,
  );
}