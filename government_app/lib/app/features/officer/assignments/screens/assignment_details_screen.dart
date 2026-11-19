import 'package:material_ui/material_ui.dart';

import '../../../../core/network/api_client.dart';
import '../data/assignment_service.dart';
import '../../households/data/household_service.dart';

class AssignmentDetailsScreen extends StatefulWidget {
  final String assignmentId;

  const AssignmentDetailsScreen({
    super.key,
    required this.assignmentId,
  });

  @override
  State<AssignmentDetailsScreen> createState() =>
      _AssignmentDetailsScreenState();
}

class _AssignmentDetailsScreenState
    extends State<AssignmentDetailsScreen> {
  static const Color blue = Color(0xFF2455C3);
  static const Color navy = Color(0xFF172B4D);

  final AssignmentService _assignmentService = AssignmentService();
  final HouseholdService _householdService = HouseholdService();
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = true;
  bool _isUpdating = false;

  String? _errorMessage;

  Map<String, dynamic>? _assignment;
  Map<String, dynamic>? _worker;
  Map<String, dynamic>? _household;

  List<Map<String, dynamic>> _members = [];

  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  // LOAD ASSIGNMENT, WORKER, HOUSEHOLD AND FAMILY MEMBERS

  Future<void> _loadDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final assignmentId = int.tryParse(widget.assignmentId);

      if (assignmentId == null) {
        throw Exception('Invalid assignment ID.');
      }

      // Fetch assignment
      final assignment =
          await _assignmentService.fetchAssignment(assignmentId);

      final workerId = int.tryParse(
        assignment['worker_id'].toString(),
      );

      final householdId = int.tryParse(
        assignment['household_id'].toString(),
      );

      if (workerId == null || householdId == null) {
        throw Exception('Invalid worker or household ID.');
      }

      // Fetch related records
      final results = await Future.wait<dynamic>([
        _apiClient.get('/workers/$workerId'),
        _householdService.fetchHousehold(householdId),
        _apiClient.get(
          '/individuals/',
          queryParameters: {
            'skip': 0,
            'limit': 100,
          },
        ),
      ]);

      final worker = Map<String, dynamic>.from(
        results[0].data,
      );

      final household = Map<String, dynamic>.from(
        results[1],
      );

      final individualsResponse = results[2];

      final individuals = List<Map<String, dynamic>>.from(
        (individualsResponse.data as List).map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );

      // Filter members belonging to this household
      final members = individuals.where((member) {
        return member['household_id'].toString() ==
            householdId.toString();
      }).toList();

      if (!mounted) return;

      setState(() {
        _assignment = assignment;
        _worker = worker;
        _household = household;
        _members = members;
        _isLoading = false;
        _isUpdating = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isUpdating = false;
      });
    }
  }

  // DATE FORMAT

  String _formatDate(dynamic value) {
    if (value == null) return 'Not available';

    final date = DateTime.tryParse(value.toString());

    if (date == null) return 'Not available';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // STATUS FORMAT

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';

      case 'in_progress':
        return 'In Progress';

      case 'completed':
        return 'Completed';

      case 'cancelled':
        return 'Cancelled';

      default:
        return status;
    }
  }

  

  // UPDATE ASSIGNMENT STATUS THROUGH BACKEND

  Future<void> _updateStatus(String status) async {
    if (_assignment == null || _isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await _assignmentService.updateAssignment(
        int.parse(widget.assignmentId),
        {
          'status': status,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Assignment status updated successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      await _loadDetails();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update status: $e'),
        ),
      );
    }
  }

  // STATUS UPDATE DIALOG

  void _showStatusDialog() {
  final currentStatus =
      _assignment?['status']?.toString() ?? 'pending';

  const statuses = [
    {'value': 'pending', 'label': 'Pending'},
    {'value': 'in_progress', 'label': 'In Progress'},
    {'value': 'completed', 'label': 'Completed'},
    {'value': 'cancelled', 'label': 'Cancelled'},
  ];

  showDialog(
    context: context,
    builder: (dialogContext) {
      return SimpleDialog(
        title: const Text('Update Assignment Status'),
        children: statuses.map((item) {
          final isSelected = item['value'] == currentStatus;

          return SimpleDialogOption(
            onPressed: () {
              Navigator.pop(dialogContext);

              if (!isSelected) {
                _updateStatus(item['value']!);
              }
            },
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? blue : Colors.grey,
                ),
                const SizedBox(width: 12),
                Text(item['label']!),
              ],
            ),
          );
        }).toList(),
      );
    },
  );
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
          'Assignment Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? _buildError()
              : _assignment == null ||
                      _worker == null ||
                      _household == null
                  ? _buildError()
                  : RefreshIndicator(
                      onRefresh: _loadDetails,
                      child: _buildContent(),
                    ),
    );
  }

  // ERROR SCREEN

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.red,
            ),
            const SizedBox(height: 15),
            const Text(
              'Unable to load assignment details',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Assignment not found.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _loadDetails,
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
    final assignment = _assignment!;
    final worker = _worker!;
    final household = _household!;

    final status =
        assignment['status']?.toString() ?? 'pending';

    final statusLabel = _formatStatus(status);

    final dueDate = DateTime.tryParse(
      assignment['due_date']?.toString() ?? '',
    );

    final isOverdue =
        dueDate != null &&
        status != 'completed' &&
        status != 'cancelled' &&
        dueDate.isBefore(DateTime.now());

    final filteredMembers = _members.where((member) {
      if (selectedFilter == 'All') return true;

      return member['gender']?.toString().toLowerCase() ==
          selectedFilter.toLowerCase();
    }).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(18),
      children: [
        _buildAssignmentHeader(
          assignment,
          household,
          statusLabel,
          isOverdue,
        ),

        const SizedBox(height: 22),

        _sectionTitle('Assigned Health Worker'),

        const SizedBox(height: 12),

        _buildWorkerCard(worker),

        const SizedBox(height: 22),

        _sectionTitle('Assignment Schedule'),

        const SizedBox(height: 12),

        _buildScheduleCard(assignment),

        const SizedBox(height: 22),

        _sectionTitle('Household Overview'),

        const SizedBox(height: 12),

        _buildHouseholdSummary(household),

        const SizedBox(height: 22),

        _sectionTitle('Family Members'),

        const SizedBox(height: 12),

        _buildMemberSummary(),

        const SizedBox(height: 12),

        _buildMemberFilters(),

        const SizedBox(height: 12),

        if (filteredMembers.isEmpty)
          _emptyMembers()
        else
          ...filteredMembers.map(_buildMemberCard),

        const SizedBox(height: 22),

        _buildStatusAction(status),

        const SizedBox(height: 20),

        _buildDisclaimer(),

        const SizedBox(height: 25),
      ],
    );
  }

  // ASSIGNMENT HEADER

  Widget _buildAssignmentHeader(
    Map<String, dynamic> assignment,
    Map<String, dynamic> household,
    String status,
    bool overdue,
  ) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: blue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ASSIGNMENT ID',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            '#${assignment['id']}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  household['area']?.toString() ?? '-',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            children: [
              _headerBadge(status),
              if (overdue) _headerBadge('Overdue'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  // WORKER CARD

  Widget _buildWorkerCard(
    Map<String, dynamic> worker,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFFE8F0FF),
            child: Icon(
              Icons.person_outline,
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
                  worker['full_name']?.toString() ??
                      'Unknown Worker',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Employee ID: ${worker['employee_id'] ?? '-'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Worker Code: ${worker['employee_code'] ?? '-'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Area: ${worker['area'] ?? '-'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Mobile: ${worker['mobile_number'] ?? '-'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SCHEDULE CARD

  Widget _buildScheduleCard(
    Map<String, dynamic> assignment,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoRow(
            Icons.calendar_today_outlined,
            'Assignment date',
            _formatDate(assignment['assignment_date']),
          ),

          const Divider(height: 22),

          _infoRow(
            Icons.event_outlined,
            'Due date',
            _formatDate(assignment['due_date']),
          ),

          const Divider(height: 22),

          _infoRow(
            Icons.person_outline,
            'Assigned by User ID',
            assignment['assigned_by']?.toString() ?? '-',
          ),

          const Divider(height: 22),

          _infoRow(
            Icons.info_outline,
            'Current status',
            _formatStatus(
              assignment['status']?.toString() ?? 'pending',
            ),
          ),

          if (assignment['remarks'] != null &&
              assignment['remarks'].toString().isNotEmpty) ...[
            const Divider(height: 22),
            _infoRow(
              Icons.notes_outlined,
              'Remarks',
              assignment['remarks'].toString(),
            ),
          ],
        ],
      ),
    );
  }

  // HOUSEHOLD SUMMARY

  Widget _buildHouseholdSummary(
    Map<String, dynamic> household,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoRow(
            Icons.home_work_outlined,
            'Household code',
            household['household_code']?.toString() ?? '-',
          ),

          const Divider(height: 22),

          _infoRow(
            Icons.person_outline,
            'Head of family',
            household['head_of_family']?.toString() ?? '-',
          ),

          const Divider(height: 22),

          _infoRow(
            Icons.location_on_outlined,
            'Area',
            household['area']?.toString() ?? '-',
          ),

          const Divider(height: 22),

          _infoRow(
            Icons.home_outlined,
            'Address',
            household['address']?.toString() ?? '-',
          ),

          const Divider(height: 22),

          _infoRow(
            Icons.pin_drop_outlined,
            'Pincode',
            household['pincode']?.toString() ?? '-',
          ),
        ],
      ),
    );
  }

  // MEMBER SUMMARY

  Widget _buildMemberSummary() {
    final maleCount = _members.where(
      (member) => member['gender'] == 'Male',
    ).length;

    final femaleCount = _members.where(
      (member) => member['gender'] == 'Female',
    ).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              'Total Members',
              _members.length,
              blue,
            ),
          ),

          Expanded(
            child: _summaryItem(
              'Male',
              maleCount,
              const Color(0xFF2563EB),
            ),
          ),

          Expanded(
            child: _summaryItem(
              'Female',
              femaleCount,
              const Color(0xFFDB2777),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(
    String title,
    int value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // MEMBER FILTERS

  Widget _buildMemberFilters() {
    final filters = ['All', 'Male', 'Female'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
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
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // MEMBER CARD

  Widget _buildMemberCard(
    Map<String, dynamic> member,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE8F0FF),
            child: Icon(
              Icons.person_outline,
              color: blue,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['full_name']?.toString() ??
                      'Unknown Member',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: navy,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Individual ID: ${member['individual_code'] ?? '-'}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Gender: ${member['gender'] ?? '-'}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Date of birth: ${_formatDate(member['date_of_birth'])}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Mobile: ${member['mobile_number'] ?? '-'}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            member['is_active'] == true
                ? Icons.check_circle
                : Icons.cancel,
            color: member['is_active'] == true
                ? Colors.green
                : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _emptyMembers() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 40,
            color: Colors.grey,
          ),

          SizedBox(height: 10),

          Text(
            'No family members found',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'No registered individuals were found for this household.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // STATUS ACTION

  Widget _buildStatusAction(String status) {
    final canUpdate =
        status != 'completed' &&
        status != 'cancelled';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canUpdate && !_isUpdating
            ? _showStatusDialog
            : null,
        icon: const Icon(Icons.edit_outlined),
        label: Text(
          _isUpdating
              ? 'Updating...'
              : canUpdate
                  ? 'Update Assignment Status'
                  : 'Assignment ${_formatStatus(status)}',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // DISCLAIMER

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF5D99B),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFFB7791F),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Family member information is loaded from registered '
              'individual records. Medical screening progress and '
              'results are not yet available in this assignment view.',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF805B20),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SECTION TITLE

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: navy,
      ),
    );
  }

  // COMMON INFORMATION ROW

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
        ),
      ],
    );
  }

  // CARD DECORATION

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFFE8EDF5),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}