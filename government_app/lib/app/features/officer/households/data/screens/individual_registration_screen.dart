import 'package:material_ui/material_ui.dart';

import '../household_service.dart';
import '../individual_service.dart';

class IndividualRegistrationScreen extends StatefulWidget {
  final String householdId;

  const IndividualRegistrationScreen({
    super.key,
    required this.householdId,
  });

  @override
  State<IndividualRegistrationScreen> createState() =>
      _IndividualRegistrationScreenState();
}

class _IndividualRegistrationScreenState
    extends State<IndividualRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final HouseholdService _householdService = HouseholdService();
final IndividualService _individualService = IndividualService();

Map<String, dynamic>? _household;

bool _isLoadingHousehold = true;
String? _householdError;

  DateTime? _dateOfBirth;
  String? _gender;
  String? _relationship;

  bool _isSaving = false;

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
  ];

  final List<String> _relationships = [
    'Head of Household',
    'Spouse',
    'Son',
    'Daughter',
    'Father',
    'Mother',
    'Grandparent',
    'Other',
  ];
  @override
void initState() {
  super.initState();
  _loadHousehold();
}

Future<void> _loadHousehold() async {
  try {
    final id = int.tryParse(widget.householdId);

    if (id == null) {
      throw Exception('Invalid household ID');
    }

    final result = await _householdService.fetchHousehold(id);

    if (!mounted) return;

    setState(() {
      _household = result;
      _isLoadingHousehold = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _householdError = e.toString();
      _isLoadingHousehold = false;
    });
  }
}
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _dateOfBirth = selectedDate;
      });
    }
  }

  Future<void> _registerIndividual() async {
  if (!_formKey.currentState!.validate()) return;

  if (_dateOfBirth == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select date of birth.'),
      ),
    );
    return;
  }

  if (_gender == null || _relationship == null) return;

  final householdId = int.tryParse(widget.householdId);

  if (householdId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid household ID.'),
      ),
    );
    return;
  }

  setState(() {
    _isSaving = true;
  });

  try {
    final individual = await _individualService.createIndividual({
      'household_id': householdId,
      'full_name': _nameController.text.trim(),
      'date_of_birth':
          '${_dateOfBirth!.year.toString().padLeft(4, '0')}-'
          '${_dateOfBirth!.month.toString().padLeft(2, '0')}-'
          '${_dateOfBirth!.day.toString().padLeft(2, '0')}',
      'gender': _gender,
      'mobile_number': _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${individual['full_name']} registered successfully.',
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
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
  if (_isLoadingHousehold) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Individual'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  if (_householdError != null || _household == null) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Individual'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _householdError ?? 'Household not found.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoadingHousehold = true;
                  _householdError = null;
                });
                _loadHousehold();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  final household = _household!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172B4D),
        elevation: 0,
        title: const Text(
          'Register Individual',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.all(18),

          children: [
            _buildHouseholdCard(household),

            const SizedBox(height: 22),

            const Text(
              'INDIVIDUAL INFORMATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Color(0xFF2563EB),
              ),
            ),

            const SizedBox(height: 15),

            _buildLabel('Full Name'),

            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                'Enter individual name',
                Icons.person_outline,
              ),
              validator: (value) {
  final name = value?.trim() ?? '';

  if (name.isEmpty) {
    return 'Please enter full name';
  }

  if (name.length < 2) {
    return 'Full name must contain at least 2 characters';
  }

  return null;
},
            ),

            const SizedBox(height: 18),

            _buildLabel('Date of Birth'),

            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: _inputDecoration(
                  'Select date of birth',
                  Icons.calendar_month_outlined,
                ),
                child: Text(
                  _dateOfBirth == null
                      ? 'Select date of birth'
                      : '${_dateOfBirth!.day.toString().padLeft(2, '0')}/'
                          '${_dateOfBirth!.month.toString().padLeft(2, '0')}/'
                          '${_dateOfBirth!.year}',
                  style: TextStyle(
                    color: _dateOfBirth == null
                        ? Colors.grey
                        : const Color(0xFF172B4D),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            _buildLabel('Gender'),

            DropdownButtonFormField<String>(
              initialValue: _gender,
              isExpanded: true,
              decoration: _inputDecoration(
                'Select gender',
                Icons.wc_outlined,
              ),
              items: _genders.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _gender = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select gender';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            _buildLabel('Relationship with Household Head'),

            DropdownButtonFormField<String>(
              initialValue: _relationship,
              isExpanded: true,
              decoration: _inputDecoration(
                'Select relationship',
                Icons.family_restroom_outlined,
              ),
              items: _relationships.map((relationship) {
                return DropdownMenuItem(
                  value: relationship,
                  child: Text(relationship),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _relationship = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select relationship';
                }
                return null;
              },
            ),

            const SizedBox(height: 18),

            _buildLabel('Contact Number (Optional)'),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: _inputDecoration(
                'Enter 10-digit contact number',
                Icons.phone_outlined,
              ),
              validator: (value) {
                final phone = value?.trim() ?? '';

                if (phone.isNotEmpty &&
                    !RegExp(r'^[6-9][0-9]{9}$').hasMatch(phone)) {
                  return 'Enter a valid 10-digit mobile number';
                }

                return null;
              },
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _registerIndividual,
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
                  _isSaving
                      ? 'Registering...'
                      : 'Register Individual',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
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

  Widget _buildHouseholdCard(Map<String, dynamic> household) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REGISTERING UNDER HOUSEHOLD',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            household['household_code']?.toString() ?? '-',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172B4D),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Household ID: ${household['id']}',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF172B4D),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE7EDF5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE7EDF5),
        ),
      ),
    );
  }
}