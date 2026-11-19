import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../referrals/data/referral_mock_data.dart';

class RiskMonitoringScreen extends StatefulWidget {
  const RiskMonitoringScreen({super.key});

  @override
  State<RiskMonitoringScreen> createState() => _RiskMonitoringScreenState();
}

class _RiskMonitoringScreenState extends State<RiskMonitoringScreen> {
  int selectedTab = 0;

  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color page = Color(0xFFF4F7FC);

  bool get isDiabetes => selectedTab == 0;

  int get highCount => isDiabetes ? 1284 : 812;
  int get mediumCount => isDiabetes ? 5198 : 3294;
  int get lowCount => isDiabetes ? 26358 : 28734;
  int get flaggedCount => highCount + mediumCount;
  String get diseaseTitle =>
      isDiabetes ? 'Diabetes risk distribution' : 'Cardiovascular risk distribution';
  String get trendTitle =>
      isDiabetes ? 'Diabetes risk trend' : 'Cardiovascular risk trend';

  List<Map<String, dynamic>> get highRiskPeople {
    return ReferralMockData.referrals.where((person) {
      final risk = isDiabetes
          ? (person['diabetesRisk'] ?? 'Low')
          : (person['cardiovascularRisk'] ?? 'Low');
      return risk.toString().toLowerCase() == 'high';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: page,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
                children: [
                  const Text(
                    'AI-ASSISTED POPULATION TRIAGE',
                    style: TextStyle(
                      color: blue,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Risk monitoring',
                    style: TextStyle(
                      color: navy,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Screening indicators to support prioritisation and preventive care.',
                    style: TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _clinicalNotice(),
                  const SizedBox(height: 22),
                  _diseaseSelector(),
                  const SizedBox(height: 30),
                  _distributionCard(),
                  const SizedBox(height: 30),
                  _trendSection(),
                  const SizedBox(height: 30),
                  _priorityQueue(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: navy),
          ),
          const Spacer(),
          const Text(
            'Risk monitoring',
            style: TextStyle(
              color: navy,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: navy),
          ),
        ],
      ),
    );
  }

  Widget _clinicalNotice() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: navy, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clinical decision support',
                  style: TextStyle(
                    color: navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Risk classifications are not diagnoses. All high-risk results require qualified clinical review.',
                  style: TextStyle(
                    color: Color(0xFF526B89),
                    fontSize: 9,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _diseaseSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2F8),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          _tabButton('Diabetes', 0),
          _tabButton('Cardiovascular', 1),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final selected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? navy : const Color(0xFF718096),
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _distributionCard() {
    final total = highCount + mediumCount + lowCount;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_format(total)} ASSESSMENTS',
                style: const TextStyle(
                  color: blue,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const Text(
                'Last 30 days',
                style: TextStyle(
                  color: blue,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            diseaseTitle,
            style: const TextStyle(
              color: navy,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              SizedBox(
                height: 112,
                width: 112,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(112, 112),
                      painter: _DonutPainter(
                        high: highCount.toDouble(),
                        medium: mediumCount.toDouble(),
                        low: lowCount.toDouble(),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _format(flaggedCount),
                          style: const TextStyle(
                            color: navy,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'flagged',
                          style: TextStyle(
                            color: Color(0xFF718096),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    _legendRow('High', highCount, total, const Color(0xFFDC2626)),
                    const SizedBox(height: 12),
                    _legendRow('Medium', mediumCount, total, const Color(0xFFF59E0B)),
                    const SizedBox(height: 12),
                    _legendRow('Low', lowCount, total, const Color(0xFF16A34A)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendRow(String label, int value, int total, Color color) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 9, color: navy),
          ),
        ),
        Text(
          _format(value),
          style: const TextStyle(
            fontSize: 9,
            color: navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 34,
          child: Text(
            '${(value / total * 100).toStringAsFixed(1)}%',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 8, color: Color(0xFF718096)),
          ),
        ),
      ],
    );
  }

  Widget _trendSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '6-MONTH VIEW',
          style: TextStyle(
            color: blue,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isDiabetes ? 'Risk trend' : 'Cardiovascular risk trend',
          style: const TextStyle(
            color: navy,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 175,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          decoration: _cardDecoration(),
          child: CustomPaint(
            painter: _TrendPainter(
              values: isDiabetes
                  ? const [88, 110, 104, 119, 146]
                  : const [72, 83, 79, 96, 112],
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }

  Widget _priorityQueue() {
    final people = highRiskPeople;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PRIORITY QUEUE',
              style: TextStyle(
                color: blue,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            GestureDetector(
              onTap: () => context.pushNamed(
                'high-risk-individuals',
                queryParameters: {'type': isDiabetes ? 'diabetes' : 'cardiovascular'},
              ),
              child: Text(
                'View all ${isDiabetes ? '1,284' : '812'}',
                style: const TextStyle(
                  color: blue,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'High-risk individuals',
          style: TextStyle(
            color: navy,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        if (people.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: const Text(
              'No high-risk mock records are currently available.',
              style: TextStyle(fontSize: 10, color: Color(0xFF718096)),
            ),
          )
        else
          ...people.map(_personTile),
      ],
    );
  }

  Widget _personTile(Map<String, dynamic> person) {
    final id = person['id'].toString();
    final riskType = isDiabetes ? 'Diabetes' : 'Cardiovascular';
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.pushNamed(
            'individual-risk',
            pathParameters: {'id': id},
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5EBF3)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE0ECFA),
                  child: Text(
                    person['initials'] ?? '',
                    style: const TextStyle(
                      color: navy,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person['name'] ?? '',
                        style: const TextStyle(
                          color: navy,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${person['individualId']} · ${person['age']} years · ${person['area']}',
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 8,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$riskType risk',
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: navy, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFE5EBF3)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  String _format(int value) => value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]},',
      );
}

class _DonutPainter extends CustomPainter {
  final double high;
  final double medium;
  final double low;

  _DonutPainter({
    required this.high,
    required this.medium,
    required this.low,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = high + medium + low;
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.butt;
    var start = -1.5708;

    final segments = [
      (high, const Color(0xFFDC2626)),
      (medium, const Color(0xFFF59E0B)),
      (low, const Color(0xFF16A34A)),
    ];

    for (final segment in segments) {
      final sweep = segment.$1 / total * 6.283185307;
      paint.color = segment.$2;
      canvas.drawArc(
        rect.deflate(6),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.high != high ||
      oldDelegate.medium != medium ||
      oldDelegate.low != low;
}

class _TrendPainter extends CustomPainter {
  final List<double> values;

  _TrendPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    const left = 20.0;
    const right = 8.0;
    const top = 10.0;
    const bottom = 24.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;

    final grid = Paint()
      ..color = const Color(0xFFE8EEF6)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = top + chartHeight * i / 3;
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), grid);
    }

    final minValue = values.reduce((a, b) => a < b ? a : b) - 12;
    final maxValue = values.reduce((a, b) => a > b ? a : b) + 12;
    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = left + chartWidth * i / (values.length - 1);
      final y = top + chartHeight -
          ((values[i] - minValue) / (maxValue - minValue)) * chartHeight;
      points.add(Offset(x, y));
    }

    final line = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      line.lineTo(point.dx, point.dy);
    }

    final fill = Path.from(line)
      ..lineTo(points.last.dx, size.height - bottom)
      ..lineTo(points.first.dx, size.height - bottom)
      ..close();

    final fillPaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fill, fillPaint);
    canvas.drawPath(line, linePaint);

    final dot = Paint()..color = const Color(0xFF2563EB);
    final white = Paint()..color = Colors.white;
    for (final point in points) {
      canvas.drawCircle(point, 4, dot);
      canvas.drawCircle(point, 2, white);
    }

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
    const style = TextStyle(color: Color(0xFF718096), fontSize: 8);
    for (int i = 0; i < months.length; i++) {
      final painter = TextPainter(
        text: TextSpan(text: months[i], style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        Offset(points[i].dx - painter.width / 2, size.height - 13),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.values != values;
}
