import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/analytics_charts.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ApiClient _apiClient = ApiClient();

  String selectedPeriod = 'This quarter';
  String selectedArea = 'All areas';
  String selectedWorker = 'All workers';

  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic> _dashboard = {};
  List<Map<String, dynamic>> _screenings = [];
  List<Map<String, dynamic>> _workers = [];
  List<Map<String, dynamic>> _referrals = [];

  static const List<String> _periods = [
    'This month',
    'This quarter',
    'This year',
    'All time',
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final responses = await Future.wait([
        _apiClient.get('/dashboard/government'),
        _apiClient.get('/screenings/', queryParameters: {'skip': 0, 'limit': 500}),
        _apiClient.get('/workers/', queryParameters: {'skip': 0, 'limit': 100}),
        _apiClient.get('/referrals/', queryParameters: {'skip': 0, 'limit': 500}),
      ]);

      final dashboardData = responses[0].data;
      if (dashboardData is! Map) {
        throw Exception('Invalid dashboard analytics response.');
      }

      List<Map<String, dynamic>> parseList(dynamic data, String label) {
        if (data is! List) {
          throw Exception('Invalid $label response from server.');
        }
        return data
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      if (!mounted) return;
      setState(() {
        _dashboard = Map<String, dynamic>.from(dashboardData);
        _screenings = parseList(responses[1].data, 'screenings');
        _workers = parseList(responses[2].data, 'workers');
        _referrals = parseList(responses[3].data, 'referrals');
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  int _number(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

  DateTime? _date(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  bool _inSelectedPeriod(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    switch (selectedPeriod) {
      case 'This month':
        return date.year == now.year && date.month == now.month;
      case 'This quarter':
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        return date.year == now.year &&
            date.month >= quarterStartMonth &&
            date.month < quarterStartMonth + 3;
      case 'This year':
        return date.year == now.year;
      default:
        return true;
    }
  }

  Map<int, Map<String, dynamic>> get _workersById {
    return {
      for (final worker in _workers)
        if (worker['id'] != null) _number(worker['id']): worker,
    };
  }

  List<String> get _areas {
    final values = _workers
        .map((worker) => worker['area']?.toString().trim() ?? '')
        .where((area) => area.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All areas', ...values];
  }

  List<String> get _workerNames {
    final values = _workers
        .where((worker) => worker['is_active'] != false)
        .map((worker) => worker['full_name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All workers', ...values];
  }

  List<Map<String, dynamic>> get _filteredScreenings {
    return _screenings.where((screening) {
      final date = _date(screening['screening_date'] ?? screening['created_at']);
      final workerId = _number(screening['worker_id']);
      final worker = _workersById[workerId];
      final area = worker?['area']?.toString() ?? '';
      final workerName = worker?['full_name']?.toString() ?? '';

      final periodMatches = _inSelectedPeriod(date);
      final areaMatches =
          selectedArea == 'All areas' || area == selectedArea;
      final workerMatches =
          selectedWorker == 'All workers' || workerName == selectedWorker;

      return periodMatches && areaMatches && workerMatches;
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredReferrals {
    return _referrals.where((referral) {
      final date = _date(referral['referred_at'] ?? referral['created_at']);
      return _inSelectedPeriod(date);
    }).toList();
  }

  int get _completedScreenings => _filteredScreenings
      .where((item) => item['status']?.toString().toLowerCase() == 'completed')
      .length;

  int get _inProgressScreenings => _filteredScreenings
      .where((item) => item['status']?.toString().toLowerCase() == 'in_progress')
      .length;

  int get _completedReferrals => _filteredReferrals
      .where((item) => item['status']?.toString().toLowerCase() == 'completed')
      .length;

  int get _pendingReferrals => _filteredReferrals
      .where((item) => item['status']?.toString().toLowerCase() == 'pending')
      .length;

  int get _scheduledReferrals => _filteredReferrals
      .where((item) => item['status']?.toString().toLowerCase() == 'scheduled')
      .length;

  int get _uniqueIndividualsInFilteredScreenings => _filteredScreenings
      .map((item) => item['individual_id']?.toString())
      .where((id) => id != null && id.isNotEmpty)
      .toSet()
      .length;

  double get _screeningCoverage {
    final population = _number(_dashboard['total_population']);
    if (population == 0) return 0;
    return (_uniqueIndividualsInFilteredScreenings / population * 100)
        .clamp(0, 100)
        .toDouble();
  }

  List<MapEntry<String, int>> get _monthlyCounts {
    final counts = <String, int>{};
    for (final screening in _filteredScreenings) {
      final date = _date(screening['screening_date'] ?? screening['created_at']);
      if (date == null) continue;
      final key = '${_monthName(date.month)} ${date.year}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final entries = counts.entries.toList();
    entries.sort((a, b) {
      final aDate = _parseMonthKey(a.key);
      final bDate = _parseMonthKey(b.key);
      return aDate.compareTo(bDate);
    });
    return entries;
  }

  DateTime _parseMonthKey(String key) {
    final parts = key.split(' ');
    final month = _monthNumber(parts.first);
    final year = int.tryParse(parts.last) ?? 2000;
    return DateTime(year, month);
  }

  int _monthNumber(String month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months.indexOf(month) + 1;
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month - 1];
  }

  Map<String, int> get _screeningsByArea {
    final result = <String, int>{};
    for (final screening in _filteredScreenings) {
      final worker = _workersById[_number(screening['worker_id'])];
      final area = worker?['area']?.toString();
      if (area == null || area.trim().isEmpty) continue;
      result[area] = (result[area] ?? 0) + 1;
    }
    return result;
  }

  Map<String, Map<String, int>> get _workerPerformance {
    final result = <String, Map<String, int>>{};
    for (final screening in _filteredScreenings) {
      final worker = _workersById[_number(screening['worker_id'])];
      final name = worker?['full_name']?.toString() ?? 'Worker ID ${screening['worker_id']}';
      result.putIfAbsent(name, () => {'total': 0, 'completed': 0});
      result[name]!['total'] = result[name]!['total']! + 1;
      if (screening['status']?.toString().toLowerCase() == 'completed') {
        result[name]!['completed'] = result[name]!['completed']! + 1;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorState()
                      : RefreshIndicator(
                          onRefresh: _loadReports,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTitle(),
                                const SizedBox(height: 20),
                                _buildFilters(),
                                const SizedBox(height: 22),
                                _buildOverview(),
                                const SizedBox(height: 22),
                                _buildScreeningStatistics(),
                                const SizedBox(height: 22),
                                _buildVisualAnalytics(),
                                const SizedBox(height: 22),
                                _buildReferralAnalytics(),
                                const SizedBox(height: 18),
                                _buildDataNote(),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE7EDF5))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 19, color: AppColors.primary),
          ),
          const Spacer(),
          const Text(
            'Reports & Analytics',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PROGRAMME INTELLIGENCE',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Reports & analytics',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Updated ${_formatDate(_dashboard['generated_at'])}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic value) {
    final date = _date(value);
    if (date == null) return 'update time unavailable';
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(selectedPeriod, _periods,
              (value) => setState(() => selectedPeriod = value)),
          const SizedBox(width: 8),
          _filterChip(selectedArea, _areas,
              (value) => setState(() => selectedArea = value)),
          const SizedBox(width: 8),
          _filterChip(selectedWorker, _workerNames,
              (value) => setState(() => selectedWorker = value)),
        ],
      ),
    );
  }

  Widget _filterChip(
      String selected, List<String> options, ValueChanged<String> onSelected) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => options
          .map((option) => PopupMenuItem(value: option, child: Text(option)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFF15385F),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selected,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 5),
            const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading('POPULATION OVERVIEW', 'Registered population'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.9,
          children: [
            _AnalyticsCard(
              title: 'TOTAL POPULATION',
              value: '${_number(_dashboard['total_population'])}',
              subtitle: '${_number(_dashboard['active_population'])} active',
              icon: Icons.people_outline,
              iconColor: const Color(0xFF2563EB),
              background: const Color(0xFFEAF0FF),
            ),
            _AnalyticsCard(
              title: 'HOUSEHOLDS',
              value: '${_number(_dashboard['total_households'])}',
              subtitle: '${_number(_dashboard['assigned_households'])} assigned',
              icon: Icons.home_outlined,
              iconColor: const Color(0xFF0D9488),
              background: const Color(0xFFE4F7F5),
            ),
            _AnalyticsCard(
              title: 'HEALTH WORKERS',
              value: '${_number(_dashboard['total_workers'])}',
              subtitle: '${_number(_dashboard['available_workers'])} available',
              icon: Icons.groups_outlined,
              iconColor: const Color(0xFF7C3AED),
              background: const Color(0xFFF1EAFE),
            ),
            _AnalyticsCard(
              title: 'MALE / FEMALE',
              value: '${_number(_dashboard['male_population'])} / ${_number(_dashboard['female_population'])}',
              subtitle: 'Registered population',
              icon: Icons.people_alt_outlined,
              iconColor: const Color(0xFFD97706),
              background: const Color(0xFFFFF4DF),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScreeningStatistics() {
    final total = _filteredScreenings.length;
    final coverage = _screeningCoverage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading('SCREENING ANALYTICS', 'Screening performance'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.9,
          children: [
            _AnalyticsCard(
              title: 'SCREENING RECORDS',
              value: '$total',
              subtitle: 'In selected period and filters',
              icon: Icons.assignment_outlined,
              iconColor: const Color(0xFF2563EB),
              background: const Color(0xFFEAF0FF),
            ),
            _AnalyticsCard(
              title: 'UNIQUE PEOPLE SCREENED',
              value: '$_uniqueIndividualsInFilteredScreenings',
              subtitle: '${coverage.toStringAsFixed(1)}% of total population',
              icon: Icons.person_search_outlined,
              iconColor: const Color(0xFF0D9488),
              background: const Color(0xFFE4F7F5),
            ),
            _AnalyticsCard(
              title: 'COMPLETED',
              value: '$_completedScreenings',
              subtitle: 'Completed screening records',
              icon: Icons.check_circle_outline,
              iconColor: const Color(0xFF16A34A),
              background: const Color(0xFFE9F8EF),
            ),
            _AnalyticsCard(
              title: 'IN PROGRESS',
              value: '$_inProgressScreenings',
              subtitle: 'In-progress screening records',
              icon: Icons.pending_outlined,
              iconColor: const Color(0xFFD97706),
              background: const Color(0xFFFFF4DF),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _infoBanner(
          'Coverage is calculated as unique individuals with screening records '
          'divided by total registered population. It is not a clinical risk measure.',
        ),
        if (total == 0)
          _emptyMessage('No screening records match the selected filters.'),
      ],
    );
  }

  Widget _buildVisualAnalytics() {
    return AnalyticsCharts(
      malePopulation: _number(_dashboard['male_population']),
      femalePopulation: _number(_dashboard['female_population']),
      completedScreenings: _completedScreenings,
      inProgressScreenings: _inProgressScreenings,
      monthlyCounts: _monthlyCounts,
      areaCounts: _screeningsByArea,
      workerPerformance: _workerPerformance,
      pendingReferrals: _pendingReferrals,
      scheduledReferrals: _scheduledReferrals,
      completedReferrals: _completedReferrals,
    );
  }

 

  Widget _buildReferralAnalytics() {
    final total = _filteredReferrals.length;
    final completion = total == 0 ? 0.0 : _completedReferrals / total * 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading('REFERRAL ANALYTICS', 'Referral status overview'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.9,
          children: [
            _AnalyticsCard(
              title: 'TOTAL REFERRALS',
              value: '$total',
              subtitle: 'In selected period',
              icon: Icons.medical_services_outlined,
              iconColor: const Color(0xFF2563EB),
              background: const Color(0xFFEAF0FF),
            ),
            _AnalyticsCard(
              title: 'COMPLETED',
              value: '$_completedReferrals',
              subtitle: '${completion.toStringAsFixed(1)}% completion',
              icon: Icons.check_circle_outline,
              iconColor: const Color(0xFF16A34A),
              background: const Color(0xFFE9F8EF),
            ),
            _AnalyticsCard(
              title: 'PENDING',
              value: '$_pendingReferrals',
              subtitle: 'Awaiting next action',
              icon: Icons.schedule_outlined,
              iconColor: const Color(0xFFD97706),
              background: const Color(0xFFFFF4DF),
            ),
            _AnalyticsCard(
              title: 'SCHEDULED',
              value: '$_scheduledReferrals',
              subtitle: 'Appointment scheduled',
              icon: Icons.event_available_outlined,
              iconColor: const Color(0xFF0D9488),
              background: const Color(0xFFE4F7F5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataNote() {
    return _infoBanner(
      'Prototype data notice: current records are synthetic. Experimental AI '
      'predictions are excluded from clinical risk analytics. Daily averages, '
      'validated high-risk review rates and household coverage by area are not '
      'shown because the available records do not support reliable calculation.',
    );
  }

  Widget _sectionHeading(String label, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1)),
        const SizedBox(height: 7),
        Text(title,
            style: const TextStyle(
                color: AppColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  
  Widget _infoBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF0FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message,
          style: const TextStyle(
              color: Color(0xFF536987), fontSize: 10, height: 1.45)),
    );
  }

  Widget _emptyMessage(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(message,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 11)),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined,
                size: 42, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Unable to load reports',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(_errorMessage ?? 'Please try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _loadReports,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

 
  }


class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color background;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5EBF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 8,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value,
                      style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                ),
                const SizedBox(height: 3),
                Text(subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 8, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
