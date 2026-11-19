import 'package:material_ui/material_ui.dart';

import 'healthy_guidance_screen.dart';

enum HealthAssessmentType {
  diabetes,
  cardiovascular,
}

class MyHealthScreen extends StatelessWidget {
  final HealthAssessmentType assessmentType;

  const MyHealthScreen({
    super.key,
    required this.assessmentType,
  });

  static const Color navy = Color(0xFF15385B);
  static const Color blue = Color(0xFF2864ED);
  static const Color muted = Color(0xFF71829B);
  static const Color background = Color(0xFFF3F7FC);

  bool get isDiabetes =>
      assessmentType == HealthAssessmentType.diabetes;

  String get diseaseName =>
      isDiabetes ? 'Diabetes' : 'Cardiovascular';

  String get riskLevel =>
      isDiabetes ? 'Medium risk' : 'Low risk';

  Color get riskColor => isDiabetes
      ? const Color(0xFFB87500)
      : const Color(0xFF13834B);

  Color get riskBackground => isDiabetes
      ? const Color(0xFFFFF5E5)
      : const Color(0xFFEAF8EF);

  String get explanation => isDiabetes
      ? 'This result does not mean you have diabetes. It means your screening information shows factors that the health team should monitor. Staying active, choosing balanced meals and attending your next screening can support your health.'
      : 'This screening result indicates that no priority cardiovascular risk indicators were identified in this demo record. Continue healthy habits and attend routine screenings as advised by your healthcare professional.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // FIX: The complete page is scrollable.
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  24,
                  16,
                  30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeading(),

                    const SizedBox(height: 24),

                    _buildRiskOverview(),

                    const SizedBox(height: 24),

                    _buildContributingFactors(),

                    const SizedBox(height: 24),

                    _buildAIExplanation(),

                    const SizedBox(height: 24),

                    _buildOtherRiskOverview(),

                    const SizedBox(height: 18),

                    _buildDisclaimer(),

                    const SizedBox(height: 20),

                    _buildGuidanceButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HEADER

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 49,
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
              size: 19,
              color: navy,
            ),
          ),

          const Expanded(
            child: Center(
              child: Text(
                'Health Assessment',
                style: TextStyle(
                  color: navy,
                  fontSize: 15,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'YOUR LATEST SCREENING',
          style: TextStyle(
            color: blue,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'My health assessment',
          style: TextStyle(
            color: navy,
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 7),

        const Text(
          '18 June 2025 · Reviewed by the health team',
          style: TextStyle(
            color: muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // RISK OVERVIEW

  Widget _buildRiskOverview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: riskBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDiabetes
              ? const Color(0xFFFFD995)
              : const Color(0xFFBDE7CC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${diseaseName.toUpperCase()} RISK',
                style: const TextStyle(
                  color: navy,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),

              const Spacer(),

              _riskBadge(riskLevel),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            riskLevel,
            style: const TextStyle(
              color: navy,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            isDiabetes
                ? 'Some of your screening results suggest you may benefit from simple preventive steps and routine follow-up.'
                : 'No priority indicators were found in this demo screening record. Continue routine monitoring.',
            style: const TextStyle(
              color: muted,
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskBadge(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: riskColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // CONTRIBUTING FACTORS

  Widget _buildContributingFactors() {
    final factors = isDiabetes
        ? [
            _Factor(
              Icons.water_drop_outlined,
              'Random blood glucose',
              '132 mg/dL · considered with measurement context',
            ),
            _Factor(
              Icons.people_outline,
              'Family health history',
              'Reported family history of diabetes',
            ),
            _Factor(
              Icons.person_outline,
              'Body mass index',
              'BMI 25.7 kg/m² · one of several factors',
            ),
          ]
        : [
            _Factor(
              Icons.favorite_outline,
              'Blood pressure',
              'Review of recorded blood pressure measurements',
            ),
            _Factor(
              Icons.monitor_heart_outlined,
              'Heart health history',
              'Review of reported cardiovascular history',
            ),
            _Factor(
              Icons.directions_walk_outlined,
              'Lifestyle information',
              'Physical activity and other reported habits',
            ),
          ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHY THIS RESULT?',
            style: TextStyle(
              color: blue,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Important contributing factors',
            style: TextStyle(
              color: navy,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          const Divider(
            color: Color(0xFFEDF1F6),
          ),

          ...factors.map(
            (factor) => _factorRow(factor),
          ),
        ],
      ),
    );
  }

  Widget _factorRow(_Factor factor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEDF1F6),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            factor.icon,
            color: blue,
            size: 21,
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  factor.title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  factor.description,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // AI EXPLANATION

  Widget _buildAIExplanation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF4FF),
        borderRadius: BorderRadius.circular(13),
        border: const Border(
          left: BorderSide(
            color: blue,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: blue,
                size: 17,
              ),

              SizedBox(width: 7),

              Text(
                'AI-GENERATED EXPLANATION',
                style: TextStyle(
                  color: blue,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          const Text(
            'What does this result mean?',
            style: TextStyle(
              color: navy,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            explanation,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 9),

          const Row(
            children: [
              Text(
                'How this was assessed',
                style: TextStyle(
                  color: blue,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),

              Icon(
                Icons.chevron_right,
                color: blue,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SECOND RISK OVERVIEW

  Widget _buildOtherRiskOverview() {
    final otherName = isDiabetes
        ? 'CARDIOVASCULAR RISK'
        : 'DIABETES RISK';

    final otherRisk = isDiabetes
        ? 'Low risk'
        : 'Medium risk';

    final otherColor = isDiabetes
        ? const Color(0xFF13834B)
        : const Color(0xFFB87500);

    final otherBackground = isDiabetes
        ? const Color(0xFFEAF8EF)
        : const Color(0xFFFFF5E5);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: otherBackground,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: otherColor.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                otherName,
                style: const TextStyle(
                  color: navy,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const Spacer(),

              Icon(
                Icons.circle,
                color: otherColor,
                size: 8,
              ),

              const SizedBox(width: 5),

              Text(
                otherRisk,
                style: TextStyle(
                  color: otherColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            otherRisk,
            style: const TextStyle(
              color: navy,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'This is an illustrative demo result. Refer to your actual screening report and healthcare professional for interpretation.',
            style: TextStyle(
              color: muted,
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // DISCLAIMER

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E6),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFAD7100),
            size: 21,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important',
                  style: TextStyle(
                    color: Color(0xFF865600),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'These results support preliminary screening and prioritisation. They are not a confirmed diagnosis. Clinical assessment by a qualified healthcare professional is required.',
                  style: TextStyle(
                    color: Color(0xFF8C7146),
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

  // GUIDANCE BUTTON

  Widget _buildGuidanceButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 49,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HealthyGuidanceScreen(
                focus: isDiabetes
                    ? 'diabetes'
                    : 'cardiovascular',
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'View healthy living guidance',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),

            SizedBox(width: 9),

            Icon(
              Icons.chevron_right,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: const Color(0xFFE3EAF3),
      ),
    );
  }
}

class _Factor {
  final IconData icon;
  final String title;
  final String description;

  const _Factor(
    this.icon,
    this.title,
    this.description,
  );
}