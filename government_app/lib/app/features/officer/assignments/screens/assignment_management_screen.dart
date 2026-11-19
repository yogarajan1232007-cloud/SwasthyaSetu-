import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';
import '../data/assignment_service.dart';
import '../../households/data/household_service.dart';

class AssignmentManagementScreen extends StatefulWidget {
  const AssignmentManagementScreen({super.key});

  @override
  State<AssignmentManagementScreen> createState() =>
      _AssignmentManagementScreenState();
}

class _AssignmentManagementScreenState
    extends State<AssignmentManagementScreen> {
  static const Color _blue = Color(0xFF2563EB);
  static const Color _navy = Color(0xFF172B4D);

  final AssignmentService _assignmentService = AssignmentService();
  final HouseholdService _householdService = HouseholdService();
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _error;

  List<Map<String, dynamic>> _assignments = [];
  List<Map<String, dynamic>> _workers = [];
  List<Map<String, dynamic>> _households = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load assignments, workers and households from the backend.
  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _assignmentService.fetchAssignments(skip: 0, limit: 100),
        _householdService.fetchHouseholds(),
        _apiClient.get('/workers/', queryParameters: {
          'skip': 0,
          'limit': 100,
        }),
      ]);

      final workerResponse = results[2];
      if (workerResponse.statusCode != 200) {
        throw Exception('Unable to load health workers.');
      }

      final workers = List<Map<String, dynamic>>.from(
        (workerResponse.data as List).map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );

      if (!mounted) return;
      setState(() {
        _assignments = List<Map<String, dynamic>>.from(results[0]);
        _households = List<Map<String, dynamic>>.from(results[1]);
        _workers = workers;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  Map<String, dynamic>? _findById(
    List<Map<String, dynamic>> records,
    dynamic id,
  ) {
    for (final record in records) {
      if (record['id'].toString() == id.toString()) return record;
    }
    return null;
  }

  Map<String, dynamic> _displayAssignment(
    Map<String, dynamic> assignment,
  ) {
    final worker = _findById(_workers, assignment['worker_id']);
    final household = _findById(_households, assignment['household_id']);
    return {
      ...assignment,
      'worker_name': worker?['full_name'] ?? 'Unknown Worker',
      'worker_code': worker?['employee_id'] ?? '',
      'area': household?['area'] ?? 'Not available',
      'household_name': household?['head_of_family'] ?? 'Unknown Household',
      'household_code': household?['household_code'] ?? '',
    };
  }

  List<Map<String, dynamic>> get _displayAssignments =>
      _assignments.map(_displayAssignment).toList();

  String _statusLabel(dynamic value) {
    switch (value?.toString().toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return value?.toString() ?? 'Pending';
    }
  }

  bool _isActive(Map<String, dynamic> item) {
    final status = item['status']?.toString().toLowerCase();
    return status == 'pending' || status == 'in_progress';
  }

  bool _isOverdue(Map<String, dynamic> item) {
    if (!_isActive(item)) return false;
    final due = DateTime.tryParse(item['due_date']?.toString() ?? '');
    if (due == null) return false;
    final now = DateTime.now();
    return DateTime(due.year, due.month, due.day).isBefore(
      DateTime(now.year, now.month, now.day),
    );
  }

  List<Map<String, dynamic>> get _filteredAssignments {
    final query = _searchController.text.trim().toLowerCase();
    return _displayAssignments.where((item) {
      final searchable = [
        item['worker_name'],
        item['area'],
        item['household_name'],
        item['id'],
      ].join(' ').toLowerCase();
      final matchesSearch = searchable.contains(query);
      final status = _statusLabel(item['status']);
      final matchesFilter = switch (_selectedFilter) {
        'Active' => _isActive(item),
        'Pending' => status == 'Pending',
        'In Progress' => status == 'In Progress',
        'Completed' => status == 'Completed',
        'Cancelled' => status == 'Cancelled',
        'Overdue' => _isOverdue(item),
        _ => true,
      };
      return matchesSearch && matchesFilter;
    }).toList().reversed.toList();
  }

  int get _total => _assignments.length;
  int get _pending => _assignments.where((e) => e['status'] == 'pending').length;
  int get _inProgress =>
      _assignments.where((e) => e['status'] == 'in_progress').length;
  int get _active => _pending + _inProgress;
  int get _completed =>
      _assignments.where((e) => e['status'] == 'completed').length;
  int get _overdue => _assignments.where(_isOverdue).length;

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return 'Not available';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  int _asInt(dynamic value) =>
      value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

  Future<void> _updateAssignment(
    Map<String, dynamic> assignment,
    Map<String, dynamic> data,
    String successMessage,
  ) async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);
    try {
      await _assignmentService.updateAssignment(
        _asInt(assignment['id']),
        data,
      );
      if (!mounted) return;
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update assignment: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _showStatusDialog(Map<String, dynamic> assignment) async {
    var selected = assignment['status']?.toString() ?? 'pending';
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Assignment Status'),
          content: DropdownButtonFormField<String>(
           initialValue: selected,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) {
              if (value != null) setDialogState(() => selected = value);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, selected),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
    if (result == null || !mounted) return;
    await _updateAssignment(
      assignment,
      {'status': result},
      'Assignment status updated successfully.',
    );
  }

  Future<void> _showCancelDialog(Map<String, dynamic> assignment) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Assignment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cancel assignment #${assignment['id']}?'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Cancellation reason',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep Assignment'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a cancellation reason.')),
                );
                return;
              }
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
    );
    final reason = controller.text.trim();
    controller.dispose();
    if (confirmed != true || !mounted) return;
    await _updateAssignment(
      assignment,
      {'status': 'cancelled', 'remarks': reason},
      'Assignment cancelled successfully.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignments = _filteredAssignments;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _navy,
        title: const Text(
          'Assignment Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading || _isUpdating ? null : _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _buildSummary(),
                        const SizedBox(height: 24),
                        _buildSearch(),
                        const SizedBox(height: 16),
                        _buildFilters(),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'All Assignments',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _navy,
                                ),
                              ),
                            ),
                            Text(
                              '${assignments.length} assignments',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (assignments.isEmpty)
                          _buildEmptyState()
                        else
                          ...assignments.map(_buildAssignmentCard),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: Colors.red),
            const SizedBox(height: 14),
            const Text(
              'Unable to load assignments',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
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

  Widget _buildSummary() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.65,
      children: [
        _summaryCard('Total Assignments', '$_total', Icons.assignment_outlined, _blue),
        _summaryCard('Active', '$_active', Icons.pending_actions, const Color(0xFFF59E0B)),
        _summaryCard('Completed', '$_completed', Icons.task_alt, const Color(0xFF16A34A)),
        _summaryCard('Pending', '$_pending', Icons.hourglass_empty, const Color(0xFFDC6B32)),
        _summaryCard('Overdue', '$_overdue', Icons.warning_amber_rounded, Colors.red),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: _navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search worker, area or assignment ID...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE8EDF5)),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const filters = [
      'All', 'Active', 'Pending', 'In Progress', 'Overdue', 'Completed', 'Cancelled',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) => setState(() => _selectedFilter = filter),
              selectedColor: _blue,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssignmentCard(Map<String, dynamic> item) {
    final status = _statusLabel(item['status']);
    final active = _isActive(item);
    final overdue = _isOverdue(item);
    final statusColor = status == 'Completed'
        ? const Color(0xFF16A34A)
        : status == 'Cancelled'
            ? Colors.red
            : status == 'In Progress'
                ? _blue
                : const Color(0xFFF59E0B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EDF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment_outlined, color: _blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['worker_name'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: _navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assignment #${item['id']}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (overdue) ...[
            const SizedBox(height: 10),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 15),
                SizedBox(width: 5),
                Text(
                  'OVERDUE',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 18),
          _infoRow(Icons.location_on_outlined, 'Area', item['area'].toString()),
          _infoRow(Icons.home_outlined, 'Household', item['household_name'].toString()),
          _infoRow(Icons.qr_code, 'Household Code', item['household_code'].toString()),
          _infoRow(Icons.calendar_today_outlined, 'Assigned date', _formatDate(item['assignment_date'])),
          _infoRow(Icons.event_outlined, 'Due date', _formatDate(item['due_date'])),
          if ((item['remarks'] ?? '').toString().trim().isNotEmpty)
            _infoRow(Icons.notes, 'Remarks', item['remarks'].toString()),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isUpdating ? null : () => _showStatusDialog(item),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Update Status'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _blue,
                side: const BorderSide(color: _blue),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (active) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUpdating ? null : () => _showCancelDialog(item),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel Assignment'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () async {
                await context.pushNamed(
                  'assignment-details',
                  pathParameters: {'assignmentId': item['id'].toString()},
                );
                if (mounted) await _loadData();
              },
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('View Assignment Details'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 17, color: Colors.grey),
          const SizedBox(width: 9),
          Text(
            '$title: ',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _navy,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No assignments found',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 6),
          Text(
            'Create an assignment or change your search filter.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
