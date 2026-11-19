import 'package:material_ui/material_ui.dart';

class HealthTrendsScreen extends StatefulWidget {
  const HealthTrendsScreen({super.key});

  @override
  State<HealthTrendsScreen> createState() =>
      _HealthTrendsScreenState();
}

class _HealthTrendsScreenState extends State<HealthTrendsScreen> {
  static const Color navy = Color(0xFF15385B);
  static const Color blue = Color(0xFF2864ED);
  static const Color muted = Color(0xFF71829B);
  static const Color background = Color(0xFFF3F7FC);

  int selectedMetric = 0;

  bool get isGlucose => selectedMetric == 0;

  String get metricTitle =>
      isGlucose ? 'Blood glucose' : 'Blood pressure';

  String get metricValue =>
      isGlucose ? '132' : '128/82';

  String get metricUnit =>
      isGlucose ? 'mg/dL' : 'mmHg';

  String get estimatedRange =>
      isGlucose ? '128–142' : '118–132';

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
                delegate: SliverChildListDelegate([
                  _buildMetricSelector(),

                  const SizedBox(height: 24),

                  _buildTrendCard(),

                  const SizedBox(height: 24),

                  _buildExplanation(),

                  const SizedBox(height: 16),

                  _buildEstimateDisclaimer(),

                  const SizedBox(height: 16),

                  _buildUnavailableCard(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADING

  Widget _buildHeading() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ESTIMATED HEALTH OUTLOOK',
            style: TextStyle(
              color: blue,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          SizedBox(height: 11),

          Text(
            'Future health trends',
            style: TextStyle(
              color: navy,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 7),

          Text(
            'See how eligible repeated measurements may change over time.',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // METRIC SELECTOR

  Widget _buildMetricSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0F7),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          _metricTab('Blood glucose', 0),

          _metricTab('Blood pressure', 1),
        ],
      ),
    );
  }

  Widget _metricTab(String title, int index) {
    final selected = selectedMetric == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedMetric = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: navy.withValues(alpha: 0.07),
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? navy : muted,
              fontSize: 10,
              fontWeight: selected
                  ? FontWeight.w900
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // TREND CARD

  Widget _buildTrendCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HISTORY & ESTIMATE',
                      style: TextStyle(
                        color: blue,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),

                    SizedBox(height: 9),
                  ],
                ),
              ),

              const Text(
                '6 months',
                style: TextStyle(
                  color: blue,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          Text(
            '$metricTitle trend',
            style: const TextStyle(
              color: navy,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 15),

          _buildLegend(),

          const SizedBox(height: 8),

          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _TrendPainter(
                isGlucose: isGlucose,
              ),
              child: const SizedBox.expand(),
            ),
          ),

          const SizedBox(height: 12),

          _buildCurrentAndEstimate(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 15,
          height: 2,
          color: blue,
        ),

        const SizedBox(width: 5),

        const Text(
          'Recorded',
          style: TextStyle(
            color: muted,
            fontSize: 8,
          ),
        ),

        const SizedBox(width: 12),

        SizedBox(
          width: 15,
          child: CustomPaint(
            painter: _DashedLinePainter(),
            child: const SizedBox(height: 2),
          ),
        ),

        const SizedBox(width: 5),

        const Text(
          'Estimated trend',
          style: TextStyle(
            color: muted,
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentAndEstimate() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT',
                  style: TextStyle(
                    color: muted,
                    fontSize: 8,
                  ),
                ),

                const SizedBox(height: 7),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        metricValue,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(width: 4),

                      Text(
                        metricUnit,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.chevron_right,
            color: navy,
            size: 20,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESTIMATED RANGE · SEP',
                  style: TextStyle(
                    color: muted,
                    fontSize: 7,
                  ),
                ),

                const SizedBox(height: 7),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        estimatedRange,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(width: 4),

                      Text(
                        metricUnit,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // EXPLANATION

  Widget _buildExplanation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF4FF),
        borderRadius: BorderRadius.circular(12),
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
                'ABOUT THIS ESTIMATE',
                style: TextStyle(
                  color: blue,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            'What the trend suggests',
            style: TextStyle(
              color: navy,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            isGlucose
                ? 'Your available measurements show a mostly stable illustrative pattern. The shaded area represents uncertainty — the actual value could be higher or lower. Regular measurements improve this estimate.'
                : 'Your available blood pressure readings show an illustrative historical pattern. Repeated measurements taken correctly over time are needed to understand changes.',
            style: const TextStyle(
              color: muted,
              fontSize: 10,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  // DISCLAIMER

  Widget _buildEstimateDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFAD7100),
            size: 20,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Future trends are estimates',
                  style: TextStyle(
                    color: Color(0xFF865600),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'They are based on available historical measurements and are not guaranteed outcomes or a diagnosis.',
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

  // UNAVAILABLE TREND

  Widget _buildUnavailableCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFD7E1EC),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.show_chart,
            color: muted,
            size: 21,
          ),

          SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cholesterol trend unavailable',
                  style: TextStyle(
                    color: navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'More measurements are needed to generate a reliable trend.',
                  style: TextStyle(
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: const Color(0xFFE2EAF3),
      ),
    );
  }
}

// TREND CHART PAINTER

class _TrendPainter extends CustomPainter {
  final bool isGlucose;

  _TrendPainter({
    required this.isGlucose,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const left = 27.0;
    const right = 5.0;
    const top = 15.0;
    const bottom = 25.0;

    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    final values = isGlucose
        ? [88.0, 108.0, 102.0, 117.0, 150.0]
        : [85.0, 110.0, 105.0, 120.0, 145.0];

    final minValue = isGlucose ? 80.0 : 80.0;
    final maxValue = 160.0;

    double yFor(double value) {
      return top +
          chartHeight *
              (maxValue - value) /
              (maxValue - minValue);
    }

    final gridPaint = Paint()
      ..color = const Color(0xFFE8EEF5)
      ..strokeWidth = 1;

    final labelPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 3; i++) {
      final y = top + chartHeight * i / 2;

      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );

      final value = 160 - i * 40;

      labelPainter.text = TextSpan(
        text: '$value',
        style: const TextStyle(
          color: Color(0xFF71829B),
          fontSize: 7,
        ),
      );

      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(0, y - 4),
      );
    }

    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      points.add(
        Offset(
          left + chartWidth * i / 5,
          yFor(values[i]),
        ),
      );
    }

    final forecastX = left + chartWidth * 4.35;

    final recordedPath = Path()
      ..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      recordedPath.lineTo(
        points[i].dx,
        points[i].dy,
      );
    }

    // Recorded area.
    final areaPath = Path.from(recordedPath)
      ..lineTo(points.last.dx, top + chartHeight)
      ..lineTo(points.first.dx, top + chartHeight)
      ..close();

    final areaPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x332864ED),
          Color(0x002864ED),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
        Rect.fromLTWH(
          left,
          top,
          chartWidth,
          chartHeight,
        ),
      );

    canvas.drawPath(areaPath, areaPaint);

    // Forecast uncertainty region.
    final forecastArea = Rect.fromLTRB(
      points.last.dx,
      top,
      size.width - right,
      top + chartHeight,
    );

    canvas.drawRect(
      forecastArea,
      Paint()..color = const Color(0x0D2864ED),
    );

    // Recorded line.
    canvas.drawPath(
      recordedPath,
      Paint()
        ..color = const Color(0xFF2864ED)
        ..strokeWidth = 2.3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Recorded points.
    for (final point in points) {
      canvas.drawCircle(
        point,
        4,
        Paint()..color = const Color(0xFF2864ED),
      );

      canvas.drawCircle(
        point,
        2,
        Paint()..color = Colors.white,
      );
    }

    // Forecast dashed line.
    final forecastPath = Path()
      ..moveTo(
        points.last.dx,
        points.last.dy,
      )
      ..quadraticBezierTo(
        points.last.dx + chartWidth * 0.20,
        yFor(120),
        forecastX,
        yFor(128),
      );

    final dashPaint = Paint()
      ..color = const Color(0xFF8A9AB3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    _drawDashedPath(
      canvas,
      forecastPath,
      dashPaint,
    );

    const months = ['Jan', 'Mar', 'May', 'Forecast'];

    final positions = [
      left,
      left + chartWidth * 0.4,
      left + chartWidth * 0.8,
      size.width - 48,
    ];

    for (int i = 0; i < months.length; i++) {
      labelPainter.text = TextSpan(
        text: months[i],
        style: const TextStyle(
          color: Color(0xFF71829B),
          fontSize: 8,
        ),
      );

      labelPainter.layout();

      labelPainter.paint(
        canvas,
        Offset(
          positions[i],
          size.height - 15,
        ),
      );
    }
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
  ) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;

      while (distance < metric.length) {
        final end = (distance + 5).clamp(
          0.0,
          metric.length,
        );

        canvas.drawPath(
          metric.extractPath(distance, end),
          paint,
        );

        distance += 8;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) {
    return oldDelegate.isGlucose != isGlucose;
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8A9AB3)
      ..strokeWidth = 1.5;

    double x = 0;

    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 1),
        Offset((x + 3).clamp(0.0, size.width), 1),
        paint,
      );

      x += 5;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
