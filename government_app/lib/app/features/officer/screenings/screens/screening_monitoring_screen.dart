import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../data/screening_service.dart';

class ScreeningMonitoringScreen extends StatefulWidget {
  const ScreeningMonitoringScreen({super.key});

  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F7FC);

  @override
  State<ScreeningMonitoringScreen> createState() =>
      _ScreeningMonitoringScreenState();
}

class _ScreeningMonitoringScreenState
    extends State<ScreeningMonitoringScreen> {
  final ScreeningService _service = ScreeningService();

  List<Map<String, dynamic>> _screenings = [];
  Map<int, Map<String, dynamic>> _individuals = {};

  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadScreenings();
  }

  Future<void> _loadScreenings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final screenings = await _service.fetchScreenings();

      final ids = screenings
          .map((s) => int.tryParse(s['individual_id']?.toString() ?? ''))
          .whereType<int>()
          .toSet();

      final results = await Future.wait(
        ids.map((id) async {
          try {
            return MapEntry(
              id,
              await _service.fetchIndividual(id),
            );
          } catch (_) {
            return MapEntry(id, <String, dynamic>{});
          }
        }),
      );

      if (!mounted) return;

      setState(() {
        _screenings = screenings;
        _individuals = Map.fromEntries(results);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  String _status(Map<String, dynamic> screening) {
    return (screening['status'] ?? 'unknown')
        .toString()
        .toLowerCase()
        .replaceAll('_', ' ');
  }

  String _individualName(Map<String, dynamic> screening) {
    final id = int.tryParse(
      screening['individual_id']?.toString() ?? '',
    );

    final person = id == null ? null : _individuals[id];

    if (person == null || person.isEmpty) {
      return 'Individual #${id ?? '-'}';
    }

    final first = (person['first_name'] ?? '').toString();
    final last = (person['last_name'] ?? '').toString();
    final name = '$first $last'.trim();

    return name.isEmpty ? 'Individual #$id' : name;
  }

  List<Map<String, dynamic>> get _filteredScreenings {
    return _screenings.where((screening) {
      final name = _individualName(screening).toLowerCase();
      final id = (screening['individual_id'] ?? '')
          .toString()
          .toLowerCase();

      final matchesSearch = name.contains(_searchQuery) ||
          id.contains(_searchQuery);

      final status = _status(screening);

      final matchesFilter = _selectedFilter == 'All' ||
          status == _selectedFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int _count(String status) {
    return _screenings.where((s) {
      return _status(s) == status;
    }).length;
  }

  void _openDetails(Map<String, dynamic> screening) {
    final id = int.tryParse(screening['id']?.toString() ?? '');

    if (id == null) return;

    context.push(
      '/screening-details/$id',
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF15803D);
      case 'in progress':
        return const Color(0xFF2563EB);
      case 'pending':
        return const Color(0xFFB76A00);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _statCard(
    String title,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5EBF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: color.withValues(alpha: 0.10),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 13),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: ScreeningMonitoringScreen.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF718096),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _screeningCard(Map<String, dynamic> screening) {
    final status = _status(screening);
    final color = _statusColor(status);
    final individualId = screening['individual_id']?.toString() ?? '-';
    final workerId = screening['worker_id']?.toString() ?? '-';
    final date = screening['screening_date']?.toString() ?? '-';
    final type = screening['screening_type']?.toString() ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5EBF3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _openDetails(screening),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFE0ECFA),
                      child: Icon(
                        Icons.health_and_safety_outlined,
                        color: ScreeningMonitoringScreen.navy,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _individualName(screening),
                            style: const TextStyle(
                              color: ScreeningMonitoringScreen.navy,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Individual ID: $individualId',
                            style: const TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: ScreeningMonitoringScreen.navy,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _infoChip(Icons.category_outlined, type),
                    _infoChip(Icons.person_outline, 'Worker $workerId'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        date.length >= 10 ? date.substring(0, 10) : date,
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
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

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: ScreeningMonitoringScreen.blue),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: ScreeningMonitoringScreen.navy,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredScreenings;

    return Scaffold(
      backgroundColor: ScreeningMonitoringScreen.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: ScreeningMonitoringScreen.navy,
        elevation: 0,
        title: const Text(
          'Screening Monitoring',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          size: 45,
                          color: Color(0xFF718096),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton.icon(
                          onPressed: _loadScreenings,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadScreenings,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'HEALTH PROGRAM OVERVIEW',
                        style: TextStyle(
                          color: ScreeningMonitoringScreen.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Screening Records',
                        style: TextStyle(
                          color: ScreeningMonitoringScreen.navy,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Monitor community health screening progress.',
                        style: TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // STATISTICS
                      SizedBox(
                        height: 115,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _statCard(
                              'Total Screenings',
                              _screenings.length,
                              Icons.assignment_outlined,
                              const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              'In Progress',
                              _count('in progress'),
                              Icons.pending_actions,
                              const Color(0xFFB76A00),
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              'Completed',
                              _count('completed'),
                              Icons.check_circle_outline,
                              const Color(0xFF15803D),
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              'Cancelled',
                              _count('cancelled'),
                              Icons.cancel_outlined,
                              const Color(0xFFDC2626),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // SEARCH
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.trim().toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search individual name or ID',
                          prefixIcon: const Icon(Icons.search),
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
                            'In progress',
                            'Completed',
                            'Pending',
                            'Cancelled',
                          ].map((filter) {
                            final selected = _selectedFilter == filter;

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(filter),
                                selected: selected,
                                selectedColor:
                                    ScreeningMonitoringScreen.navy,
                                backgroundColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : ScreeningMonitoringScreen.navy,
                                  fontSize: 10,
                                ),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SCREENING RECORDS',
                            style: TextStyle(
                              color: ScreeningMonitoringScreen.navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${filtered.length} records',
                            style: const TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(30),
                          child: Center(
                            child: Text(
                              'No screening records found.',
                              style: TextStyle(
                                color: ScreeningMonitoringScreen.navy,
                              ),
                            ),
                          ),
                        ),

                      ...filtered.map(_screeningCard),
                    ],
                  ),
                ),
    );
  }
}