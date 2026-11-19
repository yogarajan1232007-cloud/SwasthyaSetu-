import 'package:material_ui/material_ui.dart';

class HospitalReferralScreen extends StatelessWidget {
  const HospitalReferralScreen({super.key});

  static const Color navy = Color(0xFF15385B);
  static const Color blue = Color(0xFF2864ED);
  static const Color teal = Color(0xFF009D91);
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
              child: _buildHeader(context),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeading(),

                  const SizedBox(height: 24),

                  _buildAppointmentCard(),

                  const SizedBox(height: 24),

                  _buildHospitalCard(context),

                  const SizedBox(height: 24),

                  _buildBeforeVisitCard(),

                  const SizedBox(height: 22),

                  _buildDisclaimer(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8EDF4),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: navy,
              size: 19,
            ),
          ),

          const Expanded(
            child: Center(
              child: Text(
                'Hospital Referral',
                style: TextStyle(
                  color: navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('More options coming soon.'),
                ),
              );
            },
            icon: const Icon(
              Icons.menu,
              color: navy,
            ),
          ),
        ],
      ),
    );
  }

  // HEADING

  Widget _buildHeading() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CARE COORDINATION',
          style: TextStyle(
            color: blue,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),

        SizedBox(height: 11),

        Text(
          'Hospital referral',
          style: TextStyle(
            color: navy,
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 7),

        Text(
          'Your healthcare team has arranged a clinical consultation.',
          style: TextStyle(
            color: muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // APPOINTMENT CARD

  Widget _buildAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Colors.white,
                size: 25,
              ),

              const SizedBox(width: 13),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APPOINTMENT CONFIRMED',
                      style: TextStyle(
                        color: Color(0xFF5BE0CE),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),

                    SizedBox(height: 12),

                    Text(
                      'Saturday, 28 June',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 7),

                    Text(
                      '9:30 AM · Arrive 20 minutes early',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2D8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: Color(0xFFB87500),
                      size: 7,
                    ),

                    SizedBox(width: 5),

                    Text(
                      'Medium risk',
                      style: TextStyle(
                        color: Color(0xFFB87500),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // HOSPITAL CARD

  Widget _buildHospitalCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coimbatore Medical College Hospital',
            style: TextStyle(
              color: navy,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          const Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: muted,
                size: 15,
              ),

              SizedBox(width: 5),

              Expanded(
                child: Text(
                  'Trichy Road, Coimbatore – 641018',
                  style: TextStyle(
                    color: muted,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _actionButton(
                  Icons.location_on_outlined,
                  'Get directions',
                  () {
                    _showMessage(
                      context,
                      'Map directions will be connected later.',
                    );
                  },
                ),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: _actionButton(
                  Icons.call_outlined,
                  'Call hospital',
                  () {
                    _showMessage(
                      context,
                      'Hospital contact details will be connected later.',
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _detailRow(
            'Referral reason',
            'Review of screening indicators for blood glucose',
          ),

          const SizedBox(height: 10),

          _detailRow(
            'Department',
            'General Medicine · OP Block B',
          ),

          const SizedBox(height: 10),

          _detailRow(
            'Referral ID',
            'REF-CBE-2025-01842',
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: blue,
        side: const BorderSide(
          color: Color(0xFFE1E9F4),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),

            const SizedBox(width: 5),

            Text(
              label,
              style: const TextStyle(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(
              color: muted,
              fontSize: 9,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: navy,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // BEFORE VISIT

  Widget _buildBeforeVisitCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Before your visit',
            style: TextStyle(
              color: navy,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 13),

          _checkItem(
            'Bring your Individual Health ID or government-issued ID',
          ),

          const SizedBox(height: 11),

          _checkItem(
            'Carry a list of medicines you currently take',
          ),

          const SizedBox(height: 11),

          _checkItem(
            'Follow only instructions provided by your healthcare team',
          ),
        ],
      ),
    );
  }

  Widget _checkItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check,
          color: Color(0xFF159B54),
          size: 17,
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: muted,
              fontSize: 9,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // DISCLAIMER

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
            size: 21,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This referral supports further clinical assessment.',
                  style: TextStyle(
                    color: navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Your screening result is not a confirmed diagnosis.',
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: const Color(0xFFE2EAF3),
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
