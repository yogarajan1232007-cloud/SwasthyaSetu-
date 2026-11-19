import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../assignments/data/assignment_data_store.dart';
import '../../referrals/data/referral_mock_data.dart';
import '../../households/data/household_data_store.dart';

class WorkerIndividualsScreen extends StatelessWidget {
  final Map<String, dynamic> worker;

  const WorkerIndividualsScreen({
    super.key,
    required this.worker,
  });

  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F7FC);

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatDate(dynamic value) {
    if (value is! DateTime) {
      return value?.toString() ?? 'N/A';
    }

    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    final workerId = worker['id'].toString();

    // Actual household records assigned to this worker.
    final households =
        HouseholdDataStore.getWorkerHouseholds(workerId);

    // Actual household statistics.
    final totalHouseholds = households.length;

    final totalIndividuals = households.fold<int>(
      0,
      (total, household) {
        return total +
            HouseholdDataStore.getHouseholdMembers(
              household['id'].toString(),
            ).length;
      },
    );

    final consentGranted = households.fold<int>(
      0,
      (total, household) {
        final members =
            HouseholdDataStore.getHouseholdMembers(
          household['id'].toString(),
        );

        return total +
            members.where(
              (member) =>
                  member['consentStatus'] == 'Granted',
            ).length;
      },
    );

    final consentPending = households.fold<int>(
      0,
      (total, household) {
        final members =
            HouseholdDataStore.getHouseholdMembers(
          household['id'].toString(),
        );

        return total +
            members.where(
              (member) =>
                  member['consentStatus'] == 'Pending',
            ).length;
      },
    );

    final consentDeclined = households.fold<int>(
      0,
      (total, household) {
        final members =
            HouseholdDataStore.getHouseholdMembers(
          household['id'].toString(),
        );

        return total +
            members.where(
              (member) =>
                  member['consentStatus'] == 'Declined',
            ).length;
      },
    );

    // Existing assignment records.
    final assignments =
        AssignmentDataStore.getWorkerAssignments(workerId);

    final assignedIndividuals = assignments.fold<int>(
      0,
      (total, assignment) =>
          total + _toInt(assignment['individuals']),
    );

    final completedIndividuals = assignments.fold<int>(
      0,
      (total, assignment) =>
          total + _toInt(assignment['completedIndividuals']),
    );

    final pendingIndividuals =
        (assignedIndividuals - completedIndividuals)
            .clamp(0, assignedIndividuals);

    // Existing referral-based screening records.
    final people = ReferralMockData.referrals.where((person) {
      return person['worker'] == worker['name'];
    }).toList();

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
  title: Text(worker['name']?.toString() ?? 'Worker'),
  backgroundColor: Colors.white,
  foregroundColor: navy,
  elevation: 0,
  actions: [
    IconButton(
      tooltip: 'Edit worker',
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        final updated = await context.pushNamed<bool>(
          'edit-worker',
          pathParameters: {
            'workerId': worker['workerId'].toString(),
          },
          extra: worker,
        );

        if (updated == true && context.mounted) {
          context.pop(true);
        }
      },
    ),
  ],
),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          // ==================================================
          // WORKER PROFILE
          // ==================================================

          const Text(
            'FIELD WORKER PROFILE',
            style: TextStyle(
              color: blue,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            worker['name']?.toString() ?? '',
            style: const TextStyle(
              color: navy,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '${worker['id']} · ${worker['area']}',
            style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 25),

          // ==================================================
          // ACTUAL HOUSEHOLD OVERVIEW
          // ==================================================

          const Text(
            'ACTUAL HOUSEHOLD OVERVIEW',
            style: TextStyle(
              color: blue,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Households',
                  '$totalHouseholds',
                  blue,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _statCard(
                  'Individuals',
                  '$totalIndividuals',
                  Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Consent Granted',
                  '$consentGranted',
                  Colors.green,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _statCard(
                  'Consent Pending',
                  '$consentPending',
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _statCard(
            'Consent Declined',
            '$consentDeclined',
            Colors.red,
          ),

          const SizedBox(height: 25),

          // ==================================================
          // ACTUAL HOUSEHOLD LIST
          // ==================================================

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ASSIGNED HOUSEHOLDS',
                style: TextStyle(
                  color: blue,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),

              Text(
                '$totalHouseholds records',
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (households.isEmpty)
            _emptyCard(
              Icons.home_work_outlined,
              'No households registered',
              'Households assigned to this worker will appear here.',
            )
          else
            ...households.map(
              (household) => _householdCard(
                context,
                household,
              ),
            ),

          const SizedBox(height: 25),

          // ==================================================
          // ASSIGNMENT OVERVIEW
          // ==================================================

          const Text(
            'ASSIGNMENT OVERVIEW',
            style: TextStyle(
              color: blue,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Assigned Individuals',
                  '$assignedIndividuals',
                  blue,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _statCard(
                  'Completed',
                  '$completedIndividuals',
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _statCard(
            'Pending',
            '$pendingIndividuals',
            Colors.orange,
          ),

          const SizedBox(height: 22),

          // ==================================================
          // ASSIGNMENT LIST
          // ==================================================

          const Text(
            'WORK ASSIGNMENTS',
            style: TextStyle(
              color: blue,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 12),

          if (assignments.isEmpty)
            _emptyCard(
              Icons.assignment_outlined,
              'No assignments yet',
              'Assignments created for this worker will appear here.',
            )
          else
            ...assignments.map(_assignmentCard),

          const SizedBox(height: 25),

          // ==================================================
          // EXISTING SCREENING RECORDS
          // ==================================================

          const Text(
            'SCREENED INDIVIDUALS',
            style: TextStyle(
              color: blue,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 12),

          if (people.isEmpty)
            _emptyCard(
              Icons.people_outline,
              'No screening records available',
              'Existing screening records will appear here.',
            )
          else
           ...people.map((person) => _personCard(context, person)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ============================================================
  // HOUSEHOLD CARD
  // ============================================================

  Widget _householdCard(
    BuildContext context,
    Map<String, dynamic> household,
  ) {
    final householdId = household['id'].toString();

    final members =
        HouseholdDataStore.getHouseholdMembers(householdId);

    final consent =
        household['consentStatus']?.toString() ?? 'Pending';

    final color = _consentColor(consent);

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 13),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFFE5EBF3),
        ),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(14),

        onTap: () {
          context.pushNamed(
            'household-details',
            pathParameters: {
              'householdId': householdId,
            },
          );
        },

        child: Padding(
          padding: const EdgeInsets.all(15),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  const Icon(
                    Icons.home_work_outlined,
                    color: blue,
                    size: 22,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          household['householdName']?.toString() ?? '',
                          style: const TextStyle(
                            color: navy,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          householdId,
                          style: const TextStyle(
                            color: Color(0xFF718096),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _consentBadge(consent, color),
                ],
              ),

              const SizedBox(height: 15),

              _infoRow(
                'Household Head',
                household['headOfHousehold']?.toString() ?? '-',
              ),

              _infoRow(
                'Address',
                household['address']?.toString() ?? '-',
              ),

              _infoRow(
                'Contact',
                household['phone']?.toString() ?? '-',
              ),

              _infoRow(
                'Area',
                household['area']?.toString() ?? '-',
              ),

              const Divider(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _smallStat(
                    'Family Members',
                    members.length.toString(),
                  ),

                  _smallStat(
                    'Consent Granted',
                    members.where(
                      (member) =>
                          member['consentStatus'] == 'Granted',
                    ).length.toString(),
                  ),

                  const Icon(
                    Icons.chevron_right,
                    color: navy,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'VIEW HOUSEHOLD DETAILS',
                  style: TextStyle(
                    color: blue,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ASSIGNMENT CARD
  // ============================================================

  Widget _assignmentCard(
    Map<String, dynamic> assignment,
  ) {
    final status =
        assignment['status']?.toString() ?? 'Active';

    final completed =
        _toInt(assignment['completedIndividuals']);

    final total =
        _toInt(assignment['individuals']);

    final pending = (total - completed).clamp(0, total);

    final progress = total == 0
        ? 0.0
        : (completed / total).clamp(0.0, 1.0);

    final householdList =
        (assignment['households'] as List?)
                ?.map((item) => item.toString())
                .toList() ??
            <String>[];

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 13),

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    assignment['id']?.toString() ?? '',
                    style: const TextStyle(
                      color: blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),

                _statusBadge(status),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              assignment['area']?.toString() ?? '',
              style: const TextStyle(
                color: navy,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _infoRow(
              'Assignment Date',
              _formatDate(assignment['assignmentDate']),
            ),

            _infoRow(
              'Due Date',
              _formatDate(assignment['dueDate']),
            ),

            _infoRow(
              'Households',
              '${assignment['householdCount'] ?? 0}',
            ),

            _infoRow(
              'Individuals',
              '$total',
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Assignment progress',
                  style: TextStyle(
                    color: navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE5EBF3),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(blue),
            ),

            const SizedBox(height: 10),

            Text(
              'Completed: $completed  |  Pending: $pending',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF718096),
              ),
            ),

            if (householdList.isNotEmpty) ...[
              const Divider(height: 22),

              const Text(
                'ASSIGNMENT HOUSEHOLD LABELS',
                style: TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              ...householdList.map(
                (name) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.home_outlined,
                        size: 16,
                        color: blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 11,
                            color: navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SCREENING PERSON CARD
  // ============================================================

  Widget _personCard(
  BuildContext context,
  Map<String, dynamic> person,
) {
    final diabetes =
        person['diabetesRisk'] ?? 'Not assessed';

    final cardiovascular =
        person['cardiovascularRisk'] ?? 'Not assessed';

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        contentPadding: const EdgeInsets.all(14),

        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0ECFA),
          child: Text(
            person['initials']?.toString() ?? '',
            style: const TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        title: Text(
          person['name']?.toString() ?? '',
          style: const TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                '${person['individualId']}',
                style: const TextStyle(
                  color: blue,
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                'Diabetes: $diabetes',
                style: const TextStyle(fontSize: 10),
              ),

              Text(
                'Cardiovascular: $cardiovascular',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ),

        trailing: const Icon(
          Icons.chevron_right,
          color: navy,
        ),

        onTap: () {
          context.pushNamed(
            'individual-risk',
            pathParameters: {
              'id': person['id'].toString(),
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // STATISTICS CARD
  // ============================================================

  Widget _statCard(
    String title,
    String value,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5EBF3),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SMALL STATISTICS
  // ============================================================

  Widget _smallStat(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: navy,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF718096),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF718096),
                fontSize: 11,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: navy,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONSENT BADGE
  // ============================================================

  Color _consentColor(String status) {
    if (status == 'Granted') return Colors.green;
    if (status == 'Declined') return Colors.red;
    return Colors.orange;
  }

  Widget _consentBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // ASSIGNMENT STATUS BADGE
  // ============================================================

  Widget _statusBadge(String status) {
    final completed = status == 'Completed';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: completed
            ? const Color(0xFFE8F8EF)
            : const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        status,
        style: TextStyle(
          color: completed ? Colors.green : blue,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyCard(
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE5EBF3),
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            size: 35,
            color: const Color(0xFF9AAABD),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: navy,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}