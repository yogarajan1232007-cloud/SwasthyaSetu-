import 'package:material_ui/material_ui.dart';

class HealthyGuidanceScreen extends StatefulWidget {
  final String focus;

  const HealthyGuidanceScreen({
    super.key,
    required this.focus,
  });

  @override
  State<HealthyGuidanceScreen> createState() =>
      _HealthyGuidanceScreenState();
}

class _HealthyGuidanceScreenState
    extends State<HealthyGuidanceScreen> {
  static const Color navy = Color(0xFF15385B);
  static const Color blue = Color(0xFF2864ED);
  static const Color teal = Color(0xFF009D91);
  static const Color muted = Color(0xFF71829B);
  static const Color background = Color(0xFFF3F7FC);

  int? expandedIndex = 0;

  final List<_GuidanceModule> modules = const [
    _GuidanceModule(
      icon: Icons.directions_walk_outlined,
      title: 'Walking & activity',
      subtitle: 'Build movement into your day',
      color: Color(0xFF2864ED),
      tips: [
        'Start with short, comfortable walks and gradually increase your activity.',
        'Choose activities that you enjoy, such as walking, cycling or dancing.',
        'Break up long periods of sitting with regular movement.',
        'Follow your healthcare professional’s advice if you have symptoms or activity limitations.',
      ],
    ),

    _GuidanceModule(
      icon: Icons.favorite_border,
      title: 'Healthy food',
      subtitle: 'Choose balanced everyday meals',
      color: Color(0xFF2864ED),
      tips: [
        'Include vegetables, fruits, whole grains and pulses in your meals.',
        'Choose fibre-rich foods such as vegetables, beans and whole grains.',
        'Limit sugary drinks and foods high in added sugar.',
        'Reduce excess salt and highly processed foods.',
        'Choose appropriate portions and maintain regular meal habits.',
      ],
    ),

    _GuidanceModule(
      icon: Icons.person_outline,
      title: 'Sleep & routine',
      subtitle: 'Protect your regular sleep time',
      color: Color(0xFF2864ED),
      tips: [
        'Try to maintain a consistent sleep and wake-up schedule.',
        'Create a quiet and comfortable sleeping environment.',
        'Reduce screen use close to bedtime.',
        'Include relaxing activities in your evening routine.',
        'Speak with a healthcare professional if sleep problems persist.',
      ],
    ),

    _GuidanceModule(
      icon: Icons.show_chart_rounded,
      title: 'Weight management',
      subtitle: 'Focus on steady, healthy habits',
      color: Color(0xFF2864ED),
      tips: [
        'Focus on sustainable food and activity habits rather than rapid weight changes.',
        'Monitor weight periodically if advised by your healthcare professional.',
        'Combine balanced meals with regular physical activity.',
        'Avoid crash diets and unverified weight-loss products.',
        'Seek professional guidance for an appropriate personal plan.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(17, 24, 17, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeading(),

                    const SizedBox(height: 24),

                    _buildWeeklyFocus(),

                    const SizedBox(height: 24),

                    const Text(
                      'YOUR HEALTH HABITS',
                      style: TextStyle(
                        color: blue,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 13),

                    ...List.generate(
                      modules.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildModule(index),
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildGuidanceDisclaimer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER

  Widget _buildHeader() {
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
              color: navy,
              size: 19,
            ),
          ),

          const Expanded(
            child: Center(
              child: Text(
                'Healthy Living Guidance',
                style: TextStyle(
                  color: navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(width: 45),
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
          'PREVENTIVE HEALTH GUIDANCE',
          style: TextStyle(
            color: blue,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),

        SizedBox(height: 11),

        Text(
          'Small steps for better health',
          style: TextStyle(
            color: navy,
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 7),

        Text(
          'Simple, approved guidance based on your screening context.',
          style: TextStyle(
            color: muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // WEEKLY FOCUS

  Widget _buildWeeklyFocus() {
    final isDiabetes = widget.focus == 'diabetes';

    final focusTitle = isDiabetes
        ? 'Build balanced daily habits'
        : 'Make heart-friendly choices';

    final focusDescription = isDiabetes
        ? 'Choose balanced meals and include regular physical activity in your routine.'
        : 'Stay active, choose balanced foods and make time for regular rest.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: teal,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            height: 49,
            width: 49,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.directions_walk,
              color: Colors.white,
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'THIS WEEK\'S FOCUS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 9),

                Text(
                  focusTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  focusDescription,
                  style: const TextStyle(
                    color: Colors.white,
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

  // GUIDANCE MODULE

  Widget _buildModule(int index) {
    final module = modules[index];
    final isExpanded = expandedIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2EAF3),
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  expandedIndex =
                      isExpanded ? null : index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      height: 39,
                      width: 39,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF0FF),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        module.icon,
                        color: module.color,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.title,
                            style: const TextStyle(
                              color: navy,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            module.subtitle,
                            style: const TextStyle(
                              color: muted,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.chevron_right,
                      color: navy,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (isExpanded) ...[
            const Divider(
              height: 1,
              color: Color(0xFFEDF1F6),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRACTICAL HEALTH HABITS',
                    style: TextStyle(
                      color: blue,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 11),

                  ...module.tips.map(
                    (tip) => _buildTip(tip),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: teal,
            size: 17,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                color: navy,
                fontSize: 10,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DISCLAIMER

  Widget _buildGuidanceDisclaimer() {
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
                  'General preventive guidance only',
                  style: TextStyle(
                    color: navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'This app does not prescribe medicines or treatment. Speak to a qualified healthcare professional for personal medical advice.',
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
}

class _GuidanceModule {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final List<String> tips;

  const _GuidanceModule({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.tips,
  });
}