import 'package:material_ui/material_ui.dart';

class CitizenProfileScreen extends StatelessWidget {
  final VoidCallback? onSignOut;

  const CitizenProfileScreen({
    super.key,
    this.onSignOut,
  });

  static const Color navy = Color(0xFF15385B);
  static const Color blue = Color(0xFF2864ED);
  static const Color muted = Color(0xFF71829B);
  static const Color background = Color(0xFFF3F7FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildProfileHeader(),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 25, 16, 25),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildOptionsCard(context),
                  const SizedBox(height: 24),
                  _buildSignOutButton(context),
                  const SizedBox(height: 24),
                  _buildFooter(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PROFILE HEADER

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Color(0xFFDCE9F8),
            child: Text(
              'RM',
              style: TextStyle(
                color: navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Rajesh M.',
            style: TextStyle(
              color: navy,
              fontSize: 19,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Individual ID · IND-CBE-10482',
            style: TextStyle(
              color: muted,
              fontSize: 9,
            ),
          ),

          const SizedBox(height: 7),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F8EF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Verified profile',
              style: TextStyle(
                color: Color(0xFF16864D),
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PROFILE OPTIONS

  Widget _buildOptionsCard(BuildContext context) {
    final options = [
      {
        'title': 'Personal information',
        'icon': Icons.person_outline_rounded,
        'message': 'Personal information',
        'description':
            'Name: Rajesh M.\nIndividual ID: IND-CBE-10482\nProfile status: Verified',
      },
      {
        'title': 'Address & contact',
        'icon': Icons.location_on_outlined,
        'message': 'Address & contact',
        'description':
            'Your registered address and contact details will be displayed here.',
      },
      {
        'title': 'Privacy & consent',
        'icon': Icons.shield_outlined,
        'message': 'Privacy & consent',
        'description':
            'Review your data privacy information and screening consent preferences.',
      },
      {
        'title': 'Notification settings',
        'icon': Icons.notifications_none_rounded,
        'message': 'Notification settings',
        'description':
            'Manage screening reminders, follow-up alerts and programme notifications.',
      },
      {
        'title': 'Language · English / தமிழ்',
        'icon': Icons.menu_rounded,
        'message': 'Language preferences',
        'description':
            'Language selection will support English and Tamil in a future update.',
      },
      {
        'title': 'Help & accessibility',
        'icon': Icons.description_outlined,
        'message': 'Help & accessibility',
        'description':
            'Help and accessibility information for using SwasthyaSetu.',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2EAF3),
        ),
      ),
      child: Column(
        children: List.generate(options.length, (index) {
          final option = options[index];

          return Column(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _showOptionDetails(
                    context,
                    option['message'] as String,
                    option['description'] as String,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF1FF),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          option['icon'] as IconData,
                          color: blue,
                          size: 19,
                        ),
                      ),

                      const SizedBox(width: 11),

                      Expanded(
                        child: Text(
                          option['title'] as String,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.chevron_right,
                        color: navy,
                        size: 21,
                      ),
                    ],
                  ),
                ),
              ),

              if (index != options.length - 1)
                const Divider(
                  height: 1,
                  thickness: 0.7,
                  color: Color(0xFFEAF0F6),
                  indent: 12,
                  endIndent: 12,
                ),
            ],
          );
        }),
      ),
    );
  }

  // OPTION DETAILS

  void _showOptionDetails(
    BuildContext context,
    String title,
    String description,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            description,
            style: const TextStyle(
              color: muted,
              fontSize: 13,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // SIGN OUT

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 41,
      child: OutlinedButton(
        onPressed: () => _confirmSignOut(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(
            color: Color(0xFFFFC5C5),
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: const Text(
          'Sign out',
          style: TextStyle(
            color: Colors.red,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          title: const Text(
            'Sign out?',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out of SwasthyaSetu?',
            style: TextStyle(
              color: muted,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onSignOut?.call();
              },
              child: const Text(
                'Sign out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // FOOTER

  Widget _buildFooter() {
    return const Center(
      child: Column(
        children: [
          Text(
            'SwasthyaSetu · Version 1.0 · Sample prototype data',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}