import '../../workers/screens/data/worker_data_store.dart';
import '../../households/data/household_data_store.dart';

class AssignmentDataStore {
  static final List<Map<String, dynamic>> assignments = [];

  static String _generateAssignmentId() {
    return 'ASG-${DateTime.now().microsecondsSinceEpoch}';
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ============================================================
  // CHECK WHETHER A HOUSEHOLD IS ALREADY ACTIVELY ASSIGNED
  // ============================================================

  static bool isHouseholdAssigned(String householdId) {
    return assignments.any((assignment) {
      if (assignment['status'] != 'Active') return false;

      final ids = assignment['householdIds'];

      if (ids is List) {
        return ids.contains(householdId);
      }

      return false;
    });
  }

  // ============================================================
  // CREATE ASSIGNMENT USING REAL HOUSEHOLDS
  // ============================================================

  static Map<String, dynamic> createAssignment({
    required String workerId,
    required String workerName,
    required String area,
    required List<String> households,
    List<String>? householdIds,
    required DateTime assignmentDate,
    required DateTime dueDate,
  }) {
    final selectedIds = householdIds ?? <String>[];

    if (selectedIds.isEmpty) {
      throw ArgumentError('Select at least one registered household.');
    }

    if (selectedIds.toSet().length != selectedIds.length) {
      throw ArgumentError('Duplicate household IDs are not allowed.');
    }

    if (households.length != selectedIds.length) {
      throw ArgumentError('Household names and IDs do not match.');
    }

    final workerIndex = WorkerDataStore.workers.indexWhere(
      (worker) =>
          worker['id'].toString() == workerId &&
          worker['status'] == 'Active',
    );

    if (workerIndex == -1 ||
        WorkerDataStore.workers[workerIndex]['area']?.toString() != area) {
      throw ArgumentError('Select an active health worker from the same area.');
    }

    if (dueDate.isBefore(assignmentDate)) {
      throw ArgumentError('Due date cannot be before assignment date.');
    }

    final householdRecords = <Map<String, dynamic>>[];

    for (int i = 0; i < selectedIds.length; i++) {
      final household =
          HouseholdDataStore.getHouseholdById(selectedIds[i]);

      if (household == null) {
        throw ArgumentError('Household not found: ${selectedIds[i]}');
      }

      if (household['area'] != area) {
        throw ArgumentError('Household area does not match assignment area.');
      }

      if (isHouseholdAssigned(selectedIds[i])) {
        throw ArgumentError('Household is already actively assigned.');
      }

      final members = HouseholdDataStore.getHouseholdMembers(
        selectedIds[i],
      );

      if (members.isEmpty) {
        throw ArgumentError(
          'Household ${household['householdName']} has no registered members.',
        );
      }

      householdRecords.add({
        'householdId': selectedIds[i],
        'name': household['householdName'],
        'individuals': members.length,
        'completedIndividuals': 0,
        'pendingIndividuals': members.length,
        'status': 'Pending',
      });
    }

    final individualCount = householdRecords.fold<int>(
      0,
      (total, household) =>
          total + _toInt(household['individuals']),
    );

    final assignment = <String, dynamic>{
      'id': _generateAssignmentId(),
      'workerId': workerId,
      'workerName': workerName,
      'area': area,
      'households': householdRecords
          .map((household) => household['name'].toString())
          .toList(),
      'householdIds': List<String>.from(selectedIds),
      'householdProgress': householdRecords,
      'householdCount': householdRecords.length,
      'completedHouseholds': 0,
      'individuals': individualCount,
      'completedIndividuals': 0,
      'pendingIndividuals': individualCount,
      'status': 'Active',
      'assignmentDate': assignmentDate,
      'dueDate': dueDate,
      'createdAt': DateTime.now(),
    };

    // Update household ownership to the selected worker.
    for (final household in householdRecords) {
      final id = household['householdId'];

      if (id == null) continue;

      final actualHousehold =
          HouseholdDataStore.getHouseholdById(id.toString());

      if (actualHousehold != null) {
        actualHousehold['workerId'] = workerId;
        actualHousehold['workerName'] = workerName;
      }
    }

    assignments.add(assignment);
    _syncWorkerStatistics(workerId);

    return assignment;
  }

  // ============================================================
  // GET ALL ASSIGNMENTS
  // ============================================================

  static List<Map<String, dynamic>> getAllAssignments() {
    return List<Map<String, dynamic>>.from(assignments);
  }

  // ============================================================
  // GET ASSIGNMENTS BY WORKER
  // ============================================================

  static List<Map<String, dynamic>> getWorkerAssignments(
    String workerId,
  ) {
    return assignments.where((assignment) {
      return assignment['workerId'].toString() == workerId;
    }).toList();
  }

  // ============================================================
  // GET ASSIGNMENT BY ID
  // ============================================================

  static Map<String, dynamic>? getAssignmentById(
    String assignmentId,
  ) {
    try {
      return assignments.firstWhere(
        (assignment) => assignment['id'] == assignmentId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // REASSIGN ASSIGNMENT
  // ============================================================

  static bool reassignAssignment({
    required String assignmentId,
    required String newWorkerId,
  }) {
    final assignment = getAssignmentById(assignmentId);

    if (assignment == null ||
        assignment['status'] == 'Completed' ||
        assignment['status'] == 'Cancelled') {
      return false;
    }

    final index = WorkerDataStore.workers.indexWhere(
      (worker) =>
          worker['id'].toString() == newWorkerId &&
          worker['status'] == 'Active',
    );

    if (index == -1) return false;

    final newWorker = WorkerDataStore.workers[index];
    final oldWorkerId = assignment['workerId'].toString();

    if (oldWorkerId == newWorkerId) return false;

    if (newWorker['area']?.toString() != assignment['area']?.toString()) {
      return false;
    }

    final records =
        assignment['householdProgress'] as List<dynamic>? ?? [];

    for (final record in records) {
      final id = record['householdId'];

      if (id == null) continue;

      final household =
          HouseholdDataStore.getHouseholdById(id.toString());

      if (household != null) {
        household['workerId'] = newWorkerId;
        household['workerName'] = newWorker['name'];
      }
    }

    assignment['workerId'] = newWorkerId;
    assignment['workerName'] = newWorker['name'];

    _syncWorkerStatistics(oldWorkerId);
    _syncWorkerStatistics(newWorkerId);

    return true;
  }

  // ============================================================
  // CANCEL ASSIGNMENT
  // ============================================================

  static bool cancelAssignment({
    required String assignmentId,
    required String reason,
  }) {
    final assignment = getAssignmentById(assignmentId);

    if (assignment == null ||
        assignment['status'] != 'Active' ||
        reason.trim().isEmpty) {
      return false;
    }

    final workerId = assignment['workerId'].toString();

    assignment['status'] = 'Cancelled';
    assignment['cancellationReason'] = reason.trim();
    assignment['cancelledAt'] = DateTime.now();

    _syncWorkerStatistics(workerId);

    return true;
  }

  // ============================================================
  // GET HOUSEHOLD PROGRESS
  // ============================================================

  static List<Map<String, dynamic>> getHouseholds(
    String assignmentId,
  ) {
    final assignment = getAssignmentById(assignmentId);

    if (assignment == null) return [];

    final records = assignment['householdProgress'];

    if (records is! List) return [];

    return records
        .whereType<Map>()
        .map((record) => Map<String, dynamic>.from(record))
        .toList();
  }

  // ============================================================
  // UPDATE HOUSEHOLD PROGRESS
  // ============================================================

  static bool updateHouseholdProgress({
    required String assignmentId,
    required String householdId,
    required int completedIndividuals,
  }) {
    final assignment = getAssignmentById(assignmentId);

    if (assignment == null ||
        assignment['status'] != 'Active') {
      return false;
    }

    final records =
        assignment['householdProgress'] as List<dynamic>?;

    if (records == null) return false;

    final index = records.indexWhere(
      (household) => household['householdId']?.toString() == householdId,
    );

    if (index == -1) return false;

    final household = records[index];

    final total = _toInt(household['individuals']);
    final completed = completedIndividuals.clamp(0, total);

    household['completedIndividuals'] = completed;
    household['pendingIndividuals'] = total - completed;

    household['status'] = completed == 0
        ? 'Pending'
        : completed == total
            ? 'Completed'
            : 'In Progress';

    _recalculateAssignment(assignment);

    return true;
  }
  // ============================================================
// SYNC HOUSEHOLD SCREENING PROGRESS
// ============================================================

static bool syncHouseholdScreeningProgress(
  String householdId,
) {
  final members =
      HouseholdDataStore.getHouseholdMembers(householdId);

  if (members.isEmpty) return false;

  final completedIndividuals = members.where((member) {
    return member['screeningStatus'] == 'Completed';
  }).length;

  bool updated = false;

  for (final assignment in assignments) {
    if (assignment['status'] != 'Active') continue;

    final records =
        assignment['householdProgress'] as List<dynamic>?;

    if (records == null) continue;

    final isAssigned = records.any((record) {
      return record['householdId']?.toString() == householdId;
    });

    if (!isAssigned) continue;

    final success = updateHouseholdProgress(
      assignmentId: assignment['id'].toString(),
      householdId: householdId,
      completedIndividuals: completedIndividuals,
    );

    if (success) updated = true;
  }

  return updated;
}
  // ============================================================
  // RECALCULATE ASSIGNMENT
  // ============================================================

  static void _recalculateAssignment(
    Map<String, dynamic> assignment,
  ) {
    final records =
        assignment['householdProgress'] as List<dynamic>?;

    if (records == null) return;

    int total = 0;
    int completed = 0;
    int completedHouseholds = 0;

    for (final household in records) {
      total += _toInt(household['individuals']);
      completed += _toInt(household['completedIndividuals']);

      if (household['status'] == 'Completed') {
        completedHouseholds++;
      }
    }

    assignment['householdCount'] = records.length;
    assignment['completedHouseholds'] = completedHouseholds;
    assignment['individuals'] = total;
    assignment['completedIndividuals'] = completed;
    assignment['pendingIndividuals'] = total - completed;

    assignment['status'] =
        records.isNotEmpty && completedHouseholds == records.length
            ? 'Completed'
            : 'Active';

    _syncWorkerStatistics(assignment['workerId'].toString());
  }

  // ============================================================
  // LEGACY OVERALL PROGRESS
  // ============================================================

  static bool updateProgress({
    required String assignmentId,
    required int completedIndividuals,
  }) {
    final assignment = getAssignmentById(assignmentId);

    if (assignment == null ||
        assignment['status'] != 'Active') {
      return false;
    }

    final records =
        assignment['householdProgress'] as List<dynamic>?;

    if (records == null) return false;

    int remaining = completedIndividuals
        .clamp(0, _toInt(assignment['individuals']));

    for (final household in records) {
      final total = _toInt(household['individuals']);
      final completed = remaining.clamp(0, total);

      household['completedIndividuals'] = completed;
      household['pendingIndividuals'] = total - completed;

      household['status'] = completed == 0
          ? 'Pending'
          : completed == total
              ? 'Completed'
              : 'In Progress';

      remaining -= completed;
    }

    _recalculateAssignment(assignment);

    return true;
  }

  // ============================================================
  // WORKER STATISTICS
  // ============================================================

  static void _syncWorkerStatistics(String workerId) {
    final index = WorkerDataStore.workers.indexWhere(
      (worker) => worker['id'].toString() == workerId,
    );

    if (index == -1) return;

    final workerAssignments = getWorkerAssignments(workerId)
        .where((assignment) => assignment['status'] != 'Cancelled')
        .toList();

    final assigned = workerAssignments.fold<int>(
      0,
      (total, assignment) =>
          total + _toInt(assignment['individuals']),
    );

    final completed = workerAssignments.fold<int>(
      0,
      (total, assignment) =>
          total + _toInt(assignment['completedIndividuals']),
    );

    WorkerDataStore.workers[index]['assigned'] = assigned;
    WorkerDataStore.workers[index]['completed'] = completed;
    WorkerDataStore.workers[index]['pending'] = assigned - completed;
  }

  // ============================================================
  // HOUSEHOLD STATUS COUNTS
  // ============================================================

  static int householdCountByStatus(
    String assignmentId,
    String status,
  ) {
    return getHouseholds(assignmentId)
        .where((household) => household['status'] == status)
        .length;
  }

  // ============================================================
  // OVERDUE
  // ============================================================

  static bool isOverdue(Map<String, dynamic> assignment) {
    final dueDate = assignment['dueDate'];

    if (dueDate is! DateTime) return false;

    if (assignment['status'] == 'Completed' ||
        assignment['status'] == 'Cancelled') {
      return false;
    }

    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day).isAfter(
      DateTime(dueDate.year, dueDate.month, dueDate.day),
    );
  }

  static int get overdueAssignments =>
      assignments.where(isOverdue).length;

  static int get totalHouseholds =>
      assignments.fold<int>(
        0,
        (total, assignment) =>
            total + _toInt(assignment['householdCount']),
      );

  static int get totalIndividuals =>
      assignments.fold<int>(
        0,
        (total, assignment) =>
            total + _toInt(assignment['individuals']),
      );

  static int get totalCompleted =>
      assignments.fold<int>(
        0,
        (total, assignment) =>
            total + _toInt(assignment['completedIndividuals']),
      );

  static int get totalPending =>
      assignments
          .where((assignment) => assignment['status'] != 'Cancelled')
          .fold<int>(
            0,
            (total, assignment) =>
                total + _toInt(assignment['pendingIndividuals']),
          );

  static int get activeAssignments =>
      assignments.where((a) => a['status'] == 'Active').length;

  static int get completedAssignments =>
      assignments.where((a) => a['status'] == 'Completed').length;
}