import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class WorkerVisitsScreen extends StatefulWidget {
  const WorkerVisitsScreen({super.key});

  @override
  State<WorkerVisitsScreen> createState() =>
      _WorkerVisitsScreenState();
}

class _WorkerVisitsScreenState extends State<WorkerVisitsScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color teal = Color(0xFF0D998D);
  static const Color muted = Color(0xFF718096);
  static const Color background = Color(0xFFF3F7FC);

  int selectedFilter = 0;

  final List<Map<String, dynamic>> visits = [
    {
      'id': 'VIS-001',
      'name': 'Ravi Kumar',
      'household': 'CBE-18-042',
      'address': 'Ukkadam North',
      'time': '09:30 AM',
      'date': 'Today',
      'type': 'Initial Screening',
      'status': 'Pending',
      'priority': 'High',
      'members': 3,
    },
    {
      'id': 'VIS-002',
      'name': 'Selvi R.',
      'household': 'CBE-18-058',
      'address': 'Ukkadam North',
      'time': '11:00 AM',
      'date': 'Today',
      'type': 'Initial Screening',
      'status': 'Pending',
      'priority': 'Normal',
      'members': 3,
    },
    {
      'id': 'VIS-003',
      'name': 'Mohan Das',
      'household': 'CBE-18-061',
      'address': 'Ukkadam North',
      'time': '02:30 PM',
      'date': 'Today',
      'type': 'Follow-up',
      'status': 'In Progress',
      'priority': 'Normal',
      'members': 2,
    },
    {
      'id': 'VIS-004',
      'name': 'Lakshmi',
      'household': 'CBE-18-075',
      'address': 'Ukkadam North',
      'time': 'Yesterday',
      'date': 'Yesterday',
      'type': 'Initial Screening',
      'status': 'Completed',
      'priority': 'Normal',
      'members': 4,
    },
    {
      'id': 'VIS-005',
      'name': 'Arun Kumar',
      'household': 'CBE-18-082',
      'address': 'Ukkadam North',
      'time': '10:00 AM',
      'date': 'Tomorrow',
      'type': 'Follow-up',
      'status': 'Pending',
      'priority': 'High',
      'members': 2,
    },
  ];

  List<Map<String, dynamic>> get filteredVisits {
    if (selectedFilter == 1) {
      return visits
          .where((v) => v['status'] == 'Pending')
          .toList();
    }

    if (selectedFilter == 2) {
      return visits
          .where((v) => v['status'] == 'In Progress')
          .toList();
    }

    if (selectedFilter == 3) {
      return visits
          .where((v) => v['status'] == 'Completed')
          .toList();
    }

    return visits;
  }

  @override
  Widget build(BuildContext context) {
    final todayVisits =
        visits.where((v) => v['date'] == 'Today').toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        title: const Text(
          'My Visits',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(17),
          children: [
            _buildWelcomeCard(),

            const SizedBox(height: 20),

            _buildStatistics(todayVisits),

            const SizedBox(height: 25),

            const Text(
              "Today's Schedule",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),

            const SizedBox(height: 12),

            _buildTodaySchedule(todayVisits),

            const SizedBox(height: 25),

            const Text(
              'All Visits',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),

            const SizedBox(height: 13),

            _buildFilters(),

            const SizedBox(height: 15),

            if (filteredVisits.isEmpty)
              _buildEmptyState()
            else
              ...filteredVisits.map(_visitCard),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  // WELCOME CARD

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FIELD VISIT MANAGEMENT',
                  style: TextStyle(
                    color: Color(0xFF67D7C5),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Manage your home visits',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Track scheduled, ongoing and completed visits.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Icon(
            Icons.location_on_outlined,
            color: Colors.white,
            size: 45,
          ),
        ],
      ),
    );
  }

  // STATISTICS

  Widget _buildStatistics(List<Map<String, dynamic>> todayVisits) {
    final pending = todayVisits
        .where((v) => v['status'] == 'Pending')
        .length;

    final completed = todayVisits
        .where((v) => v['status'] == 'Completed')
        .length;

    final inProgress = todayVisits
        .where((v) => v['status'] == 'In Progress')
        .length;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            'TODAY',
            todayVisits.length.toString(),
            Icons.calendar_today_outlined,
            blue,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _statCard(
            'PENDING',
            pending.toString(),
            Icons.schedule,
            const Color(0xFFD99000),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _statCard(
            'ONGOING',
            inProgress.toString(),
            Icons.directions_walk,
            teal,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _statCard(
            'DONE',
            completed.toString(),
            Icons.check_circle_outline,
            const Color(0xFF16A36B),
          ),
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
      padding: const EdgeInsets.symmetric(
        vertical: 13,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE4EAF2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: navy,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }

  // TODAY'S SCHEDULE

  Widget _buildTodaySchedule(
    List<Map<String, dynamic>> todayVisits,
  ) {
    if (todayVisits.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE4EAF2),
        ),
      ),
      child: Column(
        children: todayVisits.map((visit) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Row(
              children: [
                Container(
                  width: 65,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    visit['time'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: blue,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit['name'],
                        style: const TextStyle(
                          color: navy,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        visit['household'],
                        style: const TextStyle(
                          color: muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(visit['status']),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // FILTERS

  Widget _buildFilters() {
    const filters = [
      'All',
      'Pending',
      'Ongoing',
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
                setState(() => selectedFilter = index);
              },
              selectedColor: navy,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected ? Colors.white : muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
              side: BorderSide(
                color: selected
                    ? navy
                    : const Color(0xFFE2E8F0),
              ),
            ),
          );
        }),
      ),
    );
  }

  // VISIT CARD

  Widget _visitCard(Map<String, dynamic> visit) {
    final isHighPriority = visit['priority'] == 'High';

    return InkWell(
      onTap: () => _showVisitDetails(visit),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE4EAF2),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FF),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    color: blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit['name'],
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        visit['household'],
                        style: const TextStyle(
                          color: muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                _statusBadge(visit['status']),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 15,
                  color: muted,
                ),
                const SizedBox(width: 6),
                Text(
                  '${visit['date']} · ${visit['time']}',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                if (isHighPriority)
                  const Text(
                    'HIGH PRIORITY',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 15,
                  color: muted,
                ),
                const SizedBox(width: 6),
                Text(
                  '${visit['members']} members',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                Text(
                  visit['type'],
                  style: const TextStyle(
                    color: blue,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showVisitDetails(visit),
                child: const Text('View Visit Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STATUS BADGE

  Widget _statusBadge(String status) {
    Color color;
    Color backgroundColor;

    switch (status) {
      case 'Completed':
        color = const Color(0xFF15945B);
        backgroundColor = const Color(0xFFEAF8EF);
        break;
      case 'In Progress':
        color = blue;
        backgroundColor = const Color(0xFFEAF2FF);
        break;
      default:
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
        status,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // VISIT DETAILS

  void _showVisitDetails(Map<String, dynamic> visit) {
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
        return Padding(
          padding: const EdgeInsets.all(22),
          child: SafeArea(
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
                  'Visit Details',
                  style: TextStyle(
                    fontSize: 19,
                    color: navy,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 18),

                _detailRow('Visit ID', visit['id']),
                _detailRow('Individual', visit['name']),
                _detailRow('Household', visit['household']),
                _detailRow('Area', visit['address']),
                _detailRow('Date', visit['date']),
                _detailRow('Time', visit['time']),
                _detailRow('Visit Type', visit['type']),
                _detailRow('Members', '${visit['members']}'),
                _detailRow('Status', visit['status']),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);

                      context.push('/worker-households');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Open Assigned Households'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            color: muted,
            size: 40,
          ),
          SizedBox(height: 12),
          Text(
            'No visits found',
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Your visits will appear here.',
            style: TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}