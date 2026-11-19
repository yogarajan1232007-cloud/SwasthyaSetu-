import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../data/followup_service.dart';

class FollowUpsScreen extends StatefulWidget {
  const FollowUpsScreen({super.key});

  @override
  State<FollowUpsScreen> createState() => _FollowUpsScreenState();
}

class _FollowUpsScreenState extends State<FollowUpsScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F7FC);

  final FollowUpService _service = FollowUpService();
  final TextEditingController _searchController =
      TextEditingController();

  List<Map<String, dynamic>> followUps = [];
  List<Map<String, dynamic>> individuals = [];
  List<Map<String, dynamic>> workers = [];

  bool isLoading = true;
  bool isSaving = false;

  String selectedFilter = 'All';
  String searchQuery = '';

  final List<String> filters = [
    'All',
    'Pending',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATA HELPERS
  // ============================================================

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _statusLabel(dynamic value) {
    switch ((value ?? 'pending').toString().toLowerCase()) {
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  String _statusValue(String value) {
    switch (value) {
      case 'In Progress':
        return 'in_progress';
      case 'Completed':
        return 'completed';
      case 'Cancelled':
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  String _individualName(int id) {
    final individual = individuals.where(
      (item) => _toInt(item['id']) == id,
    );

    if (individual.isEmpty) {
      return 'Individual #$id';
    }

    final item = individual.first;

    return (item['full_name'] ??
            item['name'] ??
            item['fullName'] ??
            'Individual #$id')
        .toString();
  }

  String _workerName(dynamic workerId) {
    if (workerId == null) return 'Unassigned';

    final id = _toInt(workerId);

    final worker = workers.where(
      (item) => _toInt(item['id']) == id,
    );

    if (worker.isEmpty) {
      return 'Worker #$id';
    }

    return (worker.first['full_name'] ?? 'Worker #$id').toString();
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Not scheduled';

    final date = DateTime.tryParse(value.toString());

    if (date == null) return value.toString();

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> loadData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final results = await Future.wait([
        _service.fetchFollowUps(),
        _service.fetchIndividuals(),
        _service.fetchWorkers(),
      ]);

      if (!mounted) return;

      setState(() {
        followUps =
            List<Map<String, dynamic>>.from(results[0]);

        individuals =
            List<Map<String, dynamic>>.from(results[1]);

        workers =
            List<Map<String, dynamic>>.from(results[2]);

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  // ============================================================
  // FILTERED DATA
  // ============================================================

  List<Map<String, dynamic>> get filteredItems {
    return followUps.where((item) {
      final status = _statusLabel(item['status']);

      final matchesStatus = selectedFilter == 'All' ||
          status == selectedFilter;

      final individualName = _individualName(
        _toInt(item['individual_id']),
      );

      final matchesSearch = individualName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          (item['followup_type'] ?? '')
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          _workerName(item['worker_id'])
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      return matchesStatus && matchesSearch;
    }).toList();
  }

  int countStatus(String status) {
    return followUps.where((item) {
      return _statusLabel(item['status']) == status;
    }).length;
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // CREATE FOLLOW-UP
  // ============================================================

  Future<void> createFollowUp() async {
    if (individuals.isEmpty) {
      _showMessage(
        'No individuals available. Register an individual first.',
        isError: true,
      );
      return;
    }

    final typeController = TextEditingController();
    final notesController = TextEditingController();

    int? selectedIndividualId;
    int? selectedWorkerId;
    DateTime selectedDate = DateTime.now().add(
      const Duration(days: 7),
    );

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Create follow-up',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Select individual'),

                        DropdownButtonFormField<int>(
                          initialValue: selectedIndividualId,
                          isExpanded: true,
                          decoration: _inputDecoration(
                            'Choose individual',
                          ),
                          items: individuals.map((item) {
                            final id = _toInt(item['id']);

                            final name = (item['full_name'] ??
                                    item['name'] ??
                                    item['fullName'] ??
                                    'Individual #$id')
                                .toString();

                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(
                                name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedIndividualId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select an individual';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _fieldLabel('Follow-up type'),

                        TextFormField(
                          controller: typeController,
                          decoration: _inputDecoration(
                            'e.g. Blood pressure review',
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter follow-up type';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _fieldLabel('Assign health worker'),

                        DropdownButtonFormField<int?>(
                          initialValue: selectedWorkerId,
                          isExpanded: true,
                          decoration: _inputDecoration(
                            'Select worker (optional)',
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('Unassigned'),
                            ),
                            ...workers.map((worker) {
                              return DropdownMenuItem<int?>(
                                value: _toInt(worker['id']),
                                child: Text(
                                  '${worker['full_name']} - ${worker['area']}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedWorkerId = value;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        _fieldLabel('Due date'),

                        OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: dialogContext,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 3650),
                              ),
                            );

                            if (picked != null) {
                              setDialogState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.calendar_month,
                            color: blue,
                          ),
                          label: Text(
                            _formatDate(selectedDate.toIso8601String()),
                          ),
                        ),

                        const SizedBox(height: 16),

                        _fieldLabel('Notes'),

                        TextFormField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: _inputDecoration(
                            'Enter follow-up instructions...',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      await _saveNewFollowUp(
        individualId: selectedIndividualId!,
        workerId: selectedWorkerId,
        followUpType: typeController.text.trim(),
        dueDate: selectedDate,
        notes: notesController.text.trim(),
      );
    }

    typeController.dispose();
    notesController.dispose();
  }

  Future<void> _saveNewFollowUp({
    required int individualId,
    int? workerId,
    required String followUpType,
    required DateTime dueDate,
    String? notes,
  }) async {
    setState(() {
      isSaving = true;
    });

    try {
      await _service.createFollowUp(
        individualId: individualId,
        workerId: workerId,
        followUpType: followUpType,
        dueDate: dueDate,
        notes: notes,
      );

      await loadData();

      if (!mounted) return;

      _showMessage('Follow-up created successfully');
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // UPDATE FOLLOW-UP
  // ============================================================

  Future<void> updateTask(
    Map<String, dynamic> item,
  ) async {
    if ((item['status'] ?? '').toString() == 'completed') {
      _showMessage(
        'Completed follow-ups cannot be modified.',
        isError: true,
      );
      return;
    }

    final notesController = TextEditingController(
      text: (item['notes'] ?? '').toString(),
    );

    final typeController = TextEditingController(
      text: (item['followup_type'] ?? '').toString(),
    );

    String selectedStatus = _statusLabel(item['status']);

    int? selectedWorkerId = item['worker_id'] == null
        ? null
        : _toInt(item['worker_id']);

    DateTime? selectedDate = _parseDate(item['due_date']);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Update follow-up',
                style: TextStyle(
                  color: navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _individualName(
                          _toInt(item['individual_id']),
                        ),
                        style: const TextStyle(
                          color: blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _fieldLabel('Follow-up type'),

                      TextField(
                        controller: typeController,
                        decoration: _inputDecoration(
                          'Follow-up type',
                        ),
                      ),

                      const SizedBox(height: 16),

                      _fieldLabel('Task status'),

                      DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: _inputDecoration(
                          'Select status',
                        ),
                        items: [
                          'Pending',
                          'In Progress',
                          'Completed',
                          'Cancelled',
                        ].map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedStatus = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      _fieldLabel('Assigned worker'),

                      DropdownButtonFormField<int?>(
                        initialValue: selectedWorkerId,
                        isExpanded: true,
                        decoration: _inputDecoration(
                          'Select worker',
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('Unassigned'),
                          ),
                          ...workers.map((worker) {
                            return DropdownMenuItem<int?>(
                              value: _toInt(worker['id']),
                              child: Text(
                                worker['full_name'].toString(),
                              ),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            selectedWorkerId = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      _fieldLabel('Due date'),

                      OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );

                          if (picked != null) {
                            setDialogState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.calendar_month,
                          color: blue,
                        ),
                        label: Text(
                          _formatDate(
                            selectedDate?.toIso8601String(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      _fieldLabel('Visit notes'),

                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: _inputDecoration(
                          'Enter visit observations...',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (typeController.text.trim().isEmpty) {
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Save changes'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      await _saveUpdatedFollowUp(
        item: item,
        workerId: selectedWorkerId,
        followUpType: typeController.text.trim(),
        status: selectedStatus,
        dueDate: selectedDate,
        notes: notesController.text,
      );
    }

    typeController.dispose();
    notesController.dispose();
  }

  Future<void> _saveUpdatedFollowUp({
    required Map<String, dynamic> item,
    required int? workerId,
    required String followUpType,
    required String status,
    DateTime? dueDate,
    required String notes,
  }) async {
    setState(() {
      isSaving = true;
    });

    try {
      final id = _toInt(item['id']);

      if (status == 'Completed') {
        await _service.updateFollowUp(
          id,
          workerId: workerId,
          updateWorker: true,
          followUpType: followUpType,
          dueDate: dueDate,
          notes: notes,
        );

        await _service.completeFollowUp(id);
      } else {
        await _service.updateFollowUp(
          id,
          workerId: workerId,
          updateWorker: true,
          followUpType: followUpType,
          dueDate: dueDate,
          status: _statusValue(status),
          notes: notes,
        );
      }

      await loadData();

      if (!mounted) return;

      _showMessage('Follow-up updated successfully');
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // COMPLETE FOLLOW-UP
  // ============================================================

  Future<void> completeTask(
    Map<String, dynamic> item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Complete follow-up?'),
          content: const Text(
            'Are you sure this follow-up task has been completed?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      isSaving = true;
    });

    try {
      await _service.completeFollowUp(
        _toInt(item['id']),
      );

      await loadData();

      if (!mounted) return;

      _showMessage('Follow-up completed successfully');
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // HISTORY
  // ============================================================

  void openHistory(Map<String, dynamic> item) {
    final individualId = _toInt(item['individual_id']);

    context.pushNamed(
      'individual-risk',
      pathParameters: {
        'id': individualId.toString(),
      },
    );
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  Widget _fieldLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: navy,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFE5EBF3),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return blue;
      case 'Cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  // ============================================================
  // BUILD SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final items = filteredItems;

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        title: const Text(
          'Follow-ups',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: isSaving ? null : createFollowUp,
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create follow-up'),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: blue,
              ),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              color: blue,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  100,
                ),
                children: [
                  const Text(
                    'PROGRAMME TASKS',
                    style: TextStyle(
                      color: blue,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Follow-ups',
                    style: TextStyle(
                      color: navy,
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Prioritised visits and care coordination.',
                    style: TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // STATISTICS

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          'Total',
                          followUps.length.toString(),
                          blue,
                          Icons.assignment_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statCard(
                          'Pending',
                          countStatus('Pending').toString(),
                          Colors.orange,
                          Icons.pending_actions,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statCard(
                          'In Progress',
                          countStatus('In Progress').toString(),
                          blue,
                          Icons.sync,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statCard(
                          'Completed',
                          countStatus('Completed').toString(),
                          Colors.green,
                          Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // SEARCH

                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search individual, worker or task...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: blue,
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();

                                setState(() {
                                  searchQuery = '';
                                });
                              },
                              icon: const Icon(Icons.close),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5EBF3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5EBF3),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'FOLLOW-UP QUEUE',
                    style: TextStyle(
                      color: blue,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // FILTERS

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filters.map((filter) {
                        final selected = selectedFilter == filter;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: selected,
                            selectedColor: navy,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : navy,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
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

                  const SizedBox(height: 18),

                  if (isSaving)
                    const LinearProgressIndicator(
                      color: blue,
                    ),

                  // EMPTY STATE

                  if (items.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(35),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 42,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No follow-up tasks found',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Create a new follow-up or change your filters.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // FOLLOW-UP CARDS

                  ...items.map(_followUpCard),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // FOLLOW-UP CARD
  // ============================================================

  Widget _followUpCard(Map<String, dynamic> item) {
    final status = _statusLabel(item['status']);

    final statusColor = _statusColor(status);

    final individualId = _toInt(item['individual_id']);

    final name = _individualName(individualId);

    final worker = _workerName(item['worker_id']);

    final type = (item['followup_type'] ??
            'Health screening follow-up')
        .toString();

    final notes = (item['notes'] ?? '').toString();

    final dueDate = _formatDate(item['due_date']);

    final completed = status == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE5EBF3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _badge(
                'ID #${item['id']}',
                const Color(0xFFEFF6FF),
                blue,
              ),

              const Spacer(),

              _badge(
                status,
                statusColor.withValues(alpha: 0.10),
                statusColor,
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            name,
            style: const TextStyle(
              color: navy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            type,
            style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 13),

          _infoRow(
            Icons.calendar_month_outlined,
            'Due date: $dueDate',
          ),

          const SizedBox(height: 7),

          _infoRow(
            Icons.person_outline,
            'Assigned to: $worker',
          ),

          const SizedBox(height: 7),

          _infoRow(
            Icons.badge_outlined,
            'Individual ID: $individualId',
          ),

          if (item['screening_id'] != null) ...[
            const SizedBox(height: 7),
            _infoRow(
              Icons.monitor_heart_outlined,
              'Screening ID: ${item['screening_id']}',
            ),
          ],

          if (notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                'Notes: $notes',
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 11,
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          const Divider(
            color: Color(0xFFE5EBF3),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => openHistory(item),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: blue,
                    side: const BorderSide(color: blue),
                  ),
                  child: const Text(
                    'View history',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),

              const SizedBox(width: 9),

              if (!completed) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () => updateTask(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),

                const SizedBox(width: 9),

                IconButton(
                  tooltip: 'Complete follow-up',
                  onPressed: isSaving
                      ? null
                      : () => completeTask(item),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE8F8EF),
                    foregroundColor: Colors.green,
                  ),
                  icon: const Icon(
                    Icons.check_circle_outline,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BADGE
  // ============================================================

  Widget _badge(
    String title,
    Color backgroundColor,
    Color foreground,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _infoRow(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: blue,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATISTICS CARD
  // ============================================================

  Widget _statCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
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
          Icon(
            icon,
            color: color,
            size: 17,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: navy,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}