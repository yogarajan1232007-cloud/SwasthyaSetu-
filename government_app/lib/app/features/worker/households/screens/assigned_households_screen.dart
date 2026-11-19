import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../officer/assignments/data/assignment_data_store.dart';
import '../../../officer/households/data/household_data_store.dart';

class AssignedHouseholdsScreen extends StatefulWidget {
  const AssignedHouseholdsScreen({super.key});

  static const String workerId = 'HW-2048';

  @override
  State<AssignedHouseholdsScreen> createState() =>
      _AssignedHouseholdsScreenState();
}

class _AssignedHouseholdsScreenState
    extends State<AssignedHouseholdsScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F7FC);
  static const Color muted = Color(0xFF8493A8);

  final TextEditingController searchController =
      TextEditingController();

  String selectedFilter = 'All';

  List<Map<String, dynamic>> get assignedHouseholds {
    final assignments = AssignmentDataStore.getWorkerAssignments(
      AssignedHouseholdsScreen.workerId,
    );

    final result = <Map<String, dynamic>>[];

    for (final assignment in assignments) {
      if (assignment['status'] == 'Cancelled') continue;

      final records =
          assignment['householdProgress'] as List<dynamic>? ?? [];

      for (final record in records) {
        final householdId =
            record['householdId']?.toString();

        if (householdId == null) continue;

        final household =
            HouseholdDataStore.getHouseholdById(householdId);

        if (household == null) continue;

        result.add({
          ...household,
          'assignmentId': assignment['id'],
          'assignmentDate': assignment['assignmentDate'],
          'dueDate': assignment['dueDate'],
          'progress': record,
        });
      }
    }

    return result;
  }

  List<Map<String, dynamic>> get filteredHouseholds {
    final query = searchController.text.trim().toLowerCase();

    return assignedHouseholds.where((household) {
      final name =
          household['householdName']?.toString().toLowerCase() ?? '';

      final id = household['id']?.toString().toLowerCase() ?? '';

      final address =
          household['address']?.toString().toLowerCase() ?? '';

      final progress =
          household['progress'] as Map<String, dynamic>;

      final status = progress['status']?.toString() ?? 'Pending';

      final matchesSearch = name.contains(query) ||
          id.contains(query) ||
          address.contains(query);

      final matchesFilter =
          selectedFilter == 'All' || status == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get completedCount => assignedHouseholds.where((household) {
        final progress =
            household['progress'] as Map<String, dynamic>;
        return progress['status'] == 'Completed';
      }).length;

  int get pendingCount => assignedHouseholds.where((household) {
        final progress =
            household['progress'] as Map<String, dynamic>;
        return progress['status'] == 'Pending';
      }).length;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final households = filteredHouseholds;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/worker-dashboard'),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: navy,
            size: 19,
          ),
        ),
        title: const Text(
          'Assigned households',
          style: TextStyle(
            color: navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearch(),
          _buildFilters(),
          Expanded(
            child: households.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {});
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16, 8, 16, 24,
                      ),
                      itemCount: households.length,
                      itemBuilder: (context, index) {
                        return _buildHouseholdCard(
                          households[index],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'UKKADAM NORTH PHC',
            style: TextStyle(
              color: Color(0xFFB9D0EA),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'My assigned households',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _headerStat(
                'TOTAL',
                assignedHouseholds.length.toString(),
              ),
              _headerStat(
                'COMPLETED',
                completedCount.toString(),
              ),
              _headerStat(
                'PENDING',
                pendingCount.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB9D0EA),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: TextField(
        controller: searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search household, ID or address',
          hintStyle: const TextStyle(
            color: muted,
            fontSize: 12,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: muted,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      'All',
      'Pending',
      'In Progress',
      'Completed',
    ];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) {
              setState(() {
                selectedFilter = filter;
              });
            },
            selectedColor: blue,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selected ? Colors.white : navy,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide.none,
          );
        },
      ),
    );
  }

  Widget _buildHouseholdCard(
    Map<String, dynamic> household,
  ) {
    final progress =
        household['progress'] as Map<String, dynamic>;

    final status = progress['status']?.toString() ?? 'Pending';

    final members =
        HouseholdDataStore.getHouseholdMembers(
      household['id'].toString(),
    );

    final total = members.length;

    final completed =
        int.tryParse(
          progress['completedIndividuals']?.toString() ?? '0',
        ) ??
        0;

    final statusColor = status == 'Completed'
        ? const Color(0xFF16A36A)
        : status == 'In Progress'
            ? const Color(0xFFF59E0B)
            : const Color(0xFF2563EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFE5EAF2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: () {
          context.push(
            '/worker-household-details/${household['id']}',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      household['householdName']?.toString() ??
                          'Household',
                      style: const TextStyle(
                        color: navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                household['id'].toString(),
                style: const TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _detailRow(
                Icons.person_outline,
                household['headOfHousehold']?.toString() ??
                    'Not available',
              ),
              const SizedBox(height: 7),
              _detailRow(
                Icons.location_on_outlined,
                household['address']?.toString() ??
                    'Address unavailable',
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 16,
                    color: muted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$total members',
                    style: const TextStyle(
                      color: navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$completed / $total screened',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: total == 0
                      ? 0
                      : (completed / total).clamp(0.0, 1.0),
                  minHeight: 6,
                  backgroundColor: const Color(0xFFEAF0F7),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text(
                    'View household',
                    style: TextStyle(
                      color: blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: muted),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF53647A),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Color(0xFFEAF0FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_work_outlined,
                size: 38,
                color: blue,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No assigned households',
              style: TextStyle(
                color: navy,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Households assigned to your worker account '
              'will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}