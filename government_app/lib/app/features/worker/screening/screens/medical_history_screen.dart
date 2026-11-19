import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import '../data/medical_history_data_store.dart';

class MedicalHistoryScreen extends StatefulWidget {
  final String householdId;
  final String individualId;

  const MedicalHistoryScreen({
    super.key,
    required this.householdId,
    required this.individualId,
  });

  @override
  State<MedicalHistoryScreen> createState() =>
      _MedicalHistoryScreenState();
}

class _MedicalHistoryScreenState extends State<MedicalHistoryScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color muted = Color(0xFF8292A8);
  static const Color background = Color(0xFFF4F7FC);

  final Map<String, String> answers = {
    'existingDiabetes': 'Unknown',
    'cardiovascularCondition': 'Unknown',
    'previousHypertension': 'Unknown',
    'familyHistoryDiabetes': 'Unknown',
    'currentMedication': 'Unknown',
    'smokingStatus': 'Unknown',
    'physicalActivity': 'Unknown',
    'dietaryHabits': 'Unknown',
    'relevantSymptoms': 'Unknown',
  };

  final Map<String, TextEditingController> details = {
    'existingDiabetes': TextEditingController(),
    'cardiovascularCondition': TextEditingController(),
    'previousHypertension': TextEditingController(),
    'familyHistoryDiabetes': TextEditingController(),
    'currentMedication': TextEditingController(),
    'smokingStatus': TextEditingController(),
    'physicalActivity': TextEditingController(),
    'dietaryHabits': TextEditingController(),
    'relevantSymptoms': TextEditingController(),
  };

  final Map<String, String> labels = {
    'existingDiabetes': 'Existing diabetes',
    'cardiovascularCondition': 'Cardiovascular condition',
    'previousHypertension': 'Previous hypertension',
    'familyHistoryDiabetes': 'Family history of diabetes',
    'currentMedication': 'Current medication',
    'smokingStatus': 'Smoking status',
    'physicalActivity': 'Physical activity',
    'dietaryHabits': 'Dietary habits',
    'relevantSymptoms': 'Relevant symptoms',
  };

  @override
  void initState() {
    super.initState();
    _loadExistingHistory();
  }

  void _loadExistingHistory() {
    final saved = MedicalHistoryDataStore.getByIndividualId(
      widget.individualId,
    );

    if (saved == null) return;

    for (final key in answers.keys) {
      answers[key] = saved[key]?.toString() ?? 'Unknown';
      details[key]!.text = saved['${key}Details']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    for (final controller in details.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveHistory() {
  final data = <String, dynamic>{};

  for (final key in answers.keys) {
    data[key] = answers[key];
    data['${key}Details'] = details[key]!.text.trim();
  }

  MedicalHistoryDataStore.save(
    individualId: widget.individualId,
    data: data,
  );

  context.push(
  '/worker-measurements/'
  '${widget.householdId}/'
  '${widget.individualId}',
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
          'Medical History',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
        children: [
          Text(
            'SCREENING · ${widget.individualId}',
            style: const TextStyle(
              color: blue,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Medical history',
            style: TextStyle(
              color: navy,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Choose Unknown when information is not available. '
            'Ask the individual before recording responses.',
            style: TextStyle(
              color: muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          ...answers.keys.map(_buildHistoryCard),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: blue,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Record the information reported by the individual. '
                    'Do not infer a medical condition from symptoms. '
                    'This history supports clinical screening and '
                    'risk assessment.',
                    style: TextStyle(
                      color: navy,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _saveHistory,
              icon: const Icon(Icons.save_outlined),
              label: const Text(
                'Save medical history',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(String key) {
    final answer = answers[key]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE5EAF2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labels[key]!,
            style: const TextStyle(
              color: navy,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 13),

          DropdownButtonFormField<String>(
            initialValue: answer,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF2F5F9),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Yes',
                child: Text('Yes'),
              ),
              DropdownMenuItem(
                value: 'No',
                child: Text('No'),
              ),
              DropdownMenuItem(
                value: 'Unknown',
                child: Text('Unknown'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                answers[key] = value;

                if (value != 'Yes') {
                  details[key]!.clear();
                }
              });
            },
          ),

          if (answer == 'Yes') ...[
            const SizedBox(height: 12),

            TextField(
              controller: details[key],
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Enter additional details',
                hintStyle: const TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5EAF2),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}