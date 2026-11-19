import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import '../data/measurement_data_store.dart';
import 'package:file_picker/file_picker.dart';


class MeasurementsScreen extends StatefulWidget {
  final String householdId;
  final String individualId;
  

  const MeasurementsScreen({
    super.key,
    required this.householdId,
    required this.individualId,
  });

  @override
  State<MeasurementsScreen> createState() =>
      _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color teal = Color(0xFF0D9B8E);
  static const Color muted = Color(0xFF8292A8);
  static const Color background = Color(0xFFF4F7FC);

  final _formKey = GlobalKey<FormState>();

  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final waistController = TextEditingController();
  final pulseController = TextEditingController();

  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();

  final glucoseController = TextEditingController();

  final deviceController = TextEditingController(
    text: 'Manual entry',
  );
  final hba1cController = TextEditingController();
final cholesterolController = TextEditingController();
final hdlController = TextEditingController();
final ldlController = TextEditingController();
final triglyceridesController = TextEditingController();
final spo2Controller = TextEditingController();
final ecgController = TextEditingController();

String reportCategory = 'Blood Test Report';
DateTime reportDate = DateTime.now();

final List<Map<String, dynamic>> uploadedReports = [];

  String glucoseContext = 'Random';
  bool isSaving = false;

  double? get bmi {
    final height = double.tryParse(heightController.text);
    final weight = double.tryParse(weightController.text);

    if (height == null ||
        weight == null ||
        height <= 0 ||
        weight <= 0) {
      return null;
    }

    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }
   Future<void> _pickMedicalReport() async {
  try {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (files.isEmpty) return;

    final file = files.single;
    final bytes = await file.readAsBytes();
    final size = await file.length() ?? bytes.length;

    setState(() {
      uploadedReports.add({
        'name': file.name,
        'extension': file.extension,
        'size': size,
        'bytes': bytes,
        'category': reportCategory,
        'reportDate': reportDate.toIso8601String(),
      });
    });
  } catch (e) {
    _showMessage('Unable to select report: $e');
  }
}
  @override
  void initState() {
    super.initState();
    _loadExistingMeasurements();
  }

  void _loadExistingMeasurements() {
    final saved = MeasurementDataStore.getByIndividualId(
      widget.individualId,
    );

    if (saved == null) return;

    heightController.text = saved['height']?.toString() ?? '';
    weightController.text = saved['weight']?.toString() ?? '';
    waistController.text = saved['waist']?.toString() ?? '';
    pulseController.text = saved['pulse']?.toString() ?? '';

    systolicController.text =
        saved['systolic']?.toString() ?? '';

    diastolicController.text =
        saved['diastolic']?.toString() ?? '';

    glucoseController.text =
        saved['glucose']?.toString() ?? '';

    deviceController.text =
        saved['device']?.toString() ?? 'Manual entry';

    glucoseContext =
        saved['glucoseContext']?.toString() ?? 'Random';
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    waistController.dispose();
    pulseController.dispose();
    systolicController.dispose();
    diastolicController.dispose();
    glucoseController.dispose();
    deviceController.dispose();
    hba1cController.dispose();
cholesterolController.dispose();
hdlController.dispose();
ldlController.dispose();
triglyceridesController.dispose();
spo2Controller.dispose();
ecgController.dispose();

    super.dispose();
  }

  String? _validateMeasurement(
    String? value, {
    required double min,
    required double max,
    required String field,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter $field';
    }

    final number = double.tryParse(value);

    if (number == null) {
      return 'Enter a valid number';
    }

    if (number < min || number > max) {
      return 'Enter a value between $min and $max';
    }

    return null;
  }

  Future<void> _saveMeasurements() async {
  if (!_formKey.currentState!.validate()) return;

  final systolic = double.parse(systolicController.text);
  final diastolic = double.parse(diastolicController.text);

  if (systolic <= diastolic) {
    _showMessage(
      'Please verify the blood pressure readings.',
    );
    return;
  }

  if (deviceController.text.trim().isEmpty) {
    _showMessage('Enter the measuring device information.');
    return;
  }

  setState(() => isSaving = true);

  try {
    // SAVE MAIN MEASUREMENTS
    MeasurementDataStore.save(
      individualId: widget.individualId,
      householdId: widget.householdId,
      measurements: {
        'height': double.parse(heightController.text),
        'weight': double.parse(weightController.text),
        'waist': double.parse(waistController.text),
        'pulse': int.parse(pulseController.text),
        'systolic': int.parse(systolicController.text),
        'diastolic': int.parse(diastolicController.text),
        'glucose': double.parse(glucoseController.text),
        'glucoseContext': glucoseContext,
        'bmi': bmi,
        'device': deviceController.text.trim(),
        'measurementStatus': 'Entered',

        // ADDITIONAL TESTS
        'additionalTests': {
          'hba1c': hba1cController.text.trim(),
          'totalCholesterol': cholesterolController.text.trim(),
          'hdl': hdlController.text.trim(),
          'ldl': ldlController.text.trim(),
          'triglycerides': triglyceridesController.text.trim(),
          'spo2': spo2Controller.text.trim(),
          'ecg': ecgController.text.trim(),
        },
      },
    );

    // SAVE MEDICAL DOCUMENT INFORMATION
    for (final report in uploadedReports) {
      MeasurementDataStore.addMedicalDocument(
        individualId: widget.individualId,
        householdId: widget.householdId,
        document: {
          'name': report['name'],
          'extension': report['extension'],
          'size': report['size'],
          'category': report['category'],
          'reportDate': report['reportDate'],
        },
      );
    }

    if (!mounted) return;

    // OPEN MEASUREMENT REVIEW SCREEN
    await context.push(
      '/worker-measurement-review/'
      '${widget.householdId}/'
      '${widget.individualId}',
    );
  } catch (e) {
    if (mounted) {
      _showMessage('Unable to save measurements: $e');
    }
  } finally {
    if (mounted) {
      setState(() => isSaving = false);
    }
  }
}
  
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
          'Measurements',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            _buildProtocolBanner(),

            const SizedBox(height: 25),

            _buildSectionTitle(
              step: 'STEP 1',
              title: 'Basic measurements',
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _measurementField(
                    label: 'Height',
                    unit: 'cm',
                    controller: heightController,
                    min: 30,
                    max: 250,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _measurementField(
                    label: 'Weight',
                    unit: 'kg',
                    controller: weightController,
                    min: 1,
                    max: 350,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _measurementField(
                    label: 'Waist circumference',
                    unit: 'cm',
                    controller: waistController,
                    min: 20,
                    max: 250,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _measurementField(
                    label: 'Pulse',
                    unit: 'bpm',
                    controller: pulseController,
                    min: 20,
                    max: 250,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            _buildBmiCard(),

            const SizedBox(height: 28),

            _buildSectionTitle(
              step: 'STEP 2',
              title: 'Blood pressure',
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _measurementField(
                    label: 'Systolic',
                    unit: 'mmHg',
                    controller: systolicController,
                    min: 40,
                    max: 300,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _measurementField(
                    label: 'Diastolic',
                    unit: 'mmHg',
                    controller: diastolicController,
                    min: 20,
                    max: 200,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            _buildSectionTitle(
              step: 'STEP 3',
              title: 'Diabetes screening',
            ),

            const SizedBox(height: 16),

            _measurementField(
              label: 'Blood glucose',
              unit: 'mg/dL',
              controller: glucoseController,
              min: 10,
              max: 1000,
            ),

            const SizedBox(height: 12),

            const Text(
              'Measurement context',
              style: TextStyle(
                color: navy,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 9),

            Wrap(
              spacing: 8,
              children: [
                _contextChip('Fasting'),
                _contextChip('Random'),
                _contextChip('Post-meal'),
              ],
            ),

            const SizedBox(height: 28),

            _buildSectionTitle(
              step: 'DEVICE DETAILS',
              title: 'Measurement source',
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: deviceController,
              decoration: _inputDecoration(
                label: 'Device name / model',
                hint: 'Enter approved device name',
                suffix: const Icon(
                  Icons.devices_outlined,
                  color: muted,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter device information';
                }
                return null;
              },
            ),

            const SizedBox(height: 12),

            _buildInformationCard(),

            const SizedBox(height: 28),
            _buildAdditionalTests(),

const SizedBox(height: 25),

_buildReportUploadSection(),

const SizedBox(height: 28),

            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : _saveMeasurements,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  isSaving
                      ? 'Saving...'
                      : 'Save & review measurements',
                  style: const TextStyle(
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
      ),
    );
  }

  Widget _buildProtocolBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F6F2),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.assignment_outlined,
            color: teal,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Approved screening protocol',
                  style: TextStyle(
                    color: navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Record measurements using approved devices '
                  'and follow the clinical protocol.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
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

  Widget _buildSectionTitle({
    required String step,
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step,
          style: const TextStyle(
            color: blue,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: navy,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _measurementField({
    required String label,
    required String unit,
    required TextEditingController controller,
    required double min,
    required double max,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: navy,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          onChanged: (_) {
            if (label == 'Height' || label == 'Weight') {
              setState(() {});
            }
          },
          decoration: _inputDecoration(
            suffix: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                unit,
                style: const TextStyle(
                  color: muted,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          validator: (value) => _validateMeasurement(
            value,
            min: min,
            max: max,
            field: label.toLowerCase(),
          ),
        ),
      ],
    );
  }

  Widget _buildBmiCard() {
    final value = bmi;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calculate_outlined,
            color: blue,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calculated BMI',
                  style: TextStyle(
                    color: navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value == null
                      ? 'Enter height and weight'
                      : '${value.toStringAsFixed(1)} kg/m²',
                  style: const TextStyle(
                    color: blue,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contextChip(String value) {
    final selected = glucoseContext == value;

    return ChoiceChip(
      label: Text(value),
      selected: selected,
      showCheckmark: false,
      selectedColor: navy,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : navy,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      onSelected: (_) {
        setState(() {
          glucoseContext = value;
        });
      },
    );
  }

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: blue,
            size: 20,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Record the actual device used. Device integration '
              'and automatic measurement verification will be '
              'implemented separately.',
              style: TextStyle(
                color: navy,
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildReportUploadSection() {
  final categories = [
    'Blood Test Report',
    'X-ray',
    'Ultrasound Scan',
    'ECG Report',
    'CT Scan',
    'MRI Scan',
    'Other Medical Report',
  ];

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFE5EAF2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MEDICAL DOCUMENTS',
          style: TextStyle(
            color: blue,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Reports & Diagnostic Images',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          initialValue: reportCategory,
          isExpanded: true,
          decoration: _inputDecoration(
            label: 'Report category',
          ),
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => reportCategory = value);
            }
          },
        ),

        const SizedBox(height: 14),

        OutlinedButton.icon(
          onPressed: _pickMedicalReport,
          icon: const Icon(Icons.cloud_upload_outlined),
          label: const Text('Upload Medical Report'),
          style: OutlinedButton.styleFrom(
            foregroundColor: blue,
            minimumSize: const Size(double.infinity, 48),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Supported formats: PDF, JPG, JPEG and PNG.',
          style: TextStyle(
            color: muted,
            fontSize: 10,
          ),
        ),

        const SizedBox(height: 15),

        if (uploadedReports.isNotEmpty) ...[
          const Text(
            'Selected documents',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),

          ...List.generate(uploadedReports.length, (index) {
            final report = uploadedReports[index];

            return Card(
              elevation: 0,
              color: const Color(0xFFF4F7FC),
              child: ListTile(
                leading: const Icon(
                  Icons.description_outlined,
                  color: blue,
                ),
                title: Text(
                  report['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${report['category']} · '
                  '${(report['size'] / 1024).toStringAsFixed(1)} KB',
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      uploadedReports.removeAt(index);
                    });
                  },
                ),
              ),
            );
          }),
        ],
      ],
    ),
  );
}
Widget _buildAdditionalTests() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFE5EAF2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'STEP 4',
          style: TextStyle(
            color: blue,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Additional Tests',
          style: TextStyle(
            color: navy,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),

        _additionalField('HbA1c', '%', hba1cController),
        _additionalField(
          'Total Cholesterol', 'mg/dL', cholesterolController,
        ),
        _additionalField('HDL', 'mg/dL', hdlController),
        _additionalField('LDL', 'mg/dL', ldlController),
        _additionalField(
          'Triglycerides', 'mg/dL', triglyceridesController,
        ),
        _additionalField('SpO₂', '%', spo2Controller),
        _additionalField('ECG result/reference', '', ecgController),
      ],
    ),
  );
}

Widget _additionalField(
  String label,
  String unit,
  TextEditingController controller,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: label == 'ECG result/reference'
          ? TextInputType.text
          : const TextInputType.numberWithOptions(decimal: true),
      decoration: _inputDecoration(
        label: label,
        suffix: unit.isEmpty
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(unit),
              ),
      ),
    ),
  );
}

  InputDecoration _inputDecoration({
    String? label,
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFDCE5F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: Color(0xFFDCE5F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(
          color: blue,
          width: 1.5,
        ),
      ),
    );
  }
}
