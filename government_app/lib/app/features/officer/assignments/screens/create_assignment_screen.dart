import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';
import '../data/assignment_service.dart';
import '../../households/data/household_service.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() =>
      _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState
    extends State<CreateAssignmentScreen> {
  static const Color blue = Color(0xFF2563EB);
  static const Color navy = Color(0xFF15365B);

  static const int healthOfficerUserId = 3;

  final AssignmentService _assignmentService = AssignmentService();
  final HouseholdService _householdService = HouseholdService();
  final ApiClient _apiClient = ApiClient();

  late DateTime assignmentDate;
  late DateTime dueDate;

  String? selectedWorkerId;
  String? selectedArea;

  final Set<String> selectedHouseholdIds = {};

  List<Map<String, dynamic>> allHouseholds = [];
  List<Map<String, dynamic>> allWorkers = [];
  List<Map<String, dynamic>> allIndividuals = [];
  List<Map<String, dynamic>> allAssignments = [];

  bool isLoading = true;
  bool isSubmitting = false;

  String? loadingError;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    assignmentDate = DateTime.now();

    dueDate = DateTime.now().add(
      const Duration(days: 7),
    );

    _loadData();
  }

  // ============================================================
  // LOAD BACKEND DATA
  // ============================================================

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      loadingError = null;
    });

    try {
      // Load households.
      final households =
          await _householdService.fetchHouseholds();

      // Load workers.
      final workersResponse = await _apiClient.get(
        '/workers/',
        queryParameters: {
          'skip': 0,
          'limit': 100,
        },
      );

      // Load individuals.
      final individualsResponse = await _apiClient.get(
        '/individuals/',
        queryParameters: {
          'skip': 0,
          'limit': 100,
        },
      );

      // Load existing assignments.
      final assignments =
          await _assignmentService.fetchAssignments(
        skip: 0,
        limit: 100,
      );

      if (workersResponse.statusCode != 200 ||
          individualsResponse.statusCode != 200) {
        throw Exception(
          'Unable to load backend records.',
        );
      }

      final workers = List<Map<String, dynamic>>.from(
        (workersResponse.data as List).map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );

      final individuals = List<Map<String, dynamic>>.from(
        (individualsResponse.data as List).map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );

      if (!mounted) return;

      setState(() {
        // Clear old household selections after refreshing.
        selectedHouseholdIds.clear();

        allHouseholds = households;

        allWorkers = workers.where((worker) {
          return worker['is_active'] == true &&
              worker['is_available'] == true;
        }).toList();

        allIndividuals = individuals.where((individual) {
          return individual['is_active'] == true;
        }).toList();

        allAssignments = assignments;

        final availableAreas = areas;

        if (availableAreas.isNotEmpty) {
          selectedArea = availableAreas.first;
          _selectAvailableWorker();
        } else {
          selectedArea = null;
          selectedWorkerId = null;
        }

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        loadingError = error.toString();
      });
    }
  }

  // ============================================================
  // AREAS
  // ============================================================

  List<String> get areas {
    return allHouseholds
        .map((household) => household['area'].toString())
        .toSet()
        .toList()
      ..sort();
  }

  // ============================================================
  // WORKERS
  // ============================================================

  List<Map<String, dynamic>> get activeWorkers {
    return allWorkers;
  }

  List<Map<String, dynamic>> get areaWorkers {
    if (selectedArea == null) return [];

    return activeWorkers.where((worker) {
      return worker['area']?.toString() == selectedArea;
    }).toList();
  }

  Map<String, dynamic>? get selectedWorker {
    try {
      return areaWorkers.firstWhere(
        (worker) =>
            worker['id'].toString() == selectedWorkerId,
      );
    } catch (_) {
      return null;
    }
  }

  void _selectAvailableWorker() {
    if (areaWorkers.isNotEmpty) {
      selectedWorkerId =
          areaWorkers.first['id'].toString();
    } else {
      selectedWorkerId = null;
    }
  }

  // ============================================================
  // ASSIGNMENT STATUS
  // ============================================================

  bool _hasActiveAssignment(String householdId) {
    return allAssignments.any((assignment) {
      final sameHousehold =
          assignment['household_id'].toString() ==
              householdId;

      final status =
          assignment['status']?.toString().toLowerCase();

      return sameHousehold &&
          (status == 'pending' ||
              status == 'in_progress');
    });
  }

  // ============================================================
  // AVAILABLE HOUSEHOLDS
  // ============================================================

  List<Map<String, dynamic>> get availableHouseholds {
    if (selectedArea == null || selectedWorkerId == null) {
      return [];
    }

    return allHouseholds.where((household) {
      final householdId =
          household['id'].toString();

      final matchesArea =
          household['area']?.toString() == selectedArea;

      final assignedWorkerId =
          household['assigned_worker_id'];

      // Allow unassigned households or households
      // already linked to the selected worker.
      final workerMatches =
          assignedWorkerId == null ||
              assignedWorkerId.toString() ==
                  selectedWorkerId;

      // Exclude households that already have
      // pending or in-progress assignments.
      final hasActiveAssignment =
          _hasActiveAssignment(householdId);

      return matchesArea &&
          workerMatches &&
          !hasActiveAssignment;
    }).toList();
  }

  // ============================================================
  // SELECTED HOUSEHOLDS
  // ============================================================

  List<Map<String, dynamic>> get selectedHouseholds {
    return allHouseholds.where((household) {
      return selectedHouseholdIds.contains(
        household['id'].toString(),
      );
    }).toList();
  }

  int get selectedHouseholdCount =>
      selectedHouseholdIds.length;

  // ============================================================
  // INDIVIDUAL COUNTS
  // ============================================================

  int get individualCount {
    final householdIds = selectedHouseholdIds
        .map((id) => int.tryParse(id))
        .whereType<int>()
        .toSet();

    return allIndividuals.where((individual) {
      final householdId =
          int.tryParse(
        individual['household_id'].toString(),
      );

      return householdIds.contains(householdId);
    }).length;
  }

  int getHouseholdIndividualCount(String householdId) {
    final id = int.tryParse(householdId);

    return allIndividuals.where((individual) {
      final individualHouseholdId =
          int.tryParse(
        individual['household_id'].toString(),
      );

      return individualHouseholdId == id;
    }).length;
  }

  // ============================================================
  // CHANGE AREA
  // ============================================================

  void changeArea(String area) {
    setState(() {
      selectedArea = area;

      selectedHouseholdIds.clear();

      _selectAvailableWorker();
    });
  }

  // ============================================================
  // CHANGE WORKER
  // ============================================================

  void changeWorker(String? workerId) {
    if (workerId == null) return;

    setState(() {
      selectedWorkerId = workerId;

      selectedHouseholdIds.removeWhere((householdId) {
        final household = allHouseholds.firstWhere(
          (item) =>
              item['id'].toString() == householdId,
        );

        final assignedWorkerId =
            household['assigned_worker_id'];

        return assignedWorkerId != null &&
            assignedWorkerId.toString() != workerId;
      });
    });
  }

  // ============================================================
  // SELECT HOUSEHOLD
  // ============================================================

  void toggleHousehold(
    String householdId,
    bool selected,
  ) {
    setState(() {
      if (selected) {
        selectedHouseholdIds.add(householdId);
      } else {
        selectedHouseholdIds.remove(householdId);
      }
    });
  }

  // ============================================================
  // DATE FORMATTING
  // ============================================================

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  String _apiDate(DateTime date) {
    final year =
        date.year.toString().padLeft(4, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> selectDate(bool isAssignmentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isAssignmentDate
          ? assignmentDate
          : dueDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isAssignmentDate) {
        assignmentDate = picked;

        if (dueDate.isBefore(assignmentDate)) {
          dueDate = assignmentDate.add(
            const Duration(days: 1),
          );
        }
      } else {
        dueDate = picked;
      }
    });
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // CONFIRM ASSIGNMENT
  // ============================================================

  Future<void> confirmAssignment() async {
    if (isSubmitting) return;

    if (selectedArea == null) {
      _showMessage('No household area available.');
      return;
    }

    if (selectedWorker == null) {
      _showMessage(
        'No active and available health worker found.',
      );
      return;
    }

    if (selectedHouseholdCount == 0) {
      _showMessage(
        'Please select at least one household.',
      );
      return;
    }

    if (dueDate.isBefore(assignmentDate)) {
      _showMessage(
        'Due date cannot be before assignment date.',
      );
      return;
    }

    final workerId =
        int.tryParse(selectedWorkerId ?? '');

    if (workerId == null) {
      _showMessage('Invalid worker ID.');
      return;
    }

    final selectedIds =
        selectedHouseholdIds.toList();

    // Revalidate every selected household.
    for (final householdId in selectedIds) {
      final matches = allHouseholds.where((household) {
        return household['id'].toString() ==
            householdId;
      });

      if (matches.isEmpty) {
        _showMessage(
          'A selected household is no longer available.',
        );
        return;
      }

      final household = matches.first;

      if (household['area']?.toString() != selectedArea) {
        _showMessage(
          'A selected household belongs to another area.',
        );
        return;
      }

      final assignedWorkerId =
          household['assigned_worker_id'];

      if (assignedWorkerId != null &&
          assignedWorkerId.toString() !=
              workerId.toString()) {
        _showMessage(
          'This household is assigned to another worker.',
        );
        return;
      }

      if (_hasActiveAssignment(householdId)) {
        _showMessage(
          'This household already has an active assignment.',
        );
        return;
      }
    }

    // Capture the count before changing selections.
    final totalIndividuals = individualCount;
  

    setState(() {
      isSubmitting = true;
    });

    final successfulAssignments =
        <Map<String, dynamic>>[];

    final failedHouseholds = <String>[];

    for (final householdId in selectedIds) {
      final id = int.tryParse(householdId);

      if (id == null) {
        failedHouseholds.add(householdId);
        continue;
      }

      try {
        final assignment =
            await _assignmentService.createAssignment({
          'worker_id': workerId,
          'household_id': id,
          'assigned_by': healthOfficerUserId,
          'assignment_date': _apiDate(assignmentDate),
          'due_date': _apiDate(dueDate),
          'remarks':
              'Community health screening assignment',
        });

        successfulAssignments.add(assignment);
      } catch (error) {
        debugPrint(
          'Assignment failed for household $id: $error',
        );

        failedHouseholds.add(householdId);
      }
    }

    if (!mounted) return;

    if (successfulAssignments.isEmpty) {
      setState(() {
        isSubmitting = false;
      });

      _showMessage(
        'No assignments were created. Check the backend response.',
      );

      return;
    }

    final workerName =
        selectedWorker?['full_name']?.toString() ??
            'Health Worker';

    final successData = {
      'id': successfulAssignments.first['id'],

      'assignmentIds': successfulAssignments
          .map((item) => item['id'])
          .toList(),

      'workerId': workerId.toString(),

      'workerName': workerName,

      'area': selectedArea!,

      'householdCount': successfulAssignments.length,

      'individuals': totalIndividuals,

      'assignmentDate': assignmentDate,

      'dueDate': dueDate,

      'status': 'pending',

      'partialFailureCount': failedHouseholds.length,
    };

    if (failedHouseholds.isNotEmpty) {
      setState(() {
        isSubmitting = false;
      });

      // Reload the backend records so successfully
      // assigned households disappear from selection.
      await _loadData();

      if (!mounted) return;

      _showMessage(
        '${successfulAssignments.length} assignments created. '
        '${failedHouseholds.length} failed. '
        'Please review and retry the remaining households.',
      );

      return;
    }

    context.pushNamed(
      'assignment-success',
      extra: successData,
    );
  }

  // ============================================================
  // MAIN BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,

        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
          ),
        ),

        title: const Text(
          'Create Assignment',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: isLoading || isSubmitting
                ? null
                : _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : loadingError != null
              ? _buildError()
              : _buildContent(),
    );
  }

  // ============================================================
  // ERROR VIEW
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Colors.red,
              size: 45,
            ),

            const SizedBox(height: 15),

            const Text(
              'Unable to load assignment data',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: navy,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              loadingError ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAIN CONTENT
  // ============================================================

  Widget _buildContent() {
    return ListView(
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

        const SizedBox(height: 10),

        const Text(
          'Create Assignment',
          style: TextStyle(
            color: navy,
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Allocate registered households to health workers.',
          style: TextStyle(
            color: Color(0xFF718096),
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 28),

        // AREA SELECTION

        _label('Select Area'),

        DropdownButtonFormField<String>(
          initialValue: selectedArea,
          isExpanded: true,
          decoration: _decoration(),

          items: areas.map((area) {
            return DropdownMenuItem(
              value: area,
              child: Text(area),
            );
          }).toList(),

          onChanged: isSubmitting
              ? null
              : (value) {
                  if (value != null) {
                    changeArea(value);
                  }
                },
        ),

        const SizedBox(height: 25),

        // WORKER SELECTION

        _label('Select Health Worker'),

        DropdownButtonFormField<String>(
          initialValue: selectedWorkerId,
          isExpanded: true,
          decoration: _decoration(),

          hint: const Text(
            'No active worker available',
          ),

          items: areaWorkers.map((worker) {
            return DropdownMenuItem(
              value: worker['id'].toString(),

              child: Text(
                '${worker['full_name']} '
                '(${worker['employee_id']})',
              ),
            );
          }).toList(),

          onChanged: isSubmitting
              ? null
              : changeWorker,
        ),

        if (areaWorkers.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),

            child: Text(
              'No active and available health worker is registered in this area.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 11,
              ),
            ),
          ),

        const SizedBox(height: 25),

        // HOUSEHOLD SELECTION

        _label('Select Registered Households'),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E8F2),
            ),
          ),

          child: Column(
            children: [
              ListTile(
                title: Text(
                  '$selectedHouseholdCount households selected',
                  style: const TextStyle(
                    color: navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                subtitle: Text(
                  '$individualCount actual registered individuals',
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 10,
                  ),
                ),

                trailing: IconButton(
                  icon: const Icon(
                    Icons.expand_more,
                    color: navy,
                  ),

                  onPressed: selectedWorker == null ||
                          isSubmitting
                      ? null
                      : _showHouseholdSelector,
                ),
              ),

              const Divider(height: 1),

              if (selectedHouseholds.isNotEmpty)
                ...selectedHouseholds.map((household) {
                  return ListTile(
                    dense: true,

                    leading: const Icon(
                      Icons.home_work_outlined,
                      color: blue,
                    ),

                    title: Text(
                      household['head_of_family'].toString(),
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),

                    subtitle: Text(
                      '${household['household_code']} · '
                      '${household['area']}',
                      style: const TextStyle(
                        fontSize: 10,
                      ),
                    ),

                    trailing: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),

                      onPressed: isSubmitting
                          ? null
                          : () {
                              toggleHousehold(
                                household['id'].toString(),
                                false,
                              );
                            },
                    ),
                  );
                }),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // DATES

        Row(
          children: [
            Expanded(
              child: _dateField(
                'Assignment Date',
                assignmentDate,
                () => selectDate(true),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _dateField(
                'Due Date',
                dueDate,
                () => selectDate(false),
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),

        // SCREENING TARGET

        _label('Screening Target'),

        Container(
          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E8F2),
            ),
          ),

          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'All eligible household members, subject to consent and screening eligibility.',
                  style: TextStyle(
                    color: navy,
                    fontSize: 12,
                  ),
                ),
              ),

              Icon(
                Icons.health_and_safety_outlined,
                color: blue,
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // SUMMARY

        _buildSummary(),

        const SizedBox(height: 20),

        // CONFIRM

        SizedBox(
          height: 48,

          child: ElevatedButton(
            onPressed: isSubmitting
                ? null
                : confirmAssignment,

            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            child: isSubmitting
                ? const SizedBox(
                    height: 21,
                    width: 21,

                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Confirm Assignment',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  // ============================================================
  // HOUSEHOLD SELECTOR
  // ============================================================

  void _showHouseholdSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final available = availableHouseholds;

            return SafeArea(
              child: SizedBox(
                height: 550,

                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(18),

                      child: Text(
                        'Select Households',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: navy,
                        ),
                      ),
                    ),

                    Expanded(
                      child: available.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(25),

                                child: Text(
                                  'No available households found in this area for the selected worker.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: available.length,

                              itemBuilder: (context, index) {
                                final household =
                                    available[index];

                                final id =
                                    household['id'].toString();

                                final selected =
                                    selectedHouseholdIds.contains(id);

                                final memberCount =
                                    getHouseholdIndividualCount(id);

                                return CheckboxListTile(
                                  value: selected,
                                  activeColor: blue,

                                  onChanged: (value) {
                                    toggleHousehold(
                                      id,
                                      value ?? false,
                                    );

                                    setSheetState(() {});
                                  },

                                  title: Text(
                                    household['head_of_family']
                                        .toString(),

                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),

                                  subtitle: Text(
                                    '${household['household_code']}'
                                    '\n$memberCount active registered individuals',

                                    style: const TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),

                                  secondary: const Icon(
                                    Icons.home_work_outlined,
                                    color: blue,
                                  ),

                                  isThreeLine: true,
                                );
                              },
                            ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),

                      child: SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                          },

                          child: const Text('Done'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(13),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Assignment Summary',

            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 12),

          _summaryRow(
            'Area',
            selectedArea ?? 'Not selected',
          ),

          _summaryRow(
            'Households',
            '$selectedHouseholdCount',
          ),

          _summaryRow(
            'Actual Individuals',
            '$individualCount',
          ),

          _summaryRow(
            'Health Worker',
            selectedWorker?['full_name']?.toString() ??
                'Not selected',
          ),

          _summaryRow(
            'Assignment Date',
            formatDate(assignmentDate),
          ),

          _summaryRow(
            'Due Date',
            formatDate(dueDate),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Row(
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
  // COMMON LABEL
  // ============================================================

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),

      child: Text(
        text,

        style: const TextStyle(
          color: navy,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _decoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(
          color: Color(0xFFE0E8F2),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(
          color: Color(0xFFE0E8F2),
        ),
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField(
    String label,
    DateTime date,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        _label(label),

        InkWell(
          onTap: isSubmitting ? null : onTap,

          child: Container(
            padding: const EdgeInsets.all(13),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),

              border: Border.all(
                color: const Color(0xFFE0E8F2),
              ),
            ),

            child: Row(
              children: [
                Expanded(
                  child: Text(
                    formatDate(date),

                    style: const TextStyle(
                      color: navy,
                      fontSize: 11,
                    ),
                  ),
                ),

                const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF52677F),
                  size: 19,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}