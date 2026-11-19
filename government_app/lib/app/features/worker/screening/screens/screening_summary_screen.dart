import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../data/measurement_data_store.dart';
import '../data/medical_history_data_store.dart';

class ScreeningSummaryScreen extends StatelessWidget {
  final String householdId;
  final String individualId;

  const ScreeningSummaryScreen({
    super.key,
    required this.householdId,
    required this.individualId,
  });

  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color teal = Color(0xFF0D9B8E);
  static const Color muted = Color(0xFF8292A8);
  static const Color background = Color(0xFFF4F7FC);

  @override
  Widget build(BuildContext context) {
    final measurements =
        MeasurementDataStore.getByIndividualId(individualId);

    final history =
        MedicalHistoryDataStore.getByIndividualId(individualId);

    final additionalTests =
        measurements?['additionalTests'] is Map
            ? Map<String, dynamic>.from(
                measurements!['additionalTests'] as Map,
              )
            : <String, dynamic>{};

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Screening Summary',
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
      body: measurements == null
          ? const Center(
              child: Text('Measurement records not found.'),
            )
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _buildSuccessBanner(),

                  const SizedBox(height: 22),

                  _sectionTitle('Individual Information'),

                  _infoCard(
                    Icons.home_outlined,
                    'Household ID',
                    householdId,
                  ),

                  _infoCard(
                    Icons.person_outline,
                    'Individual ID',
                    individualId,
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle('Medical History'),

                  _historyCard(history),

                  const SizedBox(height: 20),

                  _sectionTitle('Basic Measurements'),

                  _infoCard(
                    Icons.height,
                    'Height',
                    _value(measurements, 'height', ' cm'),
                  ),

                  _infoCard(
                    Icons.monitor_weight_outlined,
                    'Weight',
                    _value(measurements, 'weight', ' kg'),
                  ),

                  _infoCard(
                    Icons.monitor_heart_outlined,
                    'BMI',
                    _value(measurements, 'bmi', ' kg/m²'),
                  ),

                  _infoCard(
                    Icons.straighten,
                    'Waist Circumference',
                    _value(measurements, 'waist', ' cm'),
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle('Vital Signs'),

                  _infoCard(
                    Icons.favorite_outline,
                    'Blood Pressure',
                    _bloodPressure(measurements),
                  ),

                  _infoCard(
                    Icons.monitor_heart,
                    'Pulse Rate',
                    _value(measurements, 'pulse', ' bpm'),
                  ),

                  _infoCard(
                    Icons.bloodtype_outlined,
                    'Blood Glucose',
                    _value(measurements, 'glucose', ' mg/dL'),
                  ),

                  _infoCard(
                    Icons.schedule,
                    'Glucose Context',
                    _value(measurements, 'glucoseContext', ''),
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle('Additional Test Results'),

                  _infoCard(
                    Icons.science_outlined,
                    'HbA1c',
                    _mapValue(additionalTests, 'hba1c', '%'),
                  ),

                  _infoCard(
                    Icons.biotech_outlined,
                    'Total Cholesterol',
                    _mapValue(
                      additionalTests,
                      'totalCholesterol',
                      ' mg/dL',
                    ),
                  ),

                  _infoCard(
                    Icons.biotech_outlined,
                    'HDL',
                    _mapValue(additionalTests, 'hdl', ' mg/dL'),
                  ),

                  _infoCard(
                    Icons.biotech_outlined,
                    'LDL',
                    _mapValue(additionalTests, 'ldl', ' mg/dL'),
                  ),

                  _infoCard(
                    Icons.biotech_outlined,
                    'Triglycerides',
                    _mapValue(
                      additionalTests,
                      'triglycerides',
                      ' mg/dL',
                    ),
                  ),

                  _infoCard(
                    Icons.air,
                    'SpO₂',
                    _mapValue(additionalTests, 'spo2', '%'),
                  ),

                  _infoCard(
                    Icons.monitor_heart_outlined,
                    'ECG',
                    _mapValue(additionalTests, 'ecg', ''),
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle('Screening Status'),

                  _buildStatusCard(),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push(
                          '/worker-screening-result/'
                          '$householdId/$individualId',
                        );
                      },
                      icon: const Icon(Icons.analytics_outlined),
                      label: const Text(
                        'View Screening Result',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
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
                      child: const Text('Back to Review'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'This is a demonstration summary using mock data. '
                    'It is not a medical diagnosis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F6F2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: teal,
            size: 34,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Screening Data Collected',
                  style: TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Review the collected information before viewing '
                  'the demonstration result.',
                  style: TextStyle(
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: navy,
        ),
      ),
    );
  }

  Widget _infoCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
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
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic>? history) {
    if (history == null || history.isEmpty) {
      return _infoCard(
        Icons.history,
        'Medical History',
        'Not available',
      );
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: history.entries.map((entry) {
          final value = entry.value;

          if (value == null || value is Map || value is List) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _formatLabel(entry.key),
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    value.toString(),
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
        }).toList(),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: teal,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Measurement data saved',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: navy,
                  ),
                ),
              ),
              Text(
                'Completed',
                style: TextStyle(
                  color: teal,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          SizedBox(height: 13),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: blue,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Clinical review and validated AI assessment '
                  'are not yet implemented.',
                  style: TextStyle(
                    fontSize: 11,
                    color: muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _value(
    Map<String, dynamic> data,
    String key,
    String unit,
  ) {
    final value = data[key];

    if (value == null || value.toString().trim().isEmpty) {
      return 'Not recorded';
    }

    return '$value$unit';
  }

  static String _mapValue(
    Map<String, dynamic> data,
    String key,
    String unit,
  ) {
    final value = data[key];

    if (value == null || value.toString().trim().isEmpty) {
      return 'Not recorded';
    }

    return '$value$unit';
  }

  static String _bloodPressure(
    Map<String, dynamic> data,
  ) {
    final systolic = data['systolic'];
    final diastolic = data['diastolic'];

    if (systolic == null || diastolic == null) {
      return 'Not recorded';
    }

    return '$systolic / $diastolic mmHg';
  }

  static String _formatLabel(String key) {
    final spaced = key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );

    return spaced
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}