import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../officer/households/data/household_data_store.dart';

class WorkerHouseholdDetailsScreen extends StatefulWidget {
  final String householdId;

  const WorkerHouseholdDetailsScreen({
    super.key,
    required this.householdId,
  });

  @override
  State<WorkerHouseholdDetailsScreen> createState() =>
      _WorkerHouseholdDetailsScreenState();
}

class _WorkerHouseholdDetailsScreenState
    extends State<WorkerHouseholdDetailsScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F7FC);
  static const Color muted = Color(0xFF8292A8);
  
  String? selectedIndividualId;

  Map<String, dynamic>? get household {
    return HouseholdDataStore.getHouseholdById(
      widget.householdId,
    );
  }

  List<Map<String, dynamic>> get members {
    return HouseholdDataStore.getHouseholdMembers(
      widget.householdId,
    );
  }

  int get grantedCount => members.where((member) {
        return member['consentStatus'] == 'Granted';
      }).length;

  int get pendingCount => members.where((member) {
        return member['consentStatus'] == 'Pending';
      }).length;

  int get screenedCount => members.where((member) {
        return member['screeningStatus'] == 'Completed';
      }).length;

  Map<String, dynamic>? get selectedMember {
    if (selectedIndividualId == null) return null;

    for (final member in members) {
      if (member['id'].toString() == selectedIndividualId) {
        return member;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final data = household;

    if (data == null) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text('Household Details'),
        ),
        body: const Center(
          child: Text('Household record not found.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        title: const Text(
          'Household Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showMoreOptions,
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 25),
          children: [
            _buildHouseholdHeader(data),

            const SizedBox(height: 18),

            _buildStatistics(),

            const SizedBox(height: 25),

            _buildMembersHeading(),

            const SizedBox(height: 12),

            if (members.isEmpty)
              _buildEmptyMembers()
            else
              ...members.map(_buildMemberCard),

            const SizedBox(height: 15),

            _buildConsentInformation(),

            const SizedBox(height: 20),

            _buildStartVisitButton(),

            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  // HOUSEHOLD HEADER

  Widget _buildHouseholdHeader(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  color: blue,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data['householdName'] ?? 'Household'}',
                      style: const TextStyle(
                        color: navy,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${data['id'] ?? widget.householdId}',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

          _informationRow(
            Icons.person_outline,
            '${data['headOfHousehold'] ?? 'Not available'}',
          ),

          const SizedBox(height: 9),

          _informationRow(
            Icons.location_on_outlined,
            '${data['address'] ?? 'Address unavailable'}',
          ),

          const SizedBox(height: 9),

          _informationRow(
            Icons.map_outlined,
            '${data['area'] ?? 'Area unavailable'}',
          ),

          const SizedBox(height: 15),

          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Map navigation will be connected later.',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.navigation_outlined, size: 17),
            label: const Text('Navigate'),
            style: OutlinedButton.styleFrom(
              foregroundColor: blue,
              side: const BorderSide(color: Color(0xFFDCE6F5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _informationRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF52647A),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  // STATISTICS

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 17,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Row(
        children: [
          _statItem('Members', members.length.toString()),
          _statDivider(),
          _statItem('Screened', screenedCount.toString()),
          _statDivider(),
          _statItem('Pending', pendingCount.toString()),
        ],
      ),
    );
  }

  Widget _statItem(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: navy,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      height: 38,
      width: 1,
      color: const Color(0xFFE8EDF4),
    );
  }

  // MEMBERS HEADING

  Widget _buildMembersHeading() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HOUSEHOLD MEMBERS',
                style: TextStyle(
                  color: blue,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Screening status',
                style: TextStyle(
                  color: navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'New member registration is managed by the Health Officer.',
                ),
              ),
            );
          },
          icon: const Icon(Icons.add, size: 17),
          label: const Text('Add person'),
        ),
      ],
    );
  }

  // MEMBER CARD

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final id = member['id'].toString();
    final consent =
        member['consentStatus']?.toString() ?? 'Pending';

    final screeningStatus =
        member['screeningStatus']?.toString() ?? 'Not screened';

    final selected = selectedIndividualId == id;

    final consentColor = _consentColor(consent);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFEAF1FF)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: selected
              ? blue
              : const Color(0xFFE5EAF2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          setState(() {
            selectedIndividualId = selected ? null : id;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: const Color(0xFFE0EBF8),
                child: Text(
                  (member['name']?.toString().isNotEmpty ?? false)
                      ? member['name'][0].toString().toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member['name']?.toString() ?? 'Unknown',
                      style: const TextStyle(
                        color: navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${member['age'] ?? '-'} years · '
                      '${member['gender'] ?? '-'}',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: consentColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            consent,
                            style: TextStyle(
                              color: consentColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            screeningStatus,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: muted,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Icon(
                selected
                    ? Icons.check_circle
                    : Icons.arrow_forward_ios,
                color: selected ? blue : navy,
                size: selected ? 20 : 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // EMPTY STATE

  Widget _buildEmptyMembers() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.people_outline,
            color: muted,
            size: 40,
          ),
          SizedBox(height: 10),
          Text(
            'No household members found',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Ask the Health Officer to register household members.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // CONSENT INFORMATION

  Widget _buildConsentInformation() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: blue,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Consent and privacy',
                  style: TextStyle(
                    color: navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$grantedCount members have granted consent. '
                  '$pendingCount members have pending consent. '
                  'Only individuals with valid consent can proceed.',
                  style: const TextStyle(
                    color: Color(0xFF536B89),
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // START HOME VISIT

  Widget _buildStartVisitButton() {
    final member = selectedMember;

    final consentGranted =
        member?['consentStatus'] == 'Granted';

    return SizedBox(
      height: 53,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: member == null
            ? null
            : consentGranted
                ? _startHomeVisit
                : _showConsentWarning,
        icon: const Icon(Icons.assignment_outlined),
        label: Text(
          member == null
              ? 'Select a household member'
              : consentGranted
                  ? 'Start screening for ${member['name']}'
                  : 'Consent required to continue',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFDCE4EF),
          disabledForegroundColor: muted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

 void _startHomeVisit() {
  final member = selectedMember;

  if (member == null) return;

  if (member['consentStatus'] != 'Granted') {
    _showConsentWarning();
    return;
  }

  context.push(
    '/worker-personal-details/'
    '${widget.householdId}/'
    '${member['id']}',
  );
}

  void _showConsentWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Valid consent is required before screening.',
        ),
      ),
    );
  }

  // MORE OPTIONS

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh household'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Close'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _consentColor(String status) {
    switch (status) {
      case 'Granted':
        return const Color(0xFF16A36A);
      case 'Declined':
        return const Color(0xFFDC2626);
      case 'Revoked':
        return const Color(0xFF9333EA);
      default:
        return const Color(0xFFD97706);
    }
  }
}