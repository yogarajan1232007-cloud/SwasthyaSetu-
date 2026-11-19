import 'package:material_ui/material_ui.dart';

import 'hospital_referral_screen.dart';

class CitizenUpdatesScreen extends StatefulWidget {
  final VoidCallback? onReturnToHome;

  const CitizenUpdatesScreen({
    super.key,
    this.onReturnToHome,
  });

  @override
  State<CitizenUpdatesScreen> createState() =>
      _CitizenUpdatesScreenState();
}

class _CitizenUpdatesScreenState extends State<CitizenUpdatesScreen> {
  static const Color navy = Color(0xFF15385B);
  static const Color blue = Color(0xFF2864ED);
  static const Color muted = Color(0xFF71829B);
  static const Color background = Color(0xFFF3F7FC);

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Follow-up reminder',
      'description':
          'Your health worker visit is scheduled for 26 June at 10:00 AM.',
      'date': 'Today',
      'icon': Icons.calendar_today_outlined,
      'color': const Color(0xFFFF5267),
      'background': const Color(0xFFFFEDEF),
      'unread': true,
      'type': 'followup',
    },
    {
      'title': 'Health assessment ready',
      'description':
          'Your latest screening assessment is now available.',
      'date': 'Yesterday',
      'icon': Icons.favorite_border,
      'color': const Color(0xFF2864ED),
      'background': const Color(0xFFEAF0FF),
      'unread': true,
      'type': 'assessment',
    },
    {
      'title': 'Consultation confirmed',
      'description':
          'Coimbatore Medical College Hospital - 28 June, 9:30 AM',
      'date': '20 Jun',
      'icon': Icons.location_on_outlined,
      'color': const Color(0xFF2864ED),
      'background': const Color(0xFFEAF0FF),
      'unread': false,
      'type': 'referral',
    },
    {
      'title': 'Screening reminder',
      'description':
          'Your next routine screening is due in December.',
      'date': '18 Jun',
      'icon': Icons.assignment_outlined,
      'color': const Color(0xFF2864ED),
      'background': const Color(0xFFEAF0FF),
      'unread': false,
      'type': 'screening',
    },
  ];

  int get unreadCount =>
      notifications.where((item) => item['unread'] == true).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeading(),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 25),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = notifications[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: _buildNotificationCard(item),
                    );
                  },
                  childCount: notifications.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PAGE HEADING

  Widget _buildHeading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 27, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'UPDATES & REMINDERS',
                style: TextStyle(
                  color: blue,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              if (unreadCount > 0)
                TextButton(
                  onPressed: _markAllAsRead,
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      color: blue,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Notifications',
            style: TextStyle(
              color: navy,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Important actions and programme updates.',
            style: TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // NOTIFICATION CARD

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final bool unread = item['unread'] == true;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openNotification(item),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE2EAF3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 37,
                width: 37,
                decoration: BoxDecoration(
                  color: item['background'] as Color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['description'] as String,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 9,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['date'] as String,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              if (unread)
                Container(
                  height: 8,
                  width: 8,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: const BoxDecoration(
                    color: blue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // OPEN NOTIFICATION

  void _openNotification(Map<String, dynamic> item) {
    setState(() {
      item['unread'] = false;
    });

    final String type = item['type'] as String;

    // FOLLOW-UP REMINDER:
    // Open the Hospital Referral screen.
    if (type == 'followup') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const HospitalReferralScreen(),
        ),
      );
      return;
    }

    // ALL OTHER NOTIFICATIONS:
    // Return to Citizen Dashboard.
    _returnToHome();
  }

  // RETURN TO CITIZEN HOME

  void _returnToHome() {
    if (widget.onReturnToHome != null) {
      widget.onReturnToHome!.call();
      return;
    }

    // Fallback if the screen is opened as a separate route.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // MARK ALL AS READ

  void _markAllAsRead() {
    setState(() {
      for (final item in notifications) {
        item['unread'] = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
