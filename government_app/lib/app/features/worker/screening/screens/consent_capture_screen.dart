import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../officer/households/data/household_data_store.dart';

class ConsentCaptureScreen extends StatefulWidget {
  final String householdId;
  final String individualId;

  const ConsentCaptureScreen({
    super.key,
    required this.householdId,
    required this.individualId,
  });

  @override
  State<ConsentCaptureScreen> createState() =>
      _ConsentCaptureScreenState();
}

class _ConsentCaptureScreenState extends State<ConsentCaptureScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color teal = Color(0xFF0D9B8E);
  static const Color muted = Color(0xFF8292A8);
  static const Color background = Color(0xFFF4F7FC);

  bool screeningConsent = false;
  bool dataConsent = false;
  bool privacyConsent = false;
  bool isSubmitting = false;

  String consentMethod = 'In person';
  String? guardianName;
  String? guardianRelationship;

  late Map<String, dynamic>? individual;

  final guardianNameController = TextEditingController();

  final relationships = [
    'Parent',
    'Legal guardian',
    'Other authorized representative',
  ];

  @override
  void initState() {
    super.initState();

    final members = HouseholdDataStore.getHouseholdMembers(
      widget.householdId,
    );

    individual = members.cast<Map<String, dynamic>?>().firstWhere(
      (member) =>
          member?['id']?.toString() == widget.individualId,
      orElse: () => null,
    );
  }

  @override
  void dispose() {
    guardianNameController.dispose();
    super.dispose();
  }

  bool get allConsentsGranted =>
      screeningConsent && dataConsent && privacyConsent;

  bool get isMinor {
    final age = individual?['age'];

    if (age is int) return age < 18;

    return int.tryParse(age?.toString() ?? '') != null &&
        int.parse(age.toString()) < 18;
  }

  Future<void> _confirmConsent() async {
    if (!allConsentsGranted) {
      _showMessage(
        'Please obtain all required consents before continuing.',
      );
      return;
    }

    if (isMinor) {
      if (guardianNameController.text.trim().isEmpty ||
          guardianRelationship == null) {
        _showMessage(
          'Guardian name and relationship are required.',
        );
        return;
      }
    }

    setState(() => isSubmitting = true);

    try {
      HouseholdDataStore.updateIndividualConsent(
        householdId: widget.householdId,
        individualId: widget.individualId,
        consentStatus: 'Granted',
        recordedBy: 'S. Kavitha - HW-2048',
        notes:
            'Screening, health data processing and privacy '
            'notice explained. Individual agreed to participate.',
        consentMethod: consentMethod,
        consentFormVersion: '1.0',
        guardianName: isMinor
            ? guardianNameController.text.trim()
            : null,
        guardianRelationship:
            isMinor ? guardianRelationship : null,
      );

      if (!mounted) return;

      context.push(
        '/worker-medical-history/'
        '${widget.householdId}/'
        '${widget.individualId}',
      );
    } catch (e) {
      _showMessage('Unable to save consent. Please try again.');
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
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
    if (individual == null) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(title: const Text('Consent')),
        body: const Center(
          child: Text('Individual record not found.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        title: const Text(
          'Consent Capture',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'STEP 2 OF 2',
            style: TextStyle(
              color: blue,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 18),

          const LinearProgressIndicator(
            value: 1,
            minHeight: 5,
            backgroundColor: Color(0xFFE2EAF3),
            valueColor: AlwaysStoppedAnimation<Color>(teal),
          ),

          const SizedBox(height: 30),

          const Icon(
            Icons.shield_outlined,
            color: teal,
            size: 42,
          ),

          const SizedBox(height: 12),

          const Text(
            'Your information, your choice',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: navy,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Please explain each item in the individual’s '
            'preferred language before recording consent for '
            '${individual!['name']}.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          _consentCard(
            title: 'Screening consent',
            description:
                'I agree to participate in this community '
                'health screening voluntarily.',
            value: screeningConsent,
            onChanged: (value) {
              setState(() => screeningConsent = value);
            },
          ),

          const SizedBox(height: 14),

          _consentCard(
            title: 'Health data processing',
            description:
                'I agree that my screening information may be '
                'securely processed for healthcare coordination '
                'and risk assessment.',
            value: dataConsent,
            onChanged: (value) {
              setState(() => dataConsent = value);
            },
          ),

          const SizedBox(height: 14),

          _consentCard(
            title: 'Privacy notice',
            description:
                'I have received and understood the privacy '
                'notice explaining how my information is used.',
            value: privacyConsent,
            onChanged: (value) {
              setState(() => privacyConsent = value);
            },
          ),

          const SizedBox(height: 25),

          const Text(
            'Consent captured by',
            style: TextStyle(
              color: navy,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            initialValue: consentMethod,
            decoration: _inputDecoration(),
            items: const [
              DropdownMenuItem(
                value: 'In person',
                child: Text('Individual (self)'),
              ),
              DropdownMenuItem(
                value: 'Electronic',
                child: Text('Electronic consent'),
              ),
              DropdownMenuItem(
                value: 'Assisted',
                child: Text('Assisted consent'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => consentMethod = value);
              }
            },
          ),

          if (isMinor) ...[
            const SizedBox(height: 22),

            const Text(
              'Parent / legal guardian details',
              style: TextStyle(
                color: navy,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: guardianNameController,
              decoration: _inputDecoration(
                hint: 'Guardian full name',
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: guardianRelationship,
              decoration: _inputDecoration(
                hint: 'Relationship with individual',
              ),
              items: relationships.map((relationship) {
                return DropdownMenuItem(
                  value: relationship,
                  child: Text(relationship),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  guardianRelationship = value;
                });
              },
            ),
          ],

          const SizedBox(height: 22),

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
                    'Participation is voluntary. Consent can '
                    'be withdrawn at any time without affecting '
                    'access to public health services.',
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
              onPressed: isSubmitting ? null : _confirmConsent,
              icon: const Icon(Icons.check),
              label: Text(
                isSubmitting
                    ? 'Saving consent...'
                    : 'Confirm consent & continue',
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

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _consentCard({
  required String title,
  required String description,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: value
            ? const Color(0xFFB7E5D3)
            : const Color(0xFFE5EAF2),
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: Colors.white,
        child: CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: teal,
          value: value,
          onChanged: (checked) {
            onChanged(checked ?? false);
          },
          title: Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              description,
              style: const TextStyle(
                color: muted,
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
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
    );
  }
}