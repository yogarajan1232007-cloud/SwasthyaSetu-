import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';

class IndividualsScreen extends StatefulWidget {
  const IndividualsScreen({super.key});

  @override
  State<IndividualsScreen> createState() => _IndividualsScreenState();
}

class _IndividualsScreenState extends State<IndividualsScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);

  final ApiClient _apiClient = ApiClient();
  final TextEditingController _searchController = TextEditingController();

  String selectedFilter = 'All';
  String searchQuery = '';
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> individuals = [];

  @override
  void initState() {
    super.initState();
    _loadIndividuals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadIndividuals() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _apiClient.get(
        '/individuals/',
        queryParameters: {'skip': 0, 'limit': 100},
      );

      if (response.statusCode != 200 || response.data is! List) {
        throw Exception('Invalid individuals response from server.');
      }

      final records = (response.data as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where((item) => item['is_active'] != false)
          .toList();

      if (!mounted) return;
      setState(() {
        individuals = records;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  int? _ageFromDob(dynamic value) {
    if (value == null) return null;
    final dob = DateTime.tryParse(value.toString());
    if (dob == null) return null;
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age >= 0 ? age : null;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  List<Map<String, dynamic>> get filteredIndividuals {
    return individuals.where((person) {
      final name = (person['full_name'] ?? '').toString().toLowerCase();
      final code = (person['individual_code'] ?? '').toString().toLowerCase();
      final matchesSearch =
          name.contains(searchQuery) || code.contains(searchQuery);
      // Risk and follow-up APIs are not connected to this list yet.
      return matchesSearch && selectedFilter == 'All';
    }).toList();
  }

  void _openIndividual(Map<String, dynamic> person) {
    final id = person['id'];
    if (id == null) return;
    context.pushNamed(
      'individual-risk',
      pathParameters: {'id': id.toString()},
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        context.goNamed('dashboard');
        break;
      case 1:
        context.goNamed('workers');
        break;
      case 2:
        context.goNamed('individuals');
        break;
      case 3:
        context.goNamed('alerts');
        break;
      case 4:
        context.goNamed('dashboard');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredIndividuals;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: navy,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('dashboard');
            }
          },
        ),
        title: const Text(
          'Individuals',
          style: TextStyle(
            color: navy,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadIndividuals,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'REGISTERED POPULATION',
              style: TextStyle(
                color: blue,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Individuals',
              style: TextStyle(
                color: navy,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Review registered individuals and coordinate next steps.',
              style: TextStyle(
                color: Color(0xFF718096),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => searchQuery = value.toLowerCase().trim());
              },
              decoration: InputDecoration(
                hintText: 'Search name or Individual ID',
                prefixIcon: const Icon(Icons.search, color: navy),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5EBF3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5EBF3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: blue),
                ),
              ),
            ),
            const SizedBox(height: 17),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'High risk', 'Follow-up due'].map((filter) {
                  final selected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      selectedColor: navy,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : navy,
                        fontSize: 10,
                      ),
                      onSelected: (_) => setState(() => selectedFilter = filter),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage != null)
              _errorState()
            else ...[
              Text(
                '${filtered.length} individuals found',
                style: const TextStyle(
                  color: navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (selectedFilter != 'All')
                _unavailableFilterState()
              else if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(25),
                  child: Center(
                    child: Text('No individuals found.',
                        style: TextStyle(color: navy)),
                  ),
                )
              else
                ...filtered.map(_individualCard),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: blue,
        unselectedItemColor: const Color(0xFF718096),
        selectedFontSize: 11,
        unselectedFontSize: 10,
        elevation: 10,
        onTap: _handleNavigation,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Workers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Individuals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_outlined),
            activeIcon: Icon(Icons.warning),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 38, color: Colors.grey),
          const SizedBox(height: 10),
          const Text(
            'Unable to load individuals',
            style: TextStyle(color: navy, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            errorMessage ?? 'Please try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF718096), fontSize: 11),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loadIndividuals,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _unavailableFilterState() {
    final message = selectedFilter == 'High risk'
        ? 'AI risk assessment data is not available from this endpoint yet.'
        : 'Follow-up records are not connected to this screen yet.';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      child: Column(
        children: [
          const Icon(Icons.info_outline, color: blue, size: 30),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _individualCard(Map<String, dynamic> person) {
    final name = (person['full_name'] ?? 'Name unavailable').toString();
    final code = (person['individual_code'] ?? 'ID unavailable').toString();
    final gender = (person['gender'] ?? 'Not specified').toString();
    final age = _ageFromDob(person['date_of_birth']);
    final householdId = person['household_id'];
    final details = [
      if (age != null) '$age years',
      gender,
      if (householdId != null) 'Household $householdId',
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5EBF3)),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFFE0ECFA),
            child: Text(
              _initials(name),
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(
              color: navy,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: const TextStyle(color: blue, fontSize: 9)),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 8),
                const Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    _NotAssessedChip(label: 'Diabetes'),
                    _NotAssessedChip(label: 'Cardiovascular'),
                  ],
                ),
              ],
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: navy),
          onTap: () => _openIndividual(person),
        ),
      ),
    );
  }
}

class _NotAssessedChip extends StatelessWidget {
  const _NotAssessedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: Not Assessed',
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
