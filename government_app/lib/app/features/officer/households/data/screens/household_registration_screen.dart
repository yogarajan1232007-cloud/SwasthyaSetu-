import 'package:material_ui/material_ui.dart';
import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';

class HouseholdRegistrationScreen extends StatefulWidget {
  const HouseholdRegistrationScreen({super.key});

  @override
  State<HouseholdRegistrationScreen> createState() =>
      _HouseholdRegistrationScreenState();
}

class _HouseholdRegistrationScreenState
    extends State<HouseholdRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _householdNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _headController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedArea;
  String? _selectedWorkerId;

 bool _isSubmitting = false;
 bool _isLoadingWorkers = true;

final ApiClient _apiClient = ApiClient();

List<Map<String, dynamic>> _activeWorkers = [];

@override
void initState() {
  super.initState();
  _loadActiveWorkers();
}

Future<void> _loadActiveWorkers() async {
  try {
    final response = await _apiClient.get(
      '/workers/',
      queryParameters: {
        'skip': 0,
        'limit': 100,
      },
    );

    final workers = List<Map<String, dynamic>>.from(
      (response.data as List).map(
        (item) => Map<String, dynamic>.from(item),
      ),
    );

    if (!mounted) return;

    setState(() {
      _activeWorkers = workers.where((worker) {
        return worker['is_active'] == true;
      }).toList();

      _isLoadingWorkers = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isLoadingWorkers = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to load health workers: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  List<String> get _availableAreas {
  return _activeWorkers
      .map((worker) => worker['area']?.toString() ?? '')
      .where((area) => area.isNotEmpty && area != 'Unassigned')
      .toSet()
      .toList();
}

  @override
  void dispose() {
    _householdNameController.dispose();
    _addressController.dispose();
    _headController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _registerHousehold() async {
  if (!_formKey.currentState!.validate()) return;

  if (_selectedArea == null || _selectedWorkerId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select an area and health worker.'),
      ),
    );
    return;
  }

  final selectedWorkers = _activeWorkers.where((worker) {
    return worker['id'].toString() == _selectedWorkerId;
  }).toList();

  if (selectedWorkers.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Selected health worker is unavailable.'),
      ),
    );
    return;
  }

  final worker = selectedWorkers.first;
  final workerId = int.tryParse(worker['id'].toString());

  if (workerId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid health worker ID.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  try {
    final response = await _apiClient.post(
      '/households/',
      data: {
        'head_of_family': _headController.text.trim(),
        'address': _addressController.text.trim(),
        'area': _selectedArea,
        'assigned_worker_id': workerId,
      },
    );

    if (!mounted) return;

    final household = Map<String, dynamic>.from(response.data);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Household registered successfully! '
          'Code: ${household['household_code']}',
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  } on DioException catch (e) {
    if (!mounted) return;

    final message = e.response?.data is Map
        ? e.response?.data['detail']?.toString()
        : null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Unable to register household.'),
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
        _isSubmitting = false;
      });
    }
  }
}

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF172B4D),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Color(0xFFE3EAF4),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF172B4D),
        title: const Text(
          'Register Household',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: _isLoadingWorkers
    ? const Center(
        child: CircularProgressIndicator(),
      )
    : _activeWorkers.isEmpty
        ? const Center(
            child: Text(
              'No active health workers available.',
            ),
          )
        : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // INTRODUCTION
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.home_work_outlined,
                          color: Color(0xFF2563EB),
                          size: 32,
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New Household Registration',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF172B4D),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Register a household and assign it to an active health worker.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // HOUSEHOLD INFORMATION
                  _buildSectionTitle(
                    'Household Information',
                    'Enter the household identification and address details.',
                  ),

                  const SizedBox(height: 17),

                  _buildTextField(
                    label: 'Household Name',
                    hint: 'Enter household name',
                    controller: _householdNameController,
                    icon: Icons.home_outlined,
                  ),

                  const SizedBox(height: 15),

                  _buildTextField(
                    label: 'Complete Address',
                    hint: 'Door number, street and locality',
                    controller: _addressController,
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 15),

                  // AREA DROPDOWN
                  DropdownButtonFormField<String>(
                    initialValue: _selectedArea,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Select Area',
                      prefixIcon: const Icon(Icons.map_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    items: _availableAreas.map((area) {
                      return DropdownMenuItem<String>(
                        value: area,
                        child: Text(area),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedArea = value;

                        final matchingWorkers =
                            _activeWorkers.where((worker) {
                          return worker['area'] == value;
                        }).toList();

                        _selectedWorkerId =
                            matchingWorkers.isNotEmpty
                                ? matchingWorkers.first['id'].toString()
                                : null;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select an area';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  // HOUSEHOLD HEAD
                  _buildSectionTitle(
                    'Household Head Details',
                    'Enter the primary contact person details.',
                  ),

                  const SizedBox(height: 17),

                  _buildTextField(
                    label: 'Head of Household',
                    hint: 'Enter full name',
                    controller: _headController,
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 15),

                  _buildTextField(
                    label: 'Contact Number',
                    hint: 'Enter 10-digit mobile number',
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 25),

                  // WORKER ASSIGNMENT
                  _buildSectionTitle(
                    'Health Worker Assignment',
                    'Select the health worker responsible for this household.',
                  ),

                  const SizedBox(height: 17),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedWorkerId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Assigned Health Worker',
                      prefixIcon: const Icon(Icons.health_and_safety_outlined),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    items: _activeWorkers
                        .where((worker) {
                          return _selectedArea == null ||
                              worker['area'] == _selectedArea;
                        })
                        .map((worker) {
                          return DropdownMenuItem<String>(
                            value: worker['id'].toString(),
                            child: Text(
                              '${worker['name']} (${worker['id']})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        })
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWorkerId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a health worker';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 30),

                  // REGISTER BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 53,
                    child: ElevatedButton.icon(
                      onPressed:
                          _isSubmitting ? null : _registerHousehold,
                      icon: const Icon(Icons.add_home_outlined),
                      label: Text(
                        _isSubmitting
                            ? 'Registering...'
                            : 'Register Household',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}