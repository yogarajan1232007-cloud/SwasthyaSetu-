import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const Color _background = Color(0xFFF4F7FC);
  static const Color _primary = Color(0xFF174A91);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _border = Color(0xFFE5ECF5);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _background,
      child: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                  const SizedBox(height: 2),
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: Color(0xFFE0EBFA),
                    child: Text(
                      'DA',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Dr. Ananya Meera',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'District Health Officer · HO-1024',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF718096), fontSize: 11),
                  ),
                  const SizedBox(height: 9),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F8EF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Verified profile',
                        style: TextStyle(
                          color: Color(0xFF16834A),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _settingsCard(context),
                  const SizedBox(height: 23),
                  OutlinedButton(
                    onPressed: () => context.push('/all-services'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      alignment: Alignment.centerLeft,
                      foregroundColor: _blue,
                      side: const BorderSide(color: Color(0xFFC8D9F5)),
                      backgroundColor: const Color(0xFFEDF4FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.menu, size: 19),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Open all programme services',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 22),
                      ],
                    ),
                  ),
                  const SizedBox(height: 23),
                  OutlinedButton(
                    onPressed: () => _confirmSignOut(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(43),
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFF2CACA)),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign out',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SwasthyaSetu · Version 1.0 · Sample prototype data',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8290A3), fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Container(
            height: 39,
            width: 39,
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SWASTHYASETU',
                  style: TextStyle(
                    color: _primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Coimbatore District · North Zone Programme',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF718096), fontSize: 9),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: _primary,
            ),
          ),
          const CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFFE0EBFA),
            child: Text(
              'AM',
              style: TextStyle(
                color: _primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard(BuildContext context) {
    final items = <(IconData, String, String)>[
      (Icons.person_outline, 'Personal information', 'View officer profile details.'),
      (Icons.location_on_outlined, 'Assigned area', 'View the officer assigned district, zone and service areas.'),
      (Icons.shield_outlined, 'Privacy & consent', 'Privacy and consent information for the screening programme.'),
      (Icons.notifications_none, 'Notification settings', 'Notification preferences will be connected here.'),
      (Icons.menu, 'Language · English / தமிழ்', 'Language selection will be connected here.'),
      (Icons.description_outlined, 'Help & accessibility', 'Help, support and accessibility information.'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              InkWell(
                onTap: () => _showSetting(context, item.$2, item.$3),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDF4FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.$1, color: _blue, size: 19),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          item.$2,
                          style: const TextStyle(
                            color: _primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: _primary, size: 21),
                    ],
                  ),
                ),
              ),
              if (index != items.length - 1)
                const Divider(height: 1, color: Color(0xFFEEF2F7)),
            ],
          );
        }),
      ),
    );
  }

  void _showSetting(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Are you sure you want to sign out of SwasthyaSetu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.go('/login');
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
