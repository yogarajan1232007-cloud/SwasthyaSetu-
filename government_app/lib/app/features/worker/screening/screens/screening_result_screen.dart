import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../officer/households/data/household_data_store.dart';
import '../../../officer/assignments/data/assignment_data_store.dart';
import '../data/measurement_data_store.dart';

class ScreeningResultScreen extends StatefulWidget {
  final String householdId;
  final String individualId;

  const ScreeningResultScreen({
    super.key,
    required this.householdId,
    required this.individualId,
  });

  @override
  State<ScreeningResultScreen> createState() =>
      _ScreeningResultScreenState();
}

class _ScreeningResultScreenState
    extends State<ScreeningResultScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color teal = Color(0xFF0D9B8E);
  static const Color muted = Color(0xFF8292A8);
  static const Color background = Color(0xFFF4F7FC);

  bool isCompleting = false;

  // DEMONSTRATION VALUES ONLY.
  static const String diabetesRisk = 'Medium';
  static const String cardiovascularRisk = 'Low';

  Future<void> _completeScreening() async {
    if (isCompleting) return;

    setState(() => isCompleting = true);

    try {
      // 1. Verify the individual exists.
      final individual = HouseholdDataStore.getIndividualById(
        householdId: widget.householdId,
        individualId: widget.individualId,
      );

      if (individual == null) {
        throw Exception('Individual record not found.');
      }

      // 2. Verify consent.
      if (individual['consentStatus'] != 'Granted') {
        throw Exception(
          'Valid screening consent is required.',
        );
      }

      // 3. Verify measurements were saved.
      if (!MeasurementDataStore.hasRecord(
        widget.individualId,
      )) {
        throw Exception(
          'Please save the measurement records first.',
        );
      }

      // 4. Update individual screening status.
      final completed =
          HouseholdDataStore.markIndividualScreeningCompleted(
        householdId: widget.householdId,
        individualId: widget.individualId,
        recordedBy: 'Health Worker HW-2048',
      );

      if (!completed) {
        throw Exception(
          'Unable to update individual screening status.',
        );
      }

      // 5. Update household and assignment progress.
      AssignmentDataStore.syncHouseholdScreeningProgress(
        widget.householdId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Screening completed successfully!',
          ),
          backgroundColor: teal,
        ),
      );

      // 6. Return to Assigned Households.
      context.go('/worker-households');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isCompleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Screening Result',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildHeader(),

            const SizedBox(height: 22),

            _buildIndividualCard(),

            const SizedBox(height: 24),

            const Text(
              'Risk Assessment Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),

            const SizedBox(height: 14),

            _riskCard(
              title: 'Diabetes Risk',
              risk: diabetesRisk,
              description:
                  'Demonstration risk category for diabetes screening.',
              icon: Icons.bloodtype_outlined,
              color: const Color(0xFFD97706),
              cardColor: const Color(0xFFFFF7E6),
            ),

            const SizedBox(height: 13),

            _riskCard(
              title: 'Cardiovascular Risk',
              risk: cardiovascularRisk,
              description:
                  'Demonstration risk category for cardiovascular screening.',
              icon: Icons.favorite_outline,
              color: teal,
              cardColor: const Color(0xFFE5F6F2),
            ),

            const SizedBox(height: 24),

            _sectionTitle('Recommended Next Steps'),

            _recommendationCard(
              Icons.medical_services_outlined,
              'Healthcare Professional Review',
              'Have the collected measurements and medical history '
                  'reviewed by an authorised healthcare professional.',
            ),

            _recommendationCard(
              Icons.assignment_outlined,
              'Additional Clinical Tests',
              'A healthcare professional should decide whether '
                  'additional tests are required.',
            ),

            _recommendationCard(
              Icons.calendar_month_outlined,
              'Follow-up',
              'Schedule follow-up according to the approved '
                  'clinical screening protocol.',
            ),

            const SizedBox(height: 22),

            _buildDemoWarning(),

            const SizedBox(height: 25),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed:
                    isCompleting ? null : _completeScreening,
                icon: isCompleting
                    ? const SizedBox(
                        height: 19,
                        width: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  isCompleting
                      ? 'Completing...'
                      : 'Complete Screening',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF8CCBC3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Back to Summary'),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 42,
            color: blue,
          ),
          SizedBox(height: 12),
          Text(
            'Screening Assessment',
            style: TextStyle(
              color: navy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Illustrative risk categories for the application demo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Individual Information',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: navy,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 15),
          _detailRow('Household ID', widget.householdId),
          _detailRow('Individual ID', widget.individualId),
          _detailRow('Assessment Type', 'Demonstration'),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: navy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskCard({
    required String title,
    required String risk,
    required String description,
    required IconData icon,
    required Color color,
    required Color cardColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 43,
                width: 43,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  risk,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: const TextStyle(
              color: muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _recommendationCard(
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: blue),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
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

  Widget _buildDemoWarning() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFFFE2A8),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD97706),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'DEMO ONLY: Risk categories shown here are fixed '
              'illustrative values. They are not calculated from '
              'the individual measurements and must not be used '
              'for clinical decisions.',
              style: TextStyle(
                color: Color(0xFF805B18),
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}