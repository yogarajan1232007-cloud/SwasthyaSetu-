import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class ScheduleConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> referral;

  const ScheduleConfirmationScreen({
    super.key,
    required this.referral,
  });

  @override
  State<ScheduleConfirmationScreen> createState() =>
      _ScheduleConfirmationScreenState();
}

class _ScheduleConfirmationScreenState
    extends State<ScheduleConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController hospitalController;
  late TextEditingController doctorController;
  late TextEditingController remarksController;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();

    hospitalController = TextEditingController(
      text: widget.referral['hospital'] ?? '',
    );

    doctorController = TextEditingController(
      text: widget.referral['doctor'] ?? '',
    );

    remarksController = TextEditingController();
  }

  @override
  void dispose() {
    hospitalController.dispose();
    doctorController.dispose();
    remarksController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  void _confirmAppointment() {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select appointment date and time'),
        ),
      );
      return;
    }

    final referral = widget.referral;

    referral['hospital'] = hospitalController.text;
    referral['doctor'] = doctorController.text;
    referral['appointmentDate'] =
        '${selectedDate!.day} ${_monthName(selectedDate!.month)} ${selectedDate!.year}';
    referral['appointmentTime'] = selectedTime!.format(context);
    referral['remarks'] = remarksController.text;
    referral['status'] = 'Scheduled';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Appointment scheduled successfully'),
        backgroundColor: Colors.green,
      ),
    );

    context.pop();
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint ?? label,
            filled: true,
            fillColor: const Color(0xFFF5F7FB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final referral = widget.referral;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text('Schedule consultation'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF16365C),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PATIENT INFORMATION',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    referral['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text('ID: ${referral['individualId']}'),
                  Text('Risk: ${referral['riskLevel']}'),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'APPOINTMENT DETAILS',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 14),

            _inputField(
              'Hospital / Referral Facility',
              hospitalController,
            ),

            _inputField(
              'Doctor / Department',
              doctorController,
            ),

            const Text(
              'Appointment date',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                selectedDate == null
                    ? 'Select appointment date'
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Appointment time',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: _selectTime,
              icon: const Icon(Icons.access_time),
              label: Text(
                selectedTime == null
                    ? 'Select appointment time'
                    : selectedTime!.format(context),
              ),
            ),

            const SizedBox(height: 18),

            _inputField(
              'Additional remarks',
              remarksController,
              hint: 'Enter additional information',
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _confirmAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirm appointment',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}