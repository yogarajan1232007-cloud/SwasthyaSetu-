import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../dashboard/models/worker_performance.dart';
import '../../dashboard/services/worker_performance_service.dart';

class WorkerPerformanceScreen extends StatefulWidget {
  const WorkerPerformanceScreen({super.key});

  @override
  State<WorkerPerformanceScreen> createState() =>
      _WorkerPerformanceScreenState();
}

class _WorkerPerformanceScreenState
    extends State<WorkerPerformanceScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);

  final WorkerPerformanceService _performanceService =
      WorkerPerformanceService();

  List<WorkerPerformance> _workers = [];

  bool _isLoading = true;
  String? _errorMessage;

  String searchQuery = '';
  String selectedFilter = 'All';

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

  int _performance(WorkerPerformance worker) {
    if (worker.totalAssignments == 0) return 0;

    return ((worker.completedAssignments /
                worker.totalAssignments) *
            100)
        .round();
  }

  List<WorkerPerformance> get filteredWorkers {
    return _workers.where((worker) {
      final name = worker.workerName.toLowerCase();
      final id = worker.employeeId.toLowerCase();

      final matchesSearch =
          name.contains(searchQuery) ||
          id.contains(searchQuery);

      final performance = _performance(worker);

      bool matchesFilter = true;

      if (selectedFilter == 'Top performers') {
        matchesFilter = performance >= 80;
      } else if (selectedFilter == 'Needs attention') {
        matchesFilter = performance < 70;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get totalAssigned => _workers.fold(
        0,
        (sum, worker) => sum + worker.totalAssignments,
      );

  int get totalCompleted => _workers.fold(
        0,
        (sum, worker) => sum + worker.completedAssignments,
      );

  int get totalPending => _workers.fold(
        0,
        (sum, worker) => sum + worker.pendingAssignments,
      );

  int get activeWorkers =>
      _workers.where((worker) => worker.isActive).length;

  void openWorker(WorkerPerformance worker) {
    final workerData = {
      'name': worker.workerName,
      'initials': worker.workerName
          .trim()
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .take(2)
          .map((part) => part[0].toUpperCase())
          .join(),
      'id': worker.employeeId,
      'workerId': worker.workerId,
      'area': worker.area,
      'status': worker.isActive ? 'Active' : 'Inactive',
      'assigned': worker.totalAssignments,
      'completed': worker.completedAssignments,
      'pending': worker.pendingAssignments,
    };

    context.pushNamed(
      'worker-individuals',
      pathParameters: {
        'workerId': worker.workerId.toString(),
      },
      extra: workerData,
    );
  }
  @override
  Widget build(BuildContext context) {
    final visibleWorkers = filteredWorkers;
    if (_isLoading) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  if (_errorMessage != null) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Unable to load worker performance'),
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
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        title: const Text(
          'Worker performance',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'FIELD OPERATIONS',
            style: TextStyle(
              color: blue,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Worker performance',
            style: TextStyle(
              color: navy,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Monitor field activity and screening progress.',
            style: TextStyle(
              color: Color(0xFF718096),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 18),

          // SUMMARY
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'Assigned',
                  '$totalAssigned',
                  Icons.assignment_outlined,
                  blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _summaryCard(
                  'Completed',
                  '$totalCompleted',
                  Icons.check_circle_outline,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _summaryCard(
                  'Pending',
                  '$totalPending',
                  Icons.pending_actions,
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ACTIVE WORKERS
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: const Color(0xFFE5EBF3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.groups_outlined,
                  color: blue,
                  size: 23,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Active health workers',
                    style: TextStyle(
                      color: navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$activeWorkers',
                  style: const TextStyle(
                    color: blue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SEARCH
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase().trim();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search worker name or ID',
              prefixIcon: const Icon(
                Icons.search,
                color: navy,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5EBF3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE5EBF3),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // FILTERS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'All',
                'Top performers',
                'Needs attention',
              ].map((filter) {
                final selected = selectedFilter == filter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    selectedColor: navy,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : navy,
                      fontSize: 10,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HEALTH WORKER DIRECTORY',
                style: TextStyle(
                  color: blue,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${visibleWorkers.length} workers',
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 10,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (visibleWorkers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(25),
              child: Center(
                child: Text('No workers found.'),
              ),
            ),

          ...visibleWorkers.map(_workerCard),

          const SizedBox(height: 15),

          // INFORMATION
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: blue,
                  size: 19,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Assignment completion is calculated using '
'completed assignments divided by total assignments. '
'Displayed figures currently come from the connected '
'backend and may include demonstration records.',
                    style: TextStyle(
                      color: navy,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE5EBF3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 9),
          Text(
            value,
            style: const TextStyle(
              color: navy,
              fontSize: 20,
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
      ),
    );
  }

  Widget _workerCard(WorkerPerformance worker) {
  final performance = _performance(worker);

  final progressColor = performance >= 80
      ? const Color(0xFF059669)
      : performance >= 65
          ? blue
          : Colors.orange;

  final initials = worker.workerName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();

  return Container(
    margin: const EdgeInsets.only(bottom: 13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: const Color(0xFFE5EBF3),
      ),
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => openWorker(worker),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFFE0ECFA),
                    child: Text(
                      initials.isEmpty ? '?' : initials,
                      style: const TextStyle(
                        color: navy,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker.workerName,
                          style: const TextStyle(
                            color: navy,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${worker.employeeId} · ${worker.area}',
                          style: const TextStyle(
                            color: Color(0xFF718096),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          worker.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: worker.isActive
                                ? Colors.green
                                : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$performance%',
                    style: TextStyle(
                      color: progressColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: navy,
                  ),
                ],
              ),

              const SizedBox(height: 17),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metric(
                    "Today's visits",
                    '${worker.todaysVisits}',
                  ),
                  _metric(
                    'Assigned',
                    '${worker.totalAssignments}',
                  ),
                  _metric(
                    'Completed',
                    '${worker.completedAssignments}',
                  ),
                  _metric(
                    'Pending',
                    '${worker.pendingAssignments}',
                  ),
                ],
              ),

              const SizedBox(height: 13),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: (performance / 100).clamp(0.0, 1.0),
                  minHeight: 7,
                  backgroundColor: const Color(0xFFE5EBF3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    performance >= 80
                        ? 'Good assignment completion'
                        : performance >= 65
                            ? 'Average assignment completion'
                            : 'Needs attention',
                    style: TextStyle(
                      color: progressColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'View screening records',
                    style: TextStyle(
                      color: blue,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
  Widget _metric(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: navy,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
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
}