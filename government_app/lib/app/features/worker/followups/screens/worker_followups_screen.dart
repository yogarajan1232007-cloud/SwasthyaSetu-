import 'package:material_ui/material_ui.dart';

class WorkerFollowUpsScreen extends StatefulWidget {
  const WorkerFollowUpsScreen({super.key});

  @override
  State<WorkerFollowUpsScreen> createState() =>
      _WorkerFollowUpsScreenState();
}

class _WorkerFollowUpsScreenState
    extends State<WorkerFollowUpsScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color teal = Color(0xFF0D998D);
  static const Color muted = Color(0xFF718096);
  static const Color background = Color(0xFFF3F7FC);

  int selectedFilter = 0;

  final List<Map<String, dynamic>> followUps = [
    {
      'id': 'FU-001',
      'name': 'Ravi Kumar',
      'household': 'CBE-18-042',
      'age': 52,
      'gender': 'Male',
      'area': 'Ukkadam North',
      'date': DateTime.now(),
      'reason': 'Blood pressure recheck',
      'description':
          'A healthcare professional requested a follow-up blood pressure measurement.',
      'priority': 'High',
      'status': 'Pending',
      'lastVisit': '10 Nov 2026',
      'notes': '',
    },
    {
      'id': 'FU-002',
      'name': 'Selvi R.',
      'household': 'CBE-18-058',
      'age': 46,
      'gender': 'Female',
      'area': 'Ukkadam North',
      'date': DateTime.now(),
      'reason': 'Diabetes screening follow-up',
      'description':
          'Follow-up visit requested for healthcare professional review of screening results.',
      'priority': 'Medium',
      'status': 'Pending',
      'lastVisit': '11 Nov 2026',
      'notes': '',
    },
    {
      'id': 'FU-003',
      'name': 'Mohan Das',
      'household': 'CBE-18-061',
      'age': 61,
      'gender': 'Male',
      'area': 'Ukkadam North',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'reason': 'Cardiovascular review',
      'description':
          'Follow-up for review of cardiovascular screening measurements.',
      'priority': 'High',
      'status': 'Pending',
      'lastVisit': '09 Nov 2026',
      'notes': '',
    },
    {
      'id': 'FU-004',
      'name': 'Lakshmi',
      'household': 'CBE-18-075',
      'age': 55,
      'gender': 'Female',
      'area': 'Ukkadam North',
      'date': DateTime.now().add(const Duration(days: 2)),
      'reason': 'Routine follow-up',
      'description':
          'Scheduled follow-up according to the screening programme.',
      'priority': 'Low',
      'status': 'Pending',
      'lastVisit': '12 Nov 2026',
      'notes': '',
    },
    {
      'id': 'FU-005',
      'name': 'Arun Kumar',
      'household': 'CBE-18-082',
      'age': 48,
      'gender': 'Male',
      'area': 'Ukkadam North',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'reason': 'Pending clinical review',
      'description':
          'Follow-up is awaiting review by an authorised healthcare professional.',
      'priority': 'Medium',
      'status': 'Completed',
      'lastVisit': '08 Nov 2026',
      'notes': 'Follow-up visit recorded in this demo.',
    },
  ];

  List<Map<String, dynamic>> get filteredFollowUps {
    final now = DateTime.now();

    switch (selectedFilter) {
      case 1:
        return followUps
            .where((item) => item['status'] == 'Pending')
            .toList();

      case 2:
        return followUps.where((item) {
          final date = item['date'] as DateTime;
          return item['status'] == 'Pending' &&
              _isSameDay(date, now);
        }).toList();

      case 3:
        return followUps.where((item) {
          final date = item['date'] as DateTime;
          return item['status'] == 'Pending' &&
              _dateOnly(date).isBefore(_dateOnly(now));
        }).toList();

      case 4:
        return followUps
            .where((item) => item['status'] == 'Completed')
            .toList();

      default:
        return followUps;
    }
  }

  int get pendingCount =>
      followUps.where((e) => e['status'] == 'Pending').length;

  int get completedCount =>
      followUps.where((e) => e['status'] == 'Completed').length;

  int get dueTodayCount => followUps.where((e) {
        return e['status'] == 'Pending' &&
            _isSameDay(e['date'] as DateTime, DateTime.now());
      }).length;

  int get overdueCount => followUps.where((e) {
        return e['status'] == 'Pending' &&
            _dateOnly(e['date'] as DateTime)
                .isBefore(_dateOnly(DateTime.now()));
      }).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Follow-ups',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.all(17),
            children: [
              _buildWelcomeCard(),

              const SizedBox(height: 22),

              const Text(
                'Follow-up Overview',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),

              const SizedBox(height: 13),

              _buildStatistics(),

              const SizedBox(height: 25),

              _buildPriorityBanner(),

              const SizedBox(height: 25),

              const Text(
                'Follow-up Records',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),

              const SizedBox(height: 13),

              _buildFilters(),

              const SizedBox(height: 15),

              if (filteredFollowUps.isEmpty)
                _buildEmptyState()
              else
                ...filteredFollowUps.map(_followUpCard),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // WELCOME CARD
  // =====================================================

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COMMUNITY HEALTH PROGRAMME',
                  style: TextStyle(
                    color: Color(0xFF67D7C5),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Follow-up Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Keep track of scheduled follow-up visits and updates.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.event_repeat_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // STATISTICS
  // =====================================================

  Widget _buildStatistics() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.1,
      children: [
        _statCard(
          'TOTAL FOLLOW-UPS',
          followUps.length.toString(),
          Icons.assignment_outlined,
          blue,
          const Color(0xFFEAF2FF),
        ),
        _statCard(
          'PENDING',
          pendingCount.toString(),
          Icons.schedule,
          const Color(0xFFD18A00),
          const Color(0xFFFFF6E5),
        ),
        _statCard(
          'DUE TODAY',
          dueTodayCount.toString(),
          Icons.today_outlined,
          teal,
          const Color(0xFFE5F6F2),
        ),
        _statCard(
          'COMPLETED',
          completedCount.toString(),
          Icons.check_circle_outline,
          const Color(0xFF15945B),
          const Color(0xFFEAF8EF),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color iconBackground,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE4EAF2),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // PRIORITY BANNER
  // =====================================================

  Widget _buildPriorityBanner() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5EB),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFFFE0C2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.priority_high_rounded,
            color: Color(0xFFD97706),
            size: 25,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overdue Follow-ups',
                  style: TextStyle(
                    color: navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$overdueCount follow-up(s) are past their scheduled date.',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // FILTERS
  // =====================================================

  Widget _buildFilters() {
    const filters = [
      'All',
      'Pending',
      'Due Today',
      'Overdue',
      'Completed',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = selectedFilter == index;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  selectedFilter = index;
                });
              },
              selectedColor: navy,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected
                    ? navy
                    : const Color(0xFFE2E8F0),
              ),
              labelStyle: TextStyle(
                color: selected ? Colors.white : muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }),
      ),
    );
  }

  // =====================================================
  // FOLLOW-UP CARD
  // =====================================================

  Widget _followUpCard(Map<String, dynamic> item) {
    final date = item['date'] as DateTime;
    final status = item['status'] as String;
    final priority = item['priority'] as String;

    final isOverdue = status == 'Pending' &&
        _dateOnly(date).isBefore(_dateOnly(DateTime.now()));

    return InkWell(
      onTap: () => _showFollowUpDetails(item),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFE4EAF2),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
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
                        item['name'],
                        style: const TextStyle(
                          color: navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['household'],
                        style: const TextStyle(
                          color: muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(status, isOverdue),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: muted,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _formatDate(date),
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                    ),
                  ),
                ),
                _priorityBadge(priority),
              ],
            ),

            const SizedBox(height: 11),

            Row(
              children: [
                const Icon(
                  Icons.medical_information_outlined,
                  color: muted,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item['reason'],
                    style: const TextStyle(
                      color: navy,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: muted,
                ),
              ],
            ),

            if (status == 'Pending') ...[
              const SizedBox(height: 13),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showFollowUpDetails(item),
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('View Follow-up Details'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =====================================================
  // STATUS BADGE
  // =====================================================

  Widget _statusBadge(String status, bool isOverdue) {
    final label = isOverdue ? 'Overdue' : status;

    Color color;
    Color backgroundColor;

    if (status == 'Completed') {
      color = const Color(0xFF15945B);
      backgroundColor = const Color(0xFFEAF8EF);
    } else if (isOverdue) {
      color = Colors.redAccent;
      backgroundColor = const Color(0xFFFFEEEE);
    } else {
      color = const Color(0xFFD18A00);
      backgroundColor = const Color(0xFFFFF6E5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _priorityBadge(String priority) {
    final Color color;

    switch (priority) {
      case 'High':
        color = Colors.redAccent;
        break;
      case 'Medium':
        color = const Color(0xFFD18A00);
        break;
      default:
        color = teal;
    }

    return Text(
      '$priority Priority',
      style: TextStyle(
        color: color,
        fontSize: 9,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  // =====================================================
  // =====================================================
  // FOLLOW-UP DETAILS
  // =====================================================

  void _showFollowUpDetails(Map<String, dynamic> item) {
    String completionNotes = item['notes']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final status = item['status'] as String;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                20,
                22,
                20 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          height: 4,
                          width: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD7DEE8),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Follow-up Details',
                        style: TextStyle(
                          color: navy,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _detailRow('Follow-up ID', item['id'].toString()),
                      _detailRow('Individual', item['name'].toString()),
                      _detailRow('Household', item['household'].toString()),
                      _detailRow('Age', '${item['age']} years'),
                      _detailRow('Gender', item['gender'].toString()),
                      _detailRow('Area', item['area'].toString()),
                      _detailRow(
                        'Scheduled Date',
                        _formatDate(item['date'] as DateTime),
                      ),
                      _detailRow('Last Visit', item['lastVisit'].toString()),
                      _detailRow('Reason', item['reason'].toString()),
                      _detailRow('Priority', item['priority'].toString()),
                      _detailRow('Status', status),
                      const SizedBox(height: 15),
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['description'].toString(),
                        style: const TextStyle(
                          color: muted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Follow-up Notes',
                        style: TextStyle(
                          color: navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: ValueKey('follow-up-notes-${item['id']}'),
                        initialValue: completionNotes,
                        maxLines: 3,
                        onChanged: (value) {
                          completionNotes = value;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter follow-up notes...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (status == 'Pending')
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (completionNotes.trim().isEmpty) {
                                ScaffoldMessenger.of(sheetContext).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter follow-up notes first.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                item['status'] = 'Completed';
                                item['notes'] = completionNotes.trim();
                                item['completedAt'] = DateTime.now();
                              });

                              Navigator.pop(sheetContext);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Demo follow-up marked as completed.',
                                  ),
                                  backgroundColor: teal,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text(
                              'Mark Follow-up Completed',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF8EF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'This follow-up has been completed.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF15945B),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // EMPTY STATE
  // =====================================================

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            color: muted,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'No Follow-ups Found',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'There are no records under this filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // DATE HELPERS
  // =====================================================

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}