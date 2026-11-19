import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../individual_service.dart';

class IndividualEditScreen extends StatefulWidget {
  final String householdId;
  final String individualId;

  const IndividualEditScreen({
    super.key,
    required this.householdId,
    required this.individualId,
  });

  @override
  State<IndividualEditScreen> createState() =>
      _IndividualEditScreenState();
}

class _IndividualEditScreenState
    extends State<IndividualEditScreen> {
  final IndividualService _individualService = IndividualService();

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _dateOfBirth;

  String? _gender;

  bool _isLoading = true;
  bool _isSaving = false;

  String? _errorMessage;

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
  ];

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadIndividual();
  }

  // ============================================================
  // LOAD INDIVIDUAL FROM FASTAPI
  // ============================================================

  Future<void> _loadIndividual() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final individualId = int.tryParse(widget.individualId);
      final householdId = int.tryParse(widget.householdId);

      if (individualId == null || householdId == null) {
        throw Exception('Invalid individual or household ID');
      }

      final member = await _individualService.fetchIndividual(
        individualId,
      );
      final memberHouseholdId = int.tryParse(
  member['household_id']?.toString() ?? '',
);

if (memberHouseholdId != householdId) {
  throw Exception(
    'Individual does not belong to this household.',
  );
}

      if (!mounted) return;

      setState(() {
        _nameController.text =
            member['full_name']?.toString() ?? '';

        _phoneController.text =
            member['mobile_number']?.toString() ?? '';

        final dob = member['date_of_birth'];

        _dateOfBirth = dob == null
            ? null
            : DateTime.tryParse(dob.toString());

        final gender = member['gender']?.toString();

        _gender = _genders.contains(gender)
            ? gender
            : null;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select Date of Birth',
    );

    if (selected != null && mounted) {
      setState(() {
        _dateOfBirth = selected;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Select date of birth';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _dateForApi(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // SAVE CHANGES TO FASTAPI
  // ============================================================

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date of birth'),
        ),
      );
      return;
    }

    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select gender'),
        ),
      );
      return;
    }

    final individualId = int.tryParse(widget.individualId);

    if (individualId == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedIndividual =
          await _individualService.updateIndividual(
        individualId,
        {
          'full_name': _nameController.text.trim(),
          'date_of_birth': _dateForApi(_dateOfBirth!),
          'gender': _gender,
          'mobile_number': _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${updatedIndividual['full_name']} updated successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      context.pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update individual: $e'),
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Individual'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Individual'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 45,
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _loadIndividual,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        title: const Text(
          'Edit Individual',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172B4D),
        elevation: 0,
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _buildHeader(),

            const SizedBox(height: 22),

            _buildLabel('Full Name'),

            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: _inputDecoration(
                'Enter full name',
                Icons.person_outline,
              ),
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return 'Enter a valid full name';
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
                  'Date of Birth',
                  Icons.calendar_month_outlined,
                ),
                child: Text(
                  _formatDate(_dateOfBirth),
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
                  return 'Select gender';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            _buildLabel('Phone Number'),

            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: _inputDecoration(
                'Enter 10-digit phone number',
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
                onPressed: _isSaving ? null : _saveChanges,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save Changes',
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

            const SizedBox(height: 15),

            OutlinedButton(
              onPressed: _isSaving
                  ? null
                  : () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE7EDF5),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 27,
            backgroundColor: Color(0xFFEAF1FF),
            child: Icon(
              Icons.edit_outlined,
              color: Color(0xFF2563EB),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Individual Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Individual ID: ${widget.individualId}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF172B4D),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

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
          color: Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
    );
  }
}