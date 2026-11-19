import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../officer/households/data/household_data_store.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final String householdId;
  final String individualId;

  const PersonalDetailsScreen({
    super.key,
    required this.householdId,
    required this.individualId,
  });

  @override
  State<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color muted = Color(0xFF8292A8);
  static const Color background = Color(0xFFF4F7FC);

  late Map<String, dynamic>? individual;
  late Map<String, dynamic>? household;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    household = HouseholdDataStore.getHouseholdById(
      widget.householdId,
    );

    final members = HouseholdDataStore.getHouseholdMembers(
      widget.householdId,
    );

    individual = members.cast<Map<String, dynamic>?>().firstWhere(
      (member) => member?['id']?.toString() == widget.individualId,
      orElse: () => null,
    );
  }

  String _value(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Not provided';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (individual == null || household == null) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(title: const Text('Personal Details')),
        body: const Center(
          child: Text('Individual or household record not found.'),
        ),
      );
    }

    final person = individual!;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        title: const Text(
          'Personal Details',
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
            'STEP 1 OF 2',
            style: TextStyle(
              color: blue,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Verify personal information',
            style: TextStyle(
              color: navy,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Confirm the registered individual details before screening.',
            style: TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 22),

          _field('Full name', person['name']),
          _field('Date of birth', person['dateOfBirth']),
          _field('Age', person['age'] == null
              ? null
              : '${person['age']} years'),
          _field('Gender', person['gender']),
          _field('Mobile number', person['phone']),
          _field('Household ID', widget.householdId),
          _field('Address', household!['address']),
          _field('Emergency contact', person['emergencyContact']),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Please verify the information with the individual. '
                    'Correct any inaccurate details through the '
                    'approved registration process before continuing.',
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
            height: 53,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  '/worker-consent/${widget.householdId}/${widget.individualId}',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Verify & Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: const Color(0xFFDCE5F0),
              ),
            ),
            child: Text(
              _value(value),
              style: const TextStyle(
                color: navy,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}