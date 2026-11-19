import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({super.key});

  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color teal = Color(0xFF0D998D);
  static const Color muted = Color(0xFF718096);
  static const Color background = Color(0xFFF3F7FC);

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


void _showLogoutDialog(BuildContext context) {
  showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout from SwasthyaSetu?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(17),
          children: [
            _buildProfileHeader(),

            const SizedBox(height: 20),

            _buildPerformanceCard(),

            const SizedBox(height: 24),

            _sectionTitle('Personal Information'),

            const SizedBox(height: 12),

            _buildInformationCard(),

            const SizedBox(height: 24),

            _sectionTitle('Work Information'),

            const SizedBox(height: 12),

            _buildWorkCard(),

            const SizedBox(height: 24),

            _sectionTitle('Account & Support'),

            const SizedBox(height: 12),

            _buildSettingsCard(context),

            const SizedBox(height: 24),

            _buildLogoutButton(context),

            const SizedBox(height: 22),

            const Center(
              child: Text(
                'SwasthyaSetu Community Health System',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 5),

            const Center(
              child: Text(
                'Version 1.0.0 • Demo',
                style: TextStyle(
                  color: muted,
                  fontSize: 9,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // PROFILE HEADER
  // =====================================================

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 88,
                width: 88,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF67D7C5),
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'SK',
                    style: TextStyle(
                      color: navy,
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  height: 17,
                  width: 17,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: navy,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Text(
            'S. Kavitha',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Community Health Worker',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: Color(0xFF67D7C5),
                  size: 15,
                ),
                SizedBox(width: 7),
                Text(
                  'HW-2048',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF67D7C5),
                size: 16,
              ),
              const SizedBox(width: 5),
              const Text(
                'Ukkadam North',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ACTIVE WORKER',
              style: TextStyle(
                color: Color(0xFF15803D),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PERFORMANCE
  // =====================================================

  Widget _buildPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4EAF2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Performance',
            style: TextStyle(
              color: navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _performanceItem(
                  'ASSIGNED',
                  '12',
                  Icons.home_work_outlined,
                  blue,
                ),
              ),
              Expanded(
                child: _performanceItem(
                  'SCREENED',
                  '08',
                  Icons.health_and_safety_outlined,
                  teal,
                ),
              ),
              Expanded(
                child: _performanceItem(
                  'PENDING',
                  '04',
                  Icons.pending_actions_outlined,
                  const Color(0xFFD18A00),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Screening Progress',
                style: TextStyle(
                  color: navy,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '67%',
                style: TextStyle(
                  color: teal,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.67,
              minHeight: 9,
              backgroundColor: Color(0xFFE8EEF5),
              valueColor: AlwaysStoppedAnimation<Color>(teal),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            '8 out of 12 assigned households completed.',
            style: TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _performanceItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          height: 39,
          width: 39,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          value,
          style: const TextStyle(
            color: navy,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          title,
          style: const TextStyle(
            color: muted,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // SECTION TITLE
  // =====================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: navy,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // =====================================================
  // PERSONAL INFORMATION
  // =====================================================

  Widget _buildInformationCard() {
    return _whiteCard(
      children: [
        _informationRow(
          Icons.person_outline,
          'Full Name',
          'S. Kavitha',
        ),
        _divider(),
        _informationRow(
          Icons.badge_outlined,
          'Worker ID',
          'HW-2048',
        ),
        _divider(),
        _informationRow(
          Icons.work_outline,
          'Designation',
          'Community Health Worker',
        ),
        _divider(),
        _informationRow(
          Icons.phone_outlined,
          'Phone Number',
          'Not provided',
        ),
        _divider(),
        _informationRow(
          Icons.email_outlined,
          'Email Address',
          'Not provided',
        ),
      ],
    );
  }

  // =====================================================
  // WORK INFORMATION
  // =====================================================

  Widget _buildWorkCard() {
    return _whiteCard(
      children: [
        _informationRow(
          Icons.location_on_outlined,
          'Assigned Area',
          'Ukkadam North',
        ),
        _divider(),
        _informationRow(
          Icons.verified_user_outlined,
          'Worker Status',
          'Active',
          valueColor: teal,
        ),
        _divider(),
        _informationRow(
          Icons.calendar_month_outlined,
          'Programme',
          'Community Health Screening',
        ),
        _divider(),
        _informationRow(
          Icons.medical_information_outlined,
          'Screening Focus',
          'Diabetes & CVD',
        ),
      ],
    );
  }

  // =====================================================
  // INFORMATION ROW
  // =====================================================

  Widget _informationRow(
    IconData icon,
    String title,
    String value, {
    Color valueColor = navy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Container(
            height: 37,
            width: 37,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: blue,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // SETTINGS
  // =====================================================

  Widget _buildSettingsCard(BuildContext context) {
    return _whiteCard(
      children: [
        _settingsItem(
          Icons.settings_outlined,
          'Account Settings',
          'Manage your account preferences',
          () => _showMessage(
            context,
            'Account settings will be connected later.',
          ),
        ),

        _divider(),

        _settingsItem(
          Icons.notifications_none_outlined,
          'Notifications',
          'Manage notification preferences',
          () => _showMessage(
            context,
            'Notification settings will be connected later.',
          ),
        ),

        _divider(),

        _settingsItem(
          Icons.help_outline,
          'Help & Support',
          'Get assistance with the application',
          () => _showMessage(
            context,
            'Help and support will be connected later.',
          ),
        ),

        _divider(),

        _settingsItem(
          Icons.info_outline,
          'About SwasthyaSetu',
          'Application information',
          () => _showMessage(
            context,
            'SwasthyaSetu Community Health Screening System.',
          ),
        ),
      ],
    );
  }

  
    
Widget _settingsItem(
  IconData icon,
  String title,
  String subtitle,
  VoidCallback onTap,
) {
  return Material(
    color: Colors.transparent,
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 4,
      ),
      leading: Container(
        height: 39,
        width: 39,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FF),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          icon,
          color: blue,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: navy,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: muted,
          fontSize: 10,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: muted,
      ),
      onTap: onTap,
    ),
  );
}

  // =====================================================
  // WHITE CARD
  // =====================================================

  Widget _whiteCard({
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE4EAF2),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      color: Color(0xFFEDF1F6),
    );
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 51,
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(
            color: Color(0xFFFFCDD2),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }
}
