import 'package:material_ui/material_ui.dart';

import '../../workers/screens/data/worker_data_store.dart';
import '../../households/data/household_data_store.dart';

class AreaManagementScreen extends StatefulWidget {
  const AreaManagementScreen({super.key});

  @override
  State<AreaManagementScreen> createState() =>
      _AreaManagementScreenState();
}

class _AreaManagementScreenState extends State<AreaManagementScreen> {
  static const Color _background = Color(0xFFF4F7FC);
  static const Color _primary = Color(0xFF174A91);
  static const Color _blue = Color(0xFF2563EB);
  static const Color _muted = Color(0xFF718096);
  static const Color _border = Color(0xFFE5ECF5);

  final TextEditingController _searchController =
      TextEditingController();

  String _selectedFilter = 'All';

  List<Map<String, dynamic>> get _workers =>
      WorkerDataStore.workers
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

  List<Map<String, dynamic>> get _households =>
      HouseholdDataStore.getAllHouseholds()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

  List<String> get _areaNames {
    final names = <String>{};

    for (final worker in _workers) {
      final area = worker['area']?.toString().trim() ?? '';
      if (area.isNotEmpty) names.add(area);
    }

    for (final household in _households) {
      final area = household['area']?.toString().trim() ?? '';
      if (area.isNotEmpty) names.add(area);
    }

    final sorted = names.toList()..sort();
    return sorted;
  }

  List<Map<String, dynamic>> get _areas {
    final query = _searchController.text.trim().toLowerCase();
    final result = <Map<String, dynamic>>[];

    for (final areaName in _areaNames) {
      final areaWorkers = _workers
          .where((worker) => worker['area']?.toString() == areaName)
          .toList();

      final areaHouseholds = _households
          .where((household) => household['area']?.toString() == areaName)
          .toList();

      final activeCount = areaWorkers
          .where((worker) => worker['status'] == 'Active')
          .length;

      final inactiveCount = areaWorkers.length - activeCount;

      final matchesSearch = areaName.toLowerCase().contains(query);

      final matchesFilter = switch (_selectedFilter) {
        'Active' => activeCount > 0,
        'No active workers' => activeCount == 0,
        _ => true,
      };

      if (matchesSearch && matchesFilter) {
        result.add({
          'name': areaName,
          'workers': areaWorkers,
          'households': areaHouseholds,
          'activeWorkers': activeCount,
          'inactiveWorkers': inactiveCount,
        });
      }
    }

    return result;
  }

  int get _activeWorkerCount =>
      _workers.where((worker) => worker['status'] == 'Active').length;

  int get _householdCount => _households.length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final areas = _areas;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _primary,
        elevation: 0,
        title: const Text(
          'Area Management',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              const Text(
                'PROGRAMME COVERAGE',
                style: TextStyle(
                  color: _blue,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Manage service areas',
                style: TextStyle(
                  color: _primary,
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Monitor health worker coverage and registered households across programme areas.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),

              // SUMMARY CARDS
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.map_outlined,
                      label: 'SERVICE AREAS',
                      value: _areaNames.length.toString(),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.people_outline,
                      label: 'ACTIVE WORKERS',
                      value: _activeWorkerCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _summaryCard(
                      icon: Icons.home_work_outlined,
                      label: 'HOUSEHOLDS',
                      value: _householdCount.toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // SEARCH
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search area name...',
                  hintStyle: const TextStyle(fontSize: 12),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: _blue,
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.close, size: 18),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: _border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: _border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: _blue),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // FILTERS
              Wrap(
                spacing: 8,
                children: ['All', 'Active', 'No active workers']
                    .map((filter) {
                  final selected = _selectedFilter == filter;

                  return ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedFilter = filter);
                    },
                    selectedColor: const Color(0xFFDCEAFF),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: selected
                          ? const Color(0xFFB8D0FA)
                          : _border,
                    ),
                    labelStyle: TextStyle(
                      color: selected ? _blue : _muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // AREA LIST HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SERVICE AREAS',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '${areas.length} areas',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              if (areas.isEmpty)
                _emptyState()
              else
                ...areas.map(_areaCard),

              const SizedBox(height: 14),

              // INFORMATION NOTICE
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF4E2B5),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF9A6A12),
                      size: 18,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Area information is currently collected from registered worker and household records. Adding or editing official service areas will be enabled when the area database module is implemented.',
                        style: TextStyle(
                          color: Color(0xFF795B22),
                          fontSize: 10,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // SUMMARY CARD
  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _blue, size: 19),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: _primary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _muted,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // AREA CARD
  Widget _areaCard(Map<String, dynamic> area) {
    final workers =
        area['workers'] as List<Map<String, dynamic>>;
    final households =
        area['households'] as List<Map<String, dynamic>>;
    final activeCount = area['activeWorkers'] as int;
    final inactiveCount = area['inactiveWorkers'] as int;
    final hasCoverage = activeCount > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 11),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: _border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showAreaDetails(area),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 43,
                    width: 43,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: _blue,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area['name'].toString(),
                          style: const TextStyle(
                            color: _primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$activeCount active worker${activeCount == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: hasCoverage
                          ? const Color(0xFFE8F7EE)
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hasCoverage ? 'Active' : 'Needs coverage',
                      style: TextStyle(
                        color: hasCoverage
                            ? const Color(0xFF16834A)
                            : const Color(0xFFB66A00),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.chevron_right,
                    color: _primary,
                  ),
                ],
              ),

              const SizedBox(height: 13),
              const Divider(height: 1, color: _border),
              const SizedBox(height: 11),

              Row(
                children: [
                  _metric(
                    Icons.people_outline,
                    '$activeCount active',
                  ),
                  _metric(
                    Icons.person_off_outlined,
                    '$inactiveCount inactive',
                  ),
                  _metric(
                    Icons.home_work_outlined,
                    '${households.length} homes',
                  ),
                ],
              ),

              if (workers.isEmpty) ...[
                const SizedBox(height: 9),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No workers currently recorded for this area.',
                    style: TextStyle(
                      color: Color(0xFF9A6700),
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // AREA METRIC
  Widget _metric(IconData icon, String text) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF7A91B2),
            size: 13,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _muted,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // EMPTY STATE
  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            color: Color(0xFF8AA0BF),
            size: 34,
          ),
          SizedBox(height: 9),
          Text(
            'No matching areas found',
            style: TextStyle(
              color: _primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Try another search or filter.',
            style: TextStyle(
              color: _muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // AREA DETAILS BOTTOM SHEET
  void _showAreaDetails(Map<String, dynamic> area) {
    final workers =
        area['workers'] as List<Map<String, dynamic>>;
    final households =
        area['households'] as List<Map<String, dynamic>>;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(sheetContext).size.height * 0.78,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(22),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 13, 18, 25),
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8E0EA),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                area['name'].toString(),
                style: const TextStyle(
                  color: _primary,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Area coverage and assigned resources',
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 20),

              _sectionTitle(
                'HEALTH WORKERS (${workers.length})',
              ),

              if (workers.isEmpty)
                _emptyLine('No workers recorded for this area.')
              else
                ...workers.map((worker) {
                  final isActive = worker['status'] == 'Active';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEDF4FF),
                      child: Icon(
                        Icons.person_outline,
                        color: _blue,
                      ),
                    ),
                    title: Text(
                      worker['name']?.toString() ?? 'Worker',
                      style: const TextStyle(
                        color: _primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      worker['id']?.toString() ?? '',
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: Text(
                      worker['status']?.toString() ?? 'Unknown',
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFF16834A)
                            : const Color(0xFFB45309),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }),

              const Divider(height: 25),

              _sectionTitle(
                'REGISTERED HOUSEHOLDS (${households.length})',
              ),

              if (households.isEmpty)
                _emptyLine('No households registered in this area.')
              else
                ...households.map((household) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF0F4FA),
                      child: Icon(
                        Icons.home_outlined,
                        color: _blue,
                      ),
                    ),
                    title: Text(
                      household['householdName']?.toString() ??
                          'Household',
                      style: const TextStyle(
                        color: _primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      household['id']?.toString() ?? '',
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: Text(
                      '${household['memberCount'] ?? 0} members',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 9,
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  // BOTTOM SHEET SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: _blue,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // BOTTOM SHEET EMPTY MESSAGE
  Widget _emptyLine(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: _muted,
          fontSize: 11,
        ),
      ),
    );
  }
}