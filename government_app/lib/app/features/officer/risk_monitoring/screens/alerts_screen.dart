import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';

class _AlertColors {
  static const Color primary = Color(0xFF15365B);
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color textSecondary = Color(0xFF718096);
  static const Color background = Color(0xFFF4F7FC);
  static const Color border = Color(0xFFE4EAF2);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);
  static const Color success = Color(0xFF16A34A);
}

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final ApiClient _apiClient = ApiClient();

  int selectedFilter = 0;
  bool isLoading = true;
  String? errorMessage;

  final List<String> filters = [
    'All alerts',
    'Diabetes',
    'Cardiovascular',
    'Unassigned',
  ];

  List<Map<String, dynamic>> alerts = [];
  Map<int, Map<String, dynamic>> individualsById = {};
  Map<int, Map<String, dynamic>> workersById = {};

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      // Alerts are the primary source. Individual and worker lookups only
      // enrich the cards; an enrichment failure must not hide real alerts.
      final alertResponse = await _apiClient.get(
        '/alerts/',
        queryParameters: {'skip': 0, 'limit': 100},
      );

      if (alertResponse.data is! List) {
        throw Exception('Invalid alerts response from server.');
      }

      final fetchedAlerts = (alertResponse.data as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      Map<int, Map<String, dynamic>> fetchedIndividuals = {};
      Map<int, Map<String, dynamic>> fetchedWorkers = {};

      try {
        final response = await _apiClient.get(
          '/individuals/',
          queryParameters: {'skip': 0, 'limit': 100},
        );
        if (response.data is List) {
          for (final item in response.data as List) {
            if (item is Map) {
              final person = Map<String, dynamic>.from(item);
              final id = _toInt(person['id']);
              if (id != null) fetchedIndividuals[id] = person;
            }
          }
        }
      } catch (_) {
        // Fall back to displaying the individual database ID.
      }

      try {
        final response = await _apiClient.get(
          '/workers/',
          queryParameters: {'skip': 0, 'limit': 100},
        );
        if (response.data is List) {
          for (final item in response.data as List) {
            if (item is Map) {
              final worker = Map<String, dynamic>.from(item);
              final id = _toInt(worker['id']);
              if (id != null) fetchedWorkers[id] = worker;
            }
          }
        }
      } catch (_) {
        // Fall back to displaying the assigned worker database ID.
      }

      if (!mounted) return;
      setState(() {
        alerts = fetchedAlerts;
        individualsById = fetchedIndividuals;
        workersById = fetchedWorkers;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = _readableError(error);
      });
    }
  }

  int? _toInt(dynamic value) => int.tryParse(value?.toString() ?? '');

  String _readableError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  List<Map<String, dynamic>> get filteredAlerts {
    final result = alerts.where((alert) {
      final status = (alert['status'] ?? '').toString().toLowerCase();
      // The alerts endpoint returns active and resolved records. Keep both
      // visible in All alerts so officers can review the full alert history.
      if (selectedFilter == 1) {
        return _alertCategory(alert) == 'diabetes';
      }
      if (selectedFilter == 2) {
        return _alertCategory(alert) == 'cardiovascular';
      }
      if (selectedFilter == 3) {
        return alert['assigned_to'] == null;
      }
      return status.isNotEmpty;
    }).toList();

    result.sort((a, b) {
      final aOpen = (a['status'] ?? '').toString().toLowerCase() == 'open';
      final bOpen = (b['status'] ?? '').toString().toLowerCase() == 'open';
      if (aOpen == bOpen) {
        return (_toInt(b['id']) ?? 0).compareTo(_toInt(a['id']) ?? 0);
      }
      return aOpen ? -1 : 1;
    });
    return result;
  }

  String _alertCategory(Map<String, dynamic> alert) {
    final searchable =
        '${alert['title'] ?? ''} ${alert['message'] ?? ''}'.toLowerCase();
    if (searchable.contains('diabetes')) return 'diabetes';
    if (searchable.contains('cardiovascular')) return 'cardiovascular';
    return 'other';
  }

  String _individualName(Map<String, dynamic> alert) {
    final id = _toInt(alert['individual_id']);
    final individual = id == null ? null : individualsById[id];
    final name = individual?['full_name']?.toString();
    if (name != null && name.trim().isNotEmpty) return name;
    return id == null ? 'Individual not linked' : 'Individual #$id';
  }

  String _individualCode(Map<String, dynamic> alert) {
    final id = _toInt(alert['individual_id']);
    final individual = id == null ? null : individualsById[id];
    final code = individual?['individual_code']?.toString();
    return code?.isNotEmpty == true
        ? code!
        : (id == null ? 'No individual ID' : 'Individual ID: $id');
  }

  String _workerName(Map<String, dynamic> alert) {
    final id = _toInt(alert['assigned_to']);
    if (id == null) return 'Unassigned';
    final worker = workersById[id];
    final name = worker?['full_name']?.toString();
    if (name != null && name.trim().isNotEmpty) return name;
    return 'Worker #$id';
  }

  String _dateLabel(dynamic value) {
    if (value == null || value.toString().isEmpty) return 'Not available';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    final date = parsed.toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  String _statusLabel(dynamic value) {
    final status = (value ?? 'unknown').toString().toLowerCase();
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1);
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
      case 'high':
        return _AlertColors.danger;
      case 'medium':
      case 'moderate':
        return _AlertColors.warning;
      case 'low':
        return _AlertColors.success;
      default:
        return _AlertColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AlertColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadAlerts,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
                  children: [
                    const Text(
                      'PRIORITY COORDINATION',
                      style: TextStyle(
                        fontSize: 10,
                        color: _AlertColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Health alerts',
                      style: TextStyle(
                        fontSize: 22,
                        color: _AlertColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${filteredAlerts.length} alert records',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _AlertColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildFilters(),
                    const SizedBox(height: 20),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 70),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (errorMessage != null)
                      _buildErrorState()
                    else if (filteredAlerts.isEmpty)
                      _buildEmptyState()
                    else
                      ...filteredAlerts.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildAlertCard(item),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (!isLoading && errorMessage == null)
                      const Text(
                        'Alert records are displayed from the connected backend. '
                        'Experimental prediction alerts are demonstration data '
                        'and require review by a qualified healthcare professional.',
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.5,
                          color: _AlertColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: _AlertColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SWASTHYASETU',
                  style: TextStyle(
                    color: _AlertColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'North Zone Programme',
                  style: TextStyle(
                    color: _AlertColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadAlerts,
            icon: const Icon(
              Icons.refresh,
              color: _AlertColors.primary,
            ),
            tooltip: 'Refresh alerts',
          ),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE2EDFC),
            child: Text(
              'AM',
              style: TextStyle(
                color: _AlertColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = selectedFilter == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? _AlertColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: selected
                        ? _AlertColors.primary
                        : const Color(0xFFE3EAF3),
                  ),
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : _AlertColors.primary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> item) {
    final severity = (item['severity'] ?? 'unknown').toString();
    final status = (item['status'] ?? 'unknown').toString().toLowerCase();
    final category = _alertCategory(item);
    final individualId = _toInt(item['individual_id']);
    final accent = _severityColor(severity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AlertColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 19,
                          backgroundColor: const Color(0xFFE1ECFA),
                          child: Text(
                            'ID',
                            style: const TextStyle(
                              color: _AlertColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _individualName(item),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _AlertColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${_individualCode(item)} · Alert #${item['id']}',
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: _AlertColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _severityBadge(severity),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      (item['title'] ?? 'Health alert').toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: _AlertColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      (item['message'] ?? 'No alert description provided.')
                          .toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        height: 1.45,
                        color: _AlertColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _detail(
                            'ALERT TYPE',
                            category == 'other'
                                ? 'Not specified'
                                : category == 'diabetes'
                                    ? 'Diabetes'
                                    : 'Cardiovascular',
                          ),
                        ),
                        Expanded(
                          child: _detail(
                            'CREATED',
                            _dateLabel(item['created_at']),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _detail('ASSIGNED WORKER', _workerName(item)),
                        ),
                        Expanded(
                          child: _detail('STATUS', _statusLabel(status)),
                        ),
                      ],
                    ),
                    if (item['resolved_at'] != null) ...[
                      const SizedBox(height: 10),
                      _detail(
                        'RESOLVED ON',
                        _dateLabel(item['resolved_at']),
                      ),
                    ],
                    const SizedBox(height: 14),
                    const Divider(
                      height: 1,
                      color: Color(0xFFEDF1F6),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: individualId == null
                                ? null
                                : () {
                                    context.pushNamed(
                                      'individual-risk',
                                      pathParameters: {
                                        'id': individualId.toString(),
                                      },
                                    );
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _AlertColors.primaryBlue,
                              side: const BorderSide(
                                color: Color(0xFFE0E8F2),
                              ),
                              minimumSize: const Size(0, 42),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Review individual',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.push('/referrals'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _AlertColors.primaryBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 42),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'View referrals',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _severityBadge(String severity) {
    final color = _severityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 5),
          Text(
            '${_statusLabel(severity)} severity',
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: _AlertColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            color: _AlertColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 35,
            color: _AlertColors.textSecondary,
          ),
          const SizedBox(height: 10),
          const Text(
            'Unable to load alerts',
            style: TextStyle(
              color: _AlertColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            errorMessage ?? 'Please try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: _AlertColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _loadAlerts,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
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
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 35,
            color: _AlertColors.success,
          ),
          SizedBox(height: 10),
          Text(
            'No alerts found',
            style: TextStyle(
              color: _AlertColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'There are no backend records for this filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: _AlertColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final items = [
      (Icons.home_outlined, 'Dashboard'),
      (Icons.people_outline, 'Workers'),
      (Icons.person_outline, 'Individuals'),
      (Icons.warning_amber_outlined, 'Alerts'),
      (Icons.menu, 'More'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE7EDF5))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (index) {
              final selected = index == 3;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (index == 0) {
                      context.go('/dashboard');
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[index].$1,
                        size: 20,
                        color: selected
                            ? _AlertColors.primaryBlue
                            : Colors.blueGrey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index].$2,
                        style: TextStyle(
                          fontSize: 9,
                          color: selected
                              ? _AlertColors.primaryBlue
                              : Colors.blueGrey,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
