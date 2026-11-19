import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../household_service.dart';

class HouseholdManagementScreen extends StatefulWidget {
  const HouseholdManagementScreen({super.key});

  @override
  State<HouseholdManagementScreen> createState() =>
      _HouseholdManagementScreenState();
}

class _HouseholdManagementScreenState
    extends State<HouseholdManagementScreen> {
  static const Color blue = Color(0xFF2563EB);
  static const Color navy = Color(0xFF172B4D);

  final TextEditingController _searchController =
      TextEditingController();

  final HouseholdService _householdService = HouseholdService();

  String _selectedArea = 'All Areas';

  List<Map<String, dynamic>> _households = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHouseholds();
  }

  // FETCH HOUSEHOLDS FROM BACKEND

  Future<void> _loadHouseholds() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final result = await _householdService.fetchHouseholds();

      if (!mounted) return;

      setState(() {
        _households = result;

        if (_selectedArea != 'All Areas' &&
            !_households.any(
              (h) => h['area'] == _selectedArea,
            )) {
          _selectedArea = 'All Areas';
        }

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

  // REFRESH

  Future<void> _refresh() async {
    await _loadHouseholds();
  }

  // AREA LIST

  List<String> get _areas {
    final areas = _households
        .map((household) =>
            household['area']?.toString() ?? '')
        .where((area) => area.isNotEmpty)
        .toSet()
        .toList();

    areas.sort();

    return ['All Areas', ...areas];
  }

  // SEARCH AND FILTER

  List<Map<String, dynamic>> get _filteredHouseholds {
    final query =
        _searchController.text.trim().toLowerCase();

    return _households.where((household) {
      final code =
          household['household_code']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final head =
          household['head_of_family']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final area =
          household['area']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final address =
          household['address']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final matchesSearch = query.isEmpty ||
          code.contains(query) ||
          head.contains(query) ||
          area.contains(query) ||
          address.contains(query);

      final matchesArea =
          _selectedArea == 'All Areas' ||
              household['area'] == _selectedArea;

      return matchesSearch && matchesArea;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // MAIN SCREEN

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        title: const Text(
          'Household Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh households',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRegistration,
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_home_outlined),
        label: const Text('Add Household'),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: _buildContent(),
                ),
    );
  }

  // OPEN HOUSEHOLD REGISTRATION

  Future<void> _openRegistration() async {
    final result = await context.pushNamed<bool>(
      'household-registration',
    );

    if (result == true && mounted) {
      await _loadHouseholds();
    }
  }

  // ERROR SCREEN

  Widget _buildError() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 45,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load households',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadHouseholds,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // MAIN CONTENT

  Widget _buildContent() {
    final households = _filteredHouseholds;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatistics(),

        const SizedBox(height: 22),

        _buildSearch(),

        const SizedBox(height: 14),

        _buildFilters(),

        const SizedBox(height: 22),

        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Registered Households',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
            Text(
              '${households.length} records',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),

        if (_households.isEmpty)
          _buildEmptyState(
            'No households registered yet',
            'Start by registering your first household.',
          )
        else if (households.isEmpty)
          _buildEmptyState(
            'No matching households',
            'Try changing your search or filters.',
          )
        else
          ...households.map(_buildHouseholdCard),

        const SizedBox(height: 85),
      ],
    );
  }

  // STATISTICS

  Widget _buildStatistics() {
    final totalHouseholds = _households.length;

    final assignedHouseholds =
        _households.where((household) {
      return household['assigned_worker_id'] != null;
    }).length;

    final unassignedHouseholds =
        totalHouseholds - assignedHouseholds;

    final totalAreas = _households
        .map((household) =>
            household['area']?.toString() ?? '')
        .where((area) => area.isNotEmpty)
        .toSet()
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HOUSEHOLD OVERVIEW',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: blue,
          ),
        ),

        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.65,
          children: [
            _statCard(
              'Total Households',
              totalHouseholds.toString(),
              Icons.home_work_outlined,
              blue,
            ),
            _statCard(
              'Assigned Households',
              assignedHouseholds.toString(),
              Icons.assignment_ind_outlined,
              const Color(0xFF0891B2),
            ),
            _statCard(
              'Unassigned Households',
              unassignedHouseholds.toString(),
              Icons.pending_actions_outlined,
              const Color(0xFFD97706),
            ),
            _statCard(
              'Areas Covered',
              totalAreas.toString(),
              Icons.location_on_outlined,
              const Color(0xFF16A34A),
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
        borderRadius: BorderRadius.circular(15),
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
              fontWeight: FontWeight.w800,
              color: navy,
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

  // SEARCH

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText:
            'Search household, ID or household head...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: () {
            _searchController.clear();
            setState(() {});
          },
          icon: const Icon(Icons.close),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Color(0xFFE7EDF5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Color(0xFFE7EDF5),
          ),
        ),
      ),
    );
  }

  // AREA FILTER

  Widget _buildFilters() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedArea,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Filter by Area',
        prefixIcon: const Icon(
          Icons.location_on_outlined,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
      items: _areas.map((area) {
        return DropdownMenuItem<String>(
          value: area,
          child: Text(area),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedArea = value ?? 'All Areas';
        });
      },
    );
  }

  // HOUSEHOLD CARD

  Widget _buildHouseholdCard(
    Map<String, dynamic> household,
  ) {
    final householdId =
        household['id']?.toString() ?? '';

    final householdCode =
        household['household_code']?.toString() ??
            householdId;

    final assignedWorkerId =
        household['assigned_worker_id'];

    final assignedWorker = assignedWorkerId == null
        ? 'Not assigned'
        : 'Worker ID: $assignedWorkerId';

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(15),
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
              Container(
                height: 43,
                width: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  color: blue,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      householdCode,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Database ID: $householdId',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              _assignmentBadge(assignedWorkerId != null),
            ],
          ),

          const SizedBox(height: 15),

          _detailRow(
            Icons.person_outline,
            'Household Head',
            household['head_of_family']?.toString() ?? '-',
          ),

          const SizedBox(height: 9),

          _detailRow(
            Icons.location_on_outlined,
            'Area',
            household['area']?.toString() ?? '-',
          ),

          const SizedBox(height: 9),

          _detailRow(
            Icons.home_outlined,
            'Address',
            household['address']?.toString() ?? '-',
          ),

          const SizedBox(height: 9),

          _detailRow(
            Icons.pin_drop_outlined,
            'Pincode',
            household['pincode']?.toString() ?? '-',
          ),

          const SizedBox(height: 9),

          _detailRow(
            Icons.health_and_safety_outlined,
            'Assigned Worker',
            assignedWorker,
          ),

          const Divider(height: 25),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: householdId.isEmpty
                  ? null
                  : () async {
                      await context.pushNamed(
                        'household-details',
                        pathParameters: {
                          'householdId': householdId,
                        },
                        extra: household,
                      );

                      if (mounted) {
                        await _loadHouseholds();
                      }
                    },
              icon: const Icon(
                Icons.visibility_outlined,
              ),
              label: const Text(
                'View Household Details',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: blue,
                side: const BorderSide(color: blue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ASSIGNMENT BADGE

  Widget _assignmentBadge(bool assigned) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: assigned
            ? const Color(0xFFE8F7EE)
            : const Color(0xFFFFF3DF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        assigned ? 'Assigned' : 'Unassigned',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: assigned
              ? Colors.green
              : const Color(0xFFD97706),
        ),
      ),
    );
  }

  // DETAIL ROW

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.blueGrey,
        ),
        const SizedBox(width: 9),
        Text(
          '$title: ',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: navy,
            ),
          ),
        ),
      ],
    );
  }

  // EMPTY STATE

  Widget _buildEmptyState(
    String title,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.home_work_outlined,
            size: 45,
            color: Colors.blueGrey,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}