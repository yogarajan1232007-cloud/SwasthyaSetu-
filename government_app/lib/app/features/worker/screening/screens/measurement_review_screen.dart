import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../data/measurement_data_store.dart';

class MeasurementReviewScreen extends StatelessWidget {
  final String householdId;
  final String individualId;

  const MeasurementReviewScreen({
    super.key,
    required this.householdId,
    required this.individualId,
  });

  static const Color navy = Color(0xFF172B4D);
  static const Color blue = Color(0xFF2563EB);
  static const Color muted = Color(0xFF64748B);
  static const Color background = Color(0xFFF4F7FC);
  static const Color border = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final record =
        MeasurementDataStore.getByIndividualId(individualId);

    final rawAdditionalTests = record?['additionalTests'];

    final Map<String, dynamic> additionalTests =
        rawAdditionalTests is Map
            ? Map<String, dynamic>.from(rawAdditionalTests)
            : {};

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Review Measurements',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        centerTitle: true,
      ),
      body: record == null
          ? _emptyState(context)
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  _buildHeader(),

                  const SizedBox(height: 22),

                  _sectionTitle('Basic Measurements'),

                  _measurementCard(
                    'Height',
                    _value(record, 'height', ' cm'),
                    Icons.height,
                  ),

                  _measurementCard(
                    'Weight',
                    _value(record, 'weight', ' kg'),
                    Icons.monitor_weight_outlined,
                  ),

                  _measurementCard(
                    'Body Mass Index (BMI)',
                    _value(record, 'bmi', ' kg/m²'),
                    Icons.monitor_heart_outlined,
                  ),

                  _measurementCard(
                    'Waist Circumference',
                    _value(record, 'waist', ' cm'),
                    Icons.straighten,
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle('Vital Signs'),

                  _measurementCard(
                    'Blood Pressure',
                    _bloodPressure(record),
                    Icons.favorite_outline,
                  ),

                  _measurementCard(
                    'Pulse Rate',
                    _value(record, 'pulse', ' bpm'),
                    Icons.monitor_heart,
                  ),

                  _measurementCard(
                    'SpO₂',
                    _valueFromMap(
                      additionalTests,
                      'spo2',
                      '%',
                    ),
                    Icons.air,
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle('Diabetes Screening'),

                  _measurementCard(
                    'Blood Glucose',
                    _value(record, 'glucose', ' mg/dL'),
                    Icons.bloodtype_outlined,
                  ),

                  _measurementCard(
                    'Glucose Test Context',
                    _value(record, 'glucoseContext', ''),
                    Icons.schedule,
                  ),

                  _measurementCard(
                    'HbA1c',
                    _valueFromMap(
                      additionalTests,
                      'hba1c',
                      '%',
                    ),
                    Icons.science_outlined,
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle('Cardiovascular Screening'),

                  _measurementCard(
                    'Total Cholesterol',
                    _valueFromMap(
                      additionalTests,
                      'totalCholesterol',
                      ' mg/dL',
                    ),
                    Icons.biotech_outlined,
                  ),

                  _measurementCard(
                    'HDL Cholesterol',
                    _valueFromMap(
                      additionalTests,
                      'hdl',
                      ' mg/dL',
                    ),
                    Icons.biotech_outlined,
                  ),

                  _measurementCard(
                    'LDL Cholesterol',
                    _valueFromMap(
                      additionalTests,
                      'ldl',
                      ' mg/dL',
                    ),
                    Icons.biotech_outlined,
                  ),

                  _measurementCard(
                    'Triglycerides',
                    _valueFromMap(
                      additionalTests,
                      'triglycerides',
                      ' mg/dL',
                    ),
                    Icons.biotech_outlined,
                  ),

                  _measurementCard(
                    'ECG Result / Reference',
                    _valueFromMap(
                      additionalTests,
                      'ecg',
                      '',
                    ),
                    Icons.monitor_heart_outlined,
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle('Measurement Device'),

                  _measurementCard(
                    'Device Name / Model',
                    _value(record, 'device', ''),
                    Icons.devices_outlined,
                  ),

                  const SizedBox(height: 20),

                  _buildRecordingInformation(record),

                  const SizedBox(height: 20),

                  _buildInformationBanner(),

                  const SizedBox(height: 25),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                       context.push(
                       '/worker-screening-summary/'
                       '$householdId/$individualId',
                       );
                      },
                      icon: const Icon(
                        Icons.check_circle_outline,
                      ),
                      label: const Text(
                        'Confirm Measurements',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15803D),
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
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.pop(false);
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text(
                        'Go Back and Edit',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: blue,
                        side: const BorderSide(color: blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Demo interface only. Recorded values must be '
                    'checked by an authorised healthcare professional. '
                    'This screen does not provide a medical diagnosis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      color: muted,
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
    );
  }

  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD6E5FF),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.fact_check_outlined,
            color: blue,
            size: 32,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Review Before Confirmation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Verify all recorded measurements before '
                  'completing the screening process.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // EMPTY STATE
  // =====================================================

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.folder_off_outlined,
              size: 55,
              color: muted,
            ),
            const SizedBox(height: 15),
            const Text(
              'No Measurements Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please return and save the measurements first.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: muted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // SECTION TITLE
  // =====================================================

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

  // =====================================================
  // MEASUREMENT CARD
  // =====================================================

  Widget _measurementCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: blue,
              size: 21,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // RECORDING INFORMATION
  // =====================================================

  Widget _buildRecordingInformation(
    Map<String, dynamic> record,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: blue,
                size: 20,
              ),
              SizedBox(width: 9),
              Text(
                'Recording Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          _informationRow(
            'Household ID',
            householdId,
          ),

          _informationRow(
            'Individual ID',
            individualId,
          ),

          _informationRow(
            'Measurement Status',
            record['measurementStatus']?.toString() ?? 'Not available',
          ),

          _informationRow(
            'Recorded At',
            record['recordedAt']?.toString() ?? 'Not available',
          ),
        ],
      ),
    );
  }

  Widget _informationRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: muted,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: navy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // INFORMATION BANNER
  // =====================================================

  Widget _buildInformationBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFE2A8),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFB7791F),
            size: 22,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Please verify the entered values and ensure that '
              'measurements were collected using appropriate devices '
              'and approved screening procedures. Missing optional '
              'tests are displayed as Not recorded.',
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: Color(0xFF805B18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // VALUE HELPERS
  // =====================================================

  static String _value(
    Map<String, dynamic> record,
    String key,
    String unit,
  ) {
    final value = record[key];

    if (value == null || value.toString().trim().isEmpty) {
      return 'Not recorded';
    }

    return '$value$unit';
  }

  static String _valueFromMap(
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
    Map<String, dynamic> record,
  ) {
    final systolic = record['systolic'];
    final diastolic = record['diastolic'];

    if (systolic == null || diastolic == null) {
      return 'Not recorded';
    }

    return '$systolic / $diastolic mmHg';
  }
}