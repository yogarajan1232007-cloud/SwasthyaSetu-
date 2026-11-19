
import 'package:material_ui/material_ui.dart';

import '../data/screening_service.dart';

class ScreeningDetailsScreen extends StatefulWidget {
  final String screeningId;

  const ScreeningDetailsScreen({
    super.key,
    required this.screeningId,
  });

  @override
  State<ScreeningDetailsScreen> createState() =>
      _ScreeningDetailsScreenState();
}

class _ScreeningDetailsScreenState
    extends State<ScreeningDetailsScreen> {
  final ScreeningService _service = ScreeningService();

  Map<String, dynamic>? _screening;
  Map<String, dynamic>? _individual;
  Map<String, dynamic>? _measurement;

  bool _loading = true;
  String? _error;

  static const navy = Color(0xFF15365B);
  static const blue = Color(0xFF2563EB);
  static const background = Color(0xFFF4F7FC);

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final id = int.parse(widget.screeningId);

      final screening = await _service.fetchScreeningDetails(id);

      final individualId =
          int.tryParse(screening['individual_id']?.toString() ?? '');

      if (individualId == null) {
        throw Exception('Individual ID is missing from screening.');
      }

      final results = await Future.wait([
        _service.fetchIndividual(individualId),
        _service.fetchMeasurements(id),
      ]);

      final individual =
          results[0] as Map<String, dynamic>;

      final measurements =
          results[1] as List<Map<String, dynamic>>;

      if (!mounted) return;

      setState(() {
        _screening = screening;
        _individual = individual;

        // The latest measurement is displayed first.
        _measurement =
            measurements.isNotEmpty ? measurements.first : null;

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  String _value(dynamic value, {String suffix = ''}) {
    if (value == null || value.toString().isEmpty) {
      return 'Not recorded';
    }

    return '$value$suffix';
  }

  String _status() {
    return (_screening?['status'] ?? 'Unknown')
        .toString()
        .replaceAll('_', ' ')
        .toUpperCase();
  }

  Color _statusColor() {
    switch (_status().toLowerCase()) {
      case 'completed':
        return const Color(0xFF15803D);
      case 'in progress':
        return blue;
      case 'pending':
        return const Color(0xFFB76A00);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return Colors.grey;
    }
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 20),
      child: Row(
        children: [
          Icon(icon, color: blue, size: 20),
          const SizedBox(width: 9),
          Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(List<Map<String, String>> items) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5EBF3)),
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item['label']!,
                    style: const TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    item['value']!,
                    textAlign: TextAlign.end,
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
        }).toList(),
      ),
    );
  }

  Widget _measurementGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.65,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFE5EBF3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item['label'],
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                item['value'],
                style: const TextStyle(
                  color: navy,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
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
        title: const Text(
          'Screening Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: _loadDetails,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final s = _screening!;
    final p = _individual!;
    final m = _measurement;

    final dob = p['date_of_birth']?.toString();

    final age = dob == null
        ? 'Not recorded'
        : _calculateAge(dob);

    return RefreshIndicator(
      onRefresh: _loadDetails,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // INDIVIDUAL PROFILE
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5EBF3)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFE0ECFA),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: navy,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['full_name']?.toString() ?? 'Unknown',
                        style: const TextStyle(
                          color: navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        p['individual_code']?.toString() ?? '',
                        style: const TextStyle(
                          color: blue,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$age · ${_value(p['gender'])}',
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // SCREENING INFORMATION
          _sectionTitle(
            'Screening Information',
            Icons.assignment_outlined,
          ),
          _infoCard([
            {
              'label': 'Screening ID',
              'value': _value(s['id']),
            },
            {
              'label': 'Screening Type',
              'value': _value(s['screening_type']),
            },
            {
              'label': 'Screening Date',
              'value': _value(s['screening_date']),
            },
            {
              'label': 'Worker ID',
              'value': _value(s['worker_id']),
            },
            {
              'label': 'Assignment ID',
              'value': _value(s['assignment_id']),
            },
            {
              'label': 'Status',
              'value': _status(),
            },
          ]),

          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: _statusColor().withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _status(),
                style: TextStyle(
                  color: _statusColor(),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          // PERSONAL INFORMATION
          _sectionTitle(
            'Personal Information',
            Icons.person_outline,
          ),
          _infoCard([
            {
              'label': 'Individual Code',
              'value': _value(p['individual_code']),
            },
            {
              'label': 'Date of Birth',
              'value': _value(p['date_of_birth']),
            },
            {
              'label': 'Gender',
              'value': _value(p['gender']),
            },
            {
              'label': 'Mobile Number',
              'value': _value(p['mobile_number']),
            },
            {
              'label': 'Blood Group',
              'value': _value(p['blood_group']),
            },
            {
              'label': 'Household ID',
              'value': _value(p['household_id']),
            },
          ]),

          // MEDICAL HISTORY
          _sectionTitle(
            'Medical History',
            Icons.medical_information_outlined,
          ),
          _infoCard([
            {
              'label': 'Medical History',
              'value': _value(s['medical_history']),
            },
            {
              'label': 'Screening Remarks',
              'value': _value(s['remarks']),
            },
          ]),

          // MEASUREMENTS
          _sectionTitle(
            'Medical Measurements',
            Icons.monitor_heart_outlined,
          ),

          if (m == null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'No measurements have been recorded for this screening.',
                style: TextStyle(color: navy),
              ),
            )
          else ...[
            _measurementGrid([
              {
                'label': 'Height',
                'value': _value(m['height_cm'], suffix: ' cm'),
              },
              {
                'label': 'Weight',
                'value': _value(m['weight_kg'], suffix: ' kg'),
              },
              {
                'label': 'BMI',
                'value': _value(m['bmi']),
              },
              {
                'label': 'Waist Circumference',
                'value': _value(m['waist_cm'], suffix: ' cm'),
              },
              {
                'label': 'Pulse Rate',
                'value': _value(m['pulse_rate'], suffix: ' bpm'),
              },
              {
                'label': 'Blood Pressure',
                'value':
                    '${_value(m['systolic_bp'])}/${_value(m['diastolic_bp'])} mmHg',
              },
              {
                'label': 'Fasting Glucose',
                'value': _value(m['fasting_glucose']),
              },
              {
                'label': 'Post-meal Glucose',
                'value': _value(m['post_meal_glucose']),
              },
              {
                'label': 'HbA1c',
                'value': _value(m['hba1c'], suffix: '%'),
              },
              {
                'label': 'Total Cholesterol',
                'value': _value(m['total_cholesterol']),
              },
              {
                'label': 'HDL',
                'value': _value(m['hdl']),
              },
              {
                'label': 'LDL',
                'value': _value(m['ldl']),
              },
              {
                'label': 'Triglycerides',
                'value': _value(m['triglycerides']),
              },
              {
                'label': 'SpO2',
                'value': _value(m['spo2'], suffix: '%'),
              },
            ]),

            const SizedBox(height: 15),
            _infoCard([
              {
                'label': 'Glucose Context',
                'value': _value(m['glucose_context']),
              },
              {
                'label': 'Measurement Notes',
                'value': _value(m['measurement_notes']),
              },
              {
                'label': 'Measured At',
                'value': _value(m['measured_at']),
              },
            ]),
          ],

          const SizedBox(height: 25),
          const Text(
            'Measurements are recorded screening data. They are not, by themselves, a medical diagnosis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF718096),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _calculateAge(String dob) {
    final birthDate = DateTime.tryParse(dob);

    if (birthDate == null) return 'Age unavailable';

    final today = DateTime.now();

    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month &&
            today.day < birthDate.day)) {
      age--;
    }

    return '$age years';
  }
}
