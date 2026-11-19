import 'package:material_ui/material_ui.dart';

class HealthReportScreen extends StatelessWidget {
  const HealthReportScreen({super.key});

  static const Color navy = Color(0xFF15385B);
  static const Color blue = Color(0xFF2864ED);
  static const Color muted = Color(0xFF71829B);
  static const Color background = Color(0xFFF3F7FC);
  static const Color teal = Color(0xFF009D91);

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
                  _measurementCard(
                    icon: Icons.favorite_outline,
                    title: 'Blood pressure',
                    value: '128/82',
                    unit: 'mmHg',
                    previous: '124/80 previously',
                    status: 'Within screening range',
                    iconColor: const Color(0xFFFF5267),
                    iconBackground: const Color(0xFFFFEDEF),
                  ),

                  const SizedBox(height: 12),

                  _measurementCard(
                    icon: Icons.water_drop_outlined,
                    title: 'Blood glucose',
                    value: '132',
                    unit: 'mg/dL',
                    previous: '118 previously',
                    status: 'Random measurement',
                    iconColor: const Color(0xFF8057E8),
                    iconBackground: const Color(0xFFF1EBFF),
                  ),

                  const SizedBox(height: 12),

                  _measurementCard(
                    icon: Icons.person_outline,
                    title: 'Body mass index',
                    value: '25.7',
                    unit: 'kg/m²',
                    previous: '25.2 previously',
                    status: 'Monitor over time',
                    iconColor: const Color(0xFFFF5267),
                    iconBackground: const Color(0xFFFFEDEF),
                  ),

                  const SizedBox(height: 12),

                  _measurementCard(
                    icon: Icons.favorite_border,
                    title: 'Pulse',
                    value: '76',
                    unit: 'bpm',
                    previous: '74 previously',
                    status: 'Recorded',
                    iconColor: const Color(0xFFFF5267),
                    iconBackground: const Color(0xFFFFEDEF),
                  ),

                  const SizedBox(height: 24),

                  _buildHistoryCard(),

                  const SizedBox(height: 24),

                  _buildHelpCard(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LATEST SCREENING · 18 JUN 2025',
            style: TextStyle(
              color: blue,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          SizedBox(height: 11),

          Text(
            'My health report',
            style: TextStyle(
              color: navy,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 7),

          Text(
            'Only measurements recorded during your visit are shown.',
            style: TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _measurementCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required String previous,
    required String status,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 37,
                width: 37,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 21,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 8,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text(
                            unit,
                            style: const TextStyle(
                              color: muted,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      previous,
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

          const SizedBox(height: 11),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7F4),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: teal,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
                      '6-MONTH HISTORY',
                      style: TextStyle(
                        color: blue,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),

                    SizedBox(height: 9),

                    Text(
                      'Blood pressure',
                      style: TextStyle(
                        color: navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              TextButton(
                onPressed: () {},
                child: const Text(
                  'View details',
                  style: TextStyle(
                    color: blue,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 155,
            child: CustomPaint(
              painter: _BloodPressurePainter(),
              child: const SizedBox.expand(),
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Illustrative historical readings for frontend demonstration.',
            style: TextStyle(
              color: muted,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
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
                  'Need help understanding a result?',
                  style: TextStyle(
                    color: navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Speak to your health worker or a qualified healthcare professional. Do not change treatment based on this report alone.',
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
}

class _BloodPressurePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const left = 28.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 27.0;

    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    final gridPaint = Paint()
      ..color = const Color(0xFFE7EDF5)
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final labels = ['160', '120', '80'];

    for (int i = 0; i < 3; i++) {
      final y = top + (chartHeight * i / 2);

      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Color(0xFF71829B),
          fontSize: 7,
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(0, y - 5),
      );
    }

    final values = [88.0, 112.0, 108.0, 119.0, 148.0];

    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = left + chartWidth * i / 4;
      final y = top +
          chartHeight *
              (160 - values[i]) /
              80;

      points.add(Offset(x, y));
    }

    final path = Path()
      ..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final area = Path.from(path)
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

    canvas.drawPath(area, areaPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF2864ED)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    for (final point in points) {
      canvas.drawCircle(
        point,
        4,
        Paint()..color = const Color(0xFF2864ED),
      );

      canvas.drawCircle(
        point,
        2.2,
        Paint()..color = Colors.white,
      );
    }

    const months = ['Jan', 'Mar', 'May', 'Jul'];

    for (int i = 0; i < months.length; i++) {
      textPainter.text = TextSpan(
        text: months[i],
        style: const TextStyle(
          color: Color(0xFF71829B),
          fontSize: 8,
        ),
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          left + chartWidth * i / 3 - 5,
          size.height - 15,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
