import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../household_service.dart';
import '../individual_service.dart';

class HouseholdDetailsScreen extends StatefulWidget {
  final String householdId;

  const HouseholdDetailsScreen({
    super.key,
    required this.householdId,
  });

  @override
  State<HouseholdDetailsScreen> createState() =>
      _HouseholdDetailsScreenState();
}
int? _calculateAge(dynamic dateOfBirth) {
  if (dateOfBirth == null) return null;

  final dob = DateTime.tryParse(
    dateOfBirth.toString(),
  );

  if (dob == null) return null;

  final today = DateTime.now();

  int age = today.year - dob.year;

  if (today.month < dob.month ||
      (today.month == dob.month &&
          today.day < dob.day)) {
    age--;
  }

  return age;
}

class _HouseholdDetailsScreenState
    extends State<HouseholdDetailsScreen> {

  final HouseholdService _householdService = HouseholdService();

  Map<String, dynamic>? household;

  bool _isLoading = true;
  String? _errorMessage;

  final IndividualService _individualService = IndividualService();

List<Map<String, dynamic>> members = [];

bool _isLoadingMembers = true;
String? _membersError;

Future<void> _loadMembers() async {
  try {
    final householdId = int.tryParse(widget.householdId);

    if (householdId == null) {
      throw Exception('Invalid household ID');
    }

    final result = await _individualService.fetchHouseholdIndividuals(
      householdId,
    );

    if (!mounted) return;

    setState(() {
      members = result;
      _isLoadingMembers = false;
      _membersError = null;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _membersError = e.toString();
      _isLoadingMembers = false;
    });
  }
}

 @override
void initState() {
  super.initState();
  _loadHousehold();
  _loadMembers();
}

  Future<void> _loadHousehold() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final id = int.tryParse(widget.householdId);

      if (id == null) {
        throw Exception('Invalid household ID');
      }

      final result = await _householdService.fetchHousehold(id);

      if (!mounted) return;

      setState(() {
        household = result;
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
   Future<void> _openIndividualRegistration() async {
  final result = await context.pushNamed(
    'individual-registration',
    pathParameters: {
      'householdId': widget.householdId,
    },
  );

  if (result == true && mounted) {
    await _loadMembers();
  }
}
  Future<void> _openConsentManagement() async {
    await context.pushNamed(
      'consent-management',
      pathParameters: {
        'householdId': widget.householdId,
      },
    );

    if (mounted) {
      setState(() {});
    }
  }
    @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Household Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null || household == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Household Details'),
        ),
        body: Center(
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
                _errorMessage ?? 'Household record not found.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _loadHousehold,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final data = household!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172B4D),
        elevation: 0,
        title: const Text(
          'Household Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openIndividualRegistration,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Individual'),
      ),

      body: RefreshIndicator(
        onRefresh: _loadHousehold,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHouseholdHeader(data),

            const SizedBox(height: 18),

            _buildHouseholdInformation(data),

            const SizedBox(height: 15),

            _buildConsentButton(),

            const SizedBox(height: 18),

            _buildWorkerInformation(data),

            const SizedBox(height: 22),

            _buildMemberStatistics(),

            const SizedBox(height: 18),

            _buildMembersSection(),

            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HOUSEHOLD HEADER
  // ============================================================

  Widget _buildHouseholdHeader(
    Map<String, dynamic> data,
  ) {
    final consent =
        data['consentStatus']?.toString() ?? 'Pending';

    final color = _getConsentColor(consent);

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE7EDF5),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                height: 55,
                width: 55,

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Icon(
                  Icons.home_work_outlined,
                  color: Color(0xFF2563EB),
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      data['household_code']?.toString() ?? '-',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172B4D),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'ID: ${data['id'] ?? '-'}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              'Household Consent: $consent',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HOUSEHOLD INFORMATION
  // ============================================================

  Widget _buildHouseholdInformation(
    Map<String, dynamic> data,
  ) {
    return _sectionCard(
      title: 'Household Information',
      icon: Icons.info_outline,

      children: [
        _infoRow(
          Icons.person_outline,
          'Household Head',
        data['head_of_family']
        ),

        _infoRow(
          Icons.location_on_outlined,
          'Address',
          data['address'],
        ),

        _infoRow(
          Icons.map_outlined,
          'Area',
          data['area'],
        ),

        _infoRow(
          Icons.phone_outlined,
          'Contact Number',
          data['phone'],
        ),

        _infoRow(
          Icons.calendar_today_outlined,
          'Registration Date',
          _formatDate(data['created_at']),
        ),

        _infoRow(
          Icons.assignment_outlined,
          'Registration Status',
          data['status'],
        ),
      ],
    );
  }

  // ============================================================
  // CONSENT MANAGEMENT BUTTON
  // ============================================================

  Widget _buildConsentButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,

      child: ElevatedButton.icon(
        onPressed: _openConsentManagement,

        icon: const Icon(
          Icons.verified_user_outlined,
        ),

        label: const Text(
          'Manage Individual Consent',
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0F766E),
          foregroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WORKER INFORMATION
  // ============================================================

  Widget _buildWorkerInformation(
    Map<String, dynamic> data,
  ) {
    return _sectionCard(
      title: 'Assigned Health Worker',
      icon: Icons.health_and_safety_outlined,

      children: [
        _infoRow(
          Icons.person,
          'Worker Name',
          data['workerName'],
        ),

        _infoRow(
          Icons.badge_outlined,
          'Worker ID',
         data['assigned_worker_id']
        ),
      ],
    );
  }

  // ============================================================
  // MEMBER STATISTICS
  // ============================================================
 // ============================================================
// MEMBER STATISTICS
// ============================================================

Widget _buildMemberStatistics() {
  final total = members.length;

  final granted = members.where((member) {
    return member['consentStatus'] == 'Granted';
  }).length;

  final declined = members.where((member) {
    return member['consentStatus'] == 'Declined';
  }).length;

  final pending = members.where((member) {
    return member['consentStatus'] == 'Pending';
  }).length;

  final revoked = members.where((member) {
    return member['consentStatus'] == 'Revoked';
  }).length;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'FAMILY OVERVIEW',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Color(0xFF2563EB),
        ),
      ),

      const SizedBox(height: 12),

      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.7,
        children: [
          _statCard(
            'Total Members',
            total.toString(),
            Icons.groups_outlined,
            const Color(0xFF2563EB),
          ),
          _statCard(
            'Consent Granted',
            granted.toString(),
            Icons.verified_user_outlined,
            const Color(0xFF16A34A),
          ),
          _statCard(
            'Consent Pending',
            pending.toString(),
            Icons.pending_actions_outlined,
            const Color(0xFFD97706),
          ),
          _statCard(
            'Consent Declined',
            declined.toString(),
            Icons.cancel_outlined,
            const Color(0xFFDC2626),
          ),
          _statCard(
            'Consent Revoked',
            revoked.toString(),
            Icons.block_outlined,
            Colors.purple,
          ),
        ],
      ),
    ],
  );
}
  

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE7EDF5),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Icon(
            icon,
            color: color,
            size: 21,
          ),

          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172B4D),
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HOUSEHOLD MEMBERS
  // ============================================================

 Widget _buildMembersSection() {
  return _sectionCard(
    title: 'Family Members',
    icon: Icons.groups_outlined,
    children: [
      if (_isLoadingMembers)
        const Padding(
          padding: EdgeInsets.all(25),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
      else if (_membersError != null)
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                _membersError!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _loadMembers,
                child: const Text('Retry'),
              ),
            ],
          ),
        )
      else if (members.isEmpty)
        const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 45,
                color: Colors.blueGrey,
              ),
              SizedBox(height: 10),
              Text(
                'No family members registered',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Use Add Individual to register a family member.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        )
      else
        ...members.map(_buildMemberCard),
    ],
  );
}
Widget _buildMemberCard(
  Map<String, dynamic> member,
) {
  final fullName =
      member['full_name']?.toString() ?? '-';

  final individualCode =
      member['individual_code']?.toString() ?? '-';

  final individualId = member['id'];

  final gender =
      member['gender']?.toString() ?? '-';

  final phone =
      member['mobile_number']?.toString() ?? '-';

  final dateOfBirth = member['date_of_birth'];

  final age = _calculateAge(dateOfBirth);

  final isActive = member['is_active'] == true;

  return InkWell(
    borderRadius: BorderRadius.circular(13),

    onTap: () {
      context.pushNamed(
        'individual-details',
        pathParameters: {
          'householdId': widget.householdId,
          'individualId': individualId.toString(),
        },
      );
    },

    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE7EDF5),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFEAF1FF),
                child: Icon(
                  Icons.person_outline,
                  color: Color(0xFF2563EB),
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF172B4D),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      individualCode,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withValues(alpha: 0.10)
                      : Colors.red.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: isActive
                        ? Colors.green
                        : Colors.red,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _infoRow(
            Icons.cake_outlined,
            'Age',
            age == null ? '-' : '$age years',
          ),

          _infoRow(
            Icons.wc_outlined,
            'Gender',
            gender,
          ),

          _infoRow(
            Icons.phone_outlined,
            'Contact',
            phone,
          ),

          _infoRow(
            Icons.calendar_today_outlined,
            'Date of Birth',
            dateOfBirth ?? '-',
          ),

          const SizedBox(height: 5),

          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'View Individual Details →',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  // ============================================================
  // COMMON SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE7EDF5),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF2563EB),
                size: 20,
              ),

              const SizedBox(width: 9),

              Text(
                title,

                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172B4D),
                ),
              ),
            ],
          ),

          const Divider(height: 25),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // COMMON INFORMATION ROW
  // ============================================================

  Widget _infoRow(
    IconData icon,
    String title,
    dynamic value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            size: 17,
            color: Colors.blueGrey,
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 125,

            child: Text(
              title,

              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value?.toString() ?? '-',

              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF172B4D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONSENT COLOR
  // ============================================================

  Color _getConsentColor(String status) {
    if (status == 'Granted') {
      return const Color(0xFF16A34A);
    }

    if (status == 'Declined') {
      return const Color(0xFFDC2626);
    }

    return const Color(0xFFD97706);
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

    String _formatDate(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());

    if (date == null) return '-';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}