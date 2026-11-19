import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../household_service.dart';
import '../individual_service.dart';

class IndividualDetailsScreen extends StatefulWidget {
  final String householdId;
  final String individualId;

  const IndividualDetailsScreen({
    super.key,
    required this.householdId,
    required this.individualId,
  });

  @override
  State<IndividualDetailsScreen> createState() =>
      _IndividualDetailsScreenState();
}

class _IndividualDetailsScreenState
    extends State<IndividualDetailsScreen> {
  final IndividualService _individualService = IndividualService();
  final HouseholdService _householdService = HouseholdService();

  Map<String, dynamic>? individual;
  Map<String, dynamic>? household;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  // ============================================================
  // LOAD INDIVIDUAL AND HOUSEHOLD DETAILS FROM BACKEND
  // ============================================================

  Future<void> _loadDetails() async {
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

      final results = await Future.wait([
        _individualService.fetchIndividual(individualId),
        _householdService.fetchHousehold(householdId),
      ]);

      if (!mounted) return;

      final individualData =
          Map<String, dynamic>.from(results[0]);

      final householdData =
          Map<String, dynamic>.from(results[1]);

      // Ensure the selected individual belongs to this household.
      if (individualData['household_id'] != householdId) {
        throw Exception(
          'This individual does not belong to the selected household.',
        );
      }

      setState(() {
        individual = individualData;
        household = householdData;
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Individual Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null ||
        individual == null ||
        household == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Individual Details'),
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
                  _errorMessage ?? 'Individual record not found',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _loadDetails,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final member = individual!;
    final householdData = household!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172B4D),
        elevation: 0,
        title: const Text(
          'Individual Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadDetails,
          ),
          IconButton(
            tooltip: 'Edit Individual',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final result = await context.pushNamed(
                'individual-edit',
                pathParameters: {
                  'householdId': widget.householdId,
                  'individualId': widget.individualId,
                },
              );

              if (result == true && mounted) {
                await _loadDetails();
              }
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadDetails,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileHeader(member),

            const SizedBox(height: 18),

            _buildPersonalInformation(member),

            const SizedBox(height: 16),

            _buildHouseholdInformation(householdData),

            const SizedBox(height: 16),

            _buildConsentInformation(),

            const SizedBox(height: 16),

            _buildConsentHistory(),

            const SizedBox(height: 16),

            _buildFutureModule(
              title: 'Health Screening History',
              icon: Icons.monitor_heart_outlined,
              description:
                  'Completed health screening records will appear here.',
            ),

            const SizedBox(height: 16),

            _buildFutureModule(
              title: 'AI Health Assessment',
              icon: Icons.psychology_outlined,
              description:
                  'Diabetes and cardiovascular risk assessments '
                  'will appear here after AI integration.',
            ),

            const SizedBox(height: 16),

            _buildFutureModule(
              title: 'Health Trends',
              icon: Icons.show_chart,
              description:
                  'Historical health measurements and trends '
                  'will appear here.',
            ),

            const SizedBox(height: 16),

            _buildFutureModule(
              title: 'Referrals and Follow-ups',
              icon: Icons.medical_services_outlined,
              description:
                  'Referral records and follow-up information '
                  'will appear here.',
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader(
    Map<String, dynamic> member,
  ) {
    final isActive = member['is_active'] == true;

    final statusColor = isActive
        ? Colors.green
        : Colors.red;

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
        children: [
          const CircleAvatar(
            radius: 38,
            backgroundColor: Color(0xFFEAF1FF),
            child: Icon(
              Icons.person,
              size: 40,
              color: Color(0xFF2563EB),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            member['full_name']?.toString() ?? '-',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172B4D),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            member['individual_code']?.toString() ?? '-',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 13),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERSONAL INFORMATION
  // ============================================================

  Widget _buildPersonalInformation(
    Map<String, dynamic> member,
  ) {
    final age = _calculateAge(member['date_of_birth']);

    return _sectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      children: [
        _infoRow(
          'Full Name',
          member['full_name'],
        ),

        _infoRow(
          'Individual ID',
          member['individual_code'],
        ),

        _infoRow(
          'Database ID',
          member['id'],
        ),

        _infoRow(
          'Age',
          age == null ? '-' : '$age years',
        ),

        _infoRow(
          'Date of Birth',
          _formatDate(member['date_of_birth']),
        ),

        _infoRow(
          'Gender',
          member['gender'],
        ),

        _infoRow(
          'Blood Group',
          member['blood_group'],
        ),

        _infoRow(
          'Phone Number',
          member['mobile_number'],
        ),

        _infoRow(
          'Registration Date',
          _formatDate(member['created_at']),
        ),

        _infoRow(
          'Account Status',
          member['is_active'] == true ? 'Active' : 'Inactive',
        ),
      ],
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
      icon: Icons.home_outlined,
      children: [
        _infoRow(
          'Household Code',
          data['household_code'],
        ),

        _infoRow(
          'Household ID',
          data['id'],
        ),

        _infoRow(
          'Household Head',
          data['head_of_family'],
        ),

        _infoRow(
          'Area',
          data['area'],
        ),

        _infoRow(
          'Address',
          data['address'],
        ),

        _infoRow(
          'Pincode',
          data['pincode'],
        ),

        _infoRow(
          'Assigned Worker ID',
          data['assigned_worker_id'],
        ),
      ],
    );
  }

  // ============================================================
  // CONSENT INFORMATION
  // ============================================================

  Widget _buildConsentInformation() {
    return _sectionCard(
      title: 'Consent Information',
      icon: Icons.verified_user_outlined,
      children: [
        _infoRow(
          'Current Status',
          'Not recorded',
        ),

        const SizedBox(height: 8),

        const Text(
          'Consent information is not yet connected to the '
          'individual backend API. Screening eligibility must '
          'be checked against the applicable consent and '
          'approved screening protocol.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.blueGrey,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONSENT HISTORY
  // ============================================================

  Widget _buildConsentHistory() {
    return _sectionCard(
      title: 'Consent History',
      icon: Icons.history,
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              'No consent history available.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FUTURE MODULE PLACEHOLDER
  // ============================================================

  Widget _buildFutureModule({
    required String title,
    required IconData icon,
    required String description,
  }) {
    return _sectionCard(
      title: title,
      icon: icon,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.hourglass_empty,
                color: Colors.blueGrey.shade300,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172B4D),
                  ),
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
  // INFORMATION ROW
  // ============================================================

  Widget _infoRow(
    String label,
    dynamic value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
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
                fontSize: 12,
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
  // AGE CALCULATION
  // ============================================================

  int? _calculateAge(dynamic value) {
    if (value == null) return null;

    final dob = DateTime.tryParse(value.toString());

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