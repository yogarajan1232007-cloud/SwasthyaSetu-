import 'package:material_ui/material_ui.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

class AddWorkerScreen extends StatefulWidget {
  const AddWorkerScreen({super.key});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerScreenState();
}

class _AddWorkerScreenState extends State<AddWorkerScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  final nameController = TextEditingController();
  final idController = TextEditingController();
  final employeeCodeController = TextEditingController();
  final phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();

  bool _isSaving = false;
  
 
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  

  String gender = 'Female';
  String area = 'Ukkadam North';

  final areas = [
    'Ukkadam North',
    'Ukkadam South',
    'Town Hall Central',
    'RS Puram West',
    'Gandhipuram',
  ];

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    employeeCodeController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Widget field(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: navy,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboard,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter $label',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5EBF3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5EBF3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveWorker() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isSaving = true;
  });

  try {
    final response = await _apiClient.post(
      '/workers/',
      data: {
        'full_name': nameController.text.trim(),
        'employee_id': idController.text.trim(),
        'employee_code': employeeCodeController.text.trim(),
        'mobile_number': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'designation': 'Community Health Worker',
        'area': area,
      },
    );

    if (!mounted) return;

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health worker registered successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    }
  } on DioException catch (e) {
    if (!mounted) return;

    final responseData = e.response?.data;

    final message = responseData is Map
        ? responseData['detail']?.toString() ??
            'Unable to register worker.'
        : 'Unable to connect to the server.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registration failed: $e'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text('Add health worker'),
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'FIELD TEAM REGISTRATION',
              style: TextStyle(
                color: blue,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Worker details',
              style: TextStyle(
                color: navy,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 22),

            field('Full name', nameController),
field('Employee ID', idController),
field('Employee Code', employeeCodeController),
field(
  'Mobile number',
              phoneController,
              keyboard: TextInputType.phone,
            ),
            field(
              'Email address',
              emailController,
              keyboard: TextInputType.emailAddress,
            ),
            field('Address', addressController),

            const Text(
              'Gender',
              style: TextStyle(
                color: navy,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: gender,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              items: ['Female', 'Male', 'Other']
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => gender = value);
                }
              },
            ),

            const SizedBox(height: 18),

            const Text(
              'Assigned area',
              style: TextStyle(
                color: navy,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: area,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              items: areas
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => area = value);
                }
              },
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : saveWorker,
icon: _isSaving
    ? const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
    : const Icon(Icons.person_add_alt_1),
label: Text(
  _isSaving ? 'Registering...' : 'Register health worker',
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
}