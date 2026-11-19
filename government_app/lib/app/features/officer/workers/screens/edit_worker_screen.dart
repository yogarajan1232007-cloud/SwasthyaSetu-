import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

class EditWorkerScreen extends StatefulWidget {
  final Map<String, dynamic> worker;

  const EditWorkerScreen({
    super.key,
    required this.worker,
  });

  @override
  State<EditWorkerScreen> createState() => _EditWorkerScreenState();
}

class _EditWorkerScreenState extends State<EditWorkerScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);

  final _formKey = GlobalKey<FormState>();
  final ApiClient _apiClient = ApiClient();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController designationController;

  late String area;
  bool isSaving = false;

  final areas = [
    'Ukkadam North',
    'Ukkadam South',
    'Town Hall Central',
    'RS Puram West',
    'Gandhipuram',
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.worker['name']?.toString() ?? '',
    );

    phoneController = TextEditingController(
      text: widget.worker['phone']?.toString() ?? '',
    );

    emailController = TextEditingController(
      text: widget.worker['email']?.toString() ?? '',
    );

    designationController = TextEditingController(
      text: widget.worker['designation']?.toString() ??
          'Community Health Worker',
    );

    final savedArea = widget.worker['area']?.toString() ?? '';

    area = areas.contains(savedArea) ? savedArea : areas.first;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    designationController.dispose();
    super.dispose();
  }

  Widget inputField(
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
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateWorker() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final response = await _apiClient.put(
        '/workers/${widget.worker['workerId']}',
        data: {
          'full_name': nameController.text.trim(),
          'mobile_number': phoneController.text.trim(),
          'email': emailController.text.trim(),
          'designation': designationController.text.trim(),
          'area': area,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Worker updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        context.pop(true);
      }
    } on DioException catch (e) {
      if (!mounted) return;

      final data = e.response?.data;
      final message = data is Map
          ? data['detail']?.toString() ?? 'Worker update failed'
          : 'Unable to connect to the server';

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
          content: Text('Update failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text('Edit health worker'),
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
              'WORKER INFORMATION',
              style: TextStyle(
                color: blue,
                fontWeight: FontWeight.w800,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),

            inputField('Full name', nameController),
            inputField(
              'Mobile number',
              phoneController,
              keyboard: TextInputType.phone,
            ),
            inputField(
              'Email address',
              emailController,
              keyboard: TextInputType.emailAddress,
            ),
            inputField('Designation', designationController),

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
              child: ElevatedButton(
                onPressed: isSaving ? null : updateWorker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
