import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../households/data/household_data_store.dart';
import '../../dashboard/models/worker_performance.dart';
import '../../dashboard/services/worker_performance_service.dart';

class WorkerManagementScreen extends StatefulWidget {
  const WorkerManagementScreen({super.key});

  @override
  State<WorkerManagementScreen> createState() =>
      _WorkerManagementScreenState();
}
// ============================================================
// REAL HOUSEHOLD STATISTICS
// ============================================================

int getWorkerHouseholdCount(String workerId) {
  return HouseholdDataStore
      .getWorkerHouseholds(workerId)
      .length;
}

int getWorkerIndividualCount(String workerId) {
  final households =
      HouseholdDataStore.getWorkerHouseholds(workerId);

  return households.fold<int>(
    0,
    (total, household) {
      return total +
          HouseholdDataStore.getHouseholdMembers(
            household['id'].toString(),
          ).length;
    },
  );
}

int getWorkerConsentGrantedCount(String workerId) {
  final households =
      HouseholdDataStore.getWorkerHouseholds(workerId);

  return households.fold<int>(
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
}

int getWorkerConsentPendingCount(String workerId) {
  final households =
      HouseholdDataStore.getWorkerHouseholds(workerId);

  return households.fold<int>(
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
}

class _WorkerManagementScreenState
    extends State<WorkerManagementScreen> {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color navy = Color(0xFF15365B);
  static const Color background = Color(0xFFF4F7FC);

  final TextEditingController searchController =
    TextEditingController();

final WorkerPerformanceService _performanceService =
    WorkerPerformanceService();

String selectedFilter = 'All';

List<WorkerPerformance> _workers = [];

bool _isLoading = true;
String? _errorMessage;

List<Map<String, dynamic>> get workers {
  return _workers.map((worker) {
    final initials = worker.workerName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return {
      'name': worker.workerName,
      'initials': initials,
      'id': worker.employeeId,
      'workerId': worker.workerId,
      'area': worker.area,
      'status': worker.isActive ? 'Active' : 'Inactive',
      'assigned': worker.totalAssignments,
      'completed': worker.completedAssignments,
      'pending': worker.pendingAssignments,
      'visits': worker.todaysVisits,
      'households': worker.assignedHouseholds,
      'individuals': worker.totalIndividuals,
    };
  }).toList();
}
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

Future<void> openAddWorker() async {
  final result = await context.pushNamed<bool>(
    'add-worker',
  );

  if (result == true && mounted) {
    await _loadWorkers();
  }
}
  @override
void initState() {
  super.initState();
  _loadWorkers();
}

Future<void> _loadWorkers() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final result =
        await _performanceService.fetchWorkerPerformance();

    if (!mounted) return;

    setState(() {
      _workers = result;
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

  void openCreateAssignment() {
    context.pushNamed('create-assignment');
  }

 Future<void> openWorkerIndividuals(
  Map<String, dynamic> worker,
) async {
  final updated = await context.pushNamed<bool>(
    'worker-individuals',
    pathParameters: {
      'workerId': worker['workerId'].toString(),
    },
    extra: worker,
  );

  if (updated == true && mounted) {
    await _loadWorkers();
  }
}
  List<Map<String, dynamic>> get filteredWorkers {
    final query = searchController.text.toLowerCase().trim();

    return workers.where((worker) {
      final name = worker['name'].toString().toLowerCase();
      final id = worker['id'].toString().toLowerCase();

      final matchesSearch =
          name.contains(query) || id.contains(query);

      final matchesFilter =
          selectedFilter == 'All' ||
          worker['status'] == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = workers
        .where((worker) => worker['status'] == 'Active')
        .length;
    if (_isLoading) {
  return const Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );
}

if (_errorMessage != null) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Health workers'),
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Unable to load health workers'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadWorkers,
            child: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: navy,
            size: 18,
          ),
          onPressed: () => context.goNamed('dashboard'),
        ),
        title: const Text(
          'Health workers',
          style: TextStyle(
            color: navy,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Column(
        children: [
          _buildHeader(activeCount),
          _buildSearchBar(),

          Expanded(
            child: filteredWorkers.isEmpty
                ? const Center(
                    child: Text(
                      'No health workers found.',
                      style: TextStyle(color: navy),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredWorkers.length,
                    itemBuilder: (context, index) {
                      return _buildWorkerCard(
                        filteredWorkers[index],
                      );
                    },
                  ),
          ),
        ],
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader(int activeCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FIELD TEAM',
            style: TextStyle(
              color: primaryBlue,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Health workers',
            style: TextStyle(
              color: navy,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '$activeCount active workers',
            style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: openAddWorker,
                  icon: const Icon(
                    Icons.person_add_alt_1,
                    size: 17,
                  ),
                  label: const Text('Add worker'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: openCreateAssignment,
                  icon: const Icon(
                    Icons.assignment_ind_outlined,
                    size: 17,
                  ),
                  label: const Text('Assign worker'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBlue,
                    side: const BorderSide(
                      color: primaryBlue,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5EBF3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: Color(0xFF718096),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search name or employee ID',
                  border: InputBorder.none,
                  hintStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  selectedFilter = value;
                });
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'All',
                  child: Text('All'),
                ),
                PopupMenuItem(
                  value: 'Active',
                  child: Text('Active'),
                ),
                PopupMenuItem(
                  value: 'Inactive',
                  child: Text('Inactive'),
                ),
              ],
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Filter',
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerCard(Map<String, dynamic> worker) {
  final assigned = (worker['assigned'] as num?)?.toInt() ?? 0;
  final completed = (worker['completed'] as num?)?.toInt() ?? 0;
  final pending = (worker['pending'] as num?)?.toInt() ?? 0;

  final householdCount =
      (worker['households'] as num?)?.toInt() ?? 0;

  final individualCount =
      (worker['individuals'] as num?)?.toInt() ?? 0;

  final progress =
      assigned == 0 ? 0.0 : completed / assigned;

  final isActive = worker['status'] == 'Active';

    return GestureDetector(
      onTap: () => openWorkerIndividuals(worker),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE5EBF3),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: const Color(0xFFE0ECFA),
                  child: Text(
                    worker['initials'].toString(),
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
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              worker['name'].toString(),
                              style: const TextStyle(
                                color: navy,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          const SizedBox(width: 7),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFE8F8EF)
                                  : const Color(0xFFF1F3F5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              worker['status'].toString(),
                              style: TextStyle(
                                color: isActive
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF718096),
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '${worker['id']} · ${worker['area']}',
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color: navy,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Assigned', assigned),
                _buildStat('Completed', completed),
                _buildStat('Pending', pending),
              ],
            ),
            const SizedBox(height: 15),

const Divider(),

const SizedBox(height: 10),

const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    'LIVE HOUSEHOLD DATA',
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
      color: primaryBlue,
    ),
  ),
),

const SizedBox(height: 12),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    _buildStat('Households', householdCount),
    _buildStat('Individuals', individualCount),
  ],
),
            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: const Color(0xFFE5EBF3),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(
                  Color(0xFF0D9488),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String title, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            color: navy,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF718096),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: primaryBlue,
      unselectedItemColor: const Color(0xFF718096),
      selectedFontSize: 11,
      unselectedFontSize: 10,
      onTap: (index) {
        switch (index) {
          case 0:
            context.goNamed('dashboard');
            break;
          case 1:
            context.goNamed('workers');
            break;
          case 2:
            context.goNamed('individuals');
            break;
          case 3:
            context.goNamed('alerts');
            break;
          case 4:
            context.goNamed('dashboard');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups_outlined),
          activeIcon: Icon(Icons.groups),
          label: 'Workers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Individuals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.warning_amber_outlined),
          activeIcon: Icon(Icons.warning),
          label: 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'More',
        ),
      ],
    );
  }
}