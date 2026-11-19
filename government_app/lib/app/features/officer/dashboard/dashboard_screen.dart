import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../more/screens/more_screen.dart';
import 'models/government_dashboard.dart';
import 'services/government_dashboard_service.dart';
import 'models/worker_performance.dart';
import 'services/worker_performance_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  final GovernmentDashboardService _dashboardService =
    GovernmentDashboardService();
  final WorkerPerformanceService _workerPerformanceService =
    WorkerPerformanceService();

List<WorkerPerformance> _workerPerformance = [];

bool _isWorkerLoading = true;
String? _workerError;

GovernmentDashboard? _dashboard;

bool _isLoading = true;
String? _errorMessage;

int get totalPopulation => _dashboard?.totalPopulation ?? 0;
int get malePopulation => _dashboard?.malePopulation ?? 0;
int get femalePopulation => _dashboard?.femalePopulation ?? 0;
int get seniorCitizens => _dashboard?.seniorCitizens ?? 0;
int get children => _dashboard?.children ?? 0;

int get screened => _dashboard?.completedScreenings ?? 0;
int get uniqueIndividualsScreened =>
    _dashboard?.uniqueIndividualsScreened ?? 0;

int get inProgressScreenings =>
    _dashboard?.inProgressScreenings ?? 0;

int get totalHouseholds => _dashboard?.totalHouseholds ?? 0;
int get assignedHouseholds => _dashboard?.assignedHouseholds ?? 0;
int get unassignedHouseholds => _dashboard?.unassignedHouseholds ?? 0;

int get totalAssignments => _dashboard?.totalAssignments ?? 0;
int get pendingAssignments => _dashboard?.pendingAssignments ?? 0;
int get completedAssignments => _dashboard?.completedAssignments ?? 0;
int get overdueAssignments => _dashboard?.overdueAssignments ?? 0;

int get totalWorkers => _dashboard?.totalWorkers ?? 0;
int get availableWorkers => _dashboard?.availableWorkers ?? 0;
int get unavailableWorkers => _dashboard?.unavailableWorkers ?? 0;
// Referral statistics
int get totalReferrals => _dashboard?.totalReferrals ?? 0;
int get pendingReferrals => _dashboard?.pendingReferrals ?? 0;
int get scheduledReferrals => _dashboard?.scheduledReferrals ?? 0;
int get completedReferrals => _dashboard?.completedReferrals ?? 0;

// AI health statistics
int get totalPredictions => _dashboard?.totalPredictions ?? 0;
int get experimentalPredictions =>
    _dashboard?.experimentalPredictions ?? 0;
int get nonExperimentalPredictions =>
    _dashboard?.nonExperimentalPredictions ?? 0;
int get diabetesPredictions => _dashboard?.diabetesPredictions ?? 0;
int get cardiovascularPredictions =>
    _dashboard?.cardiovascularPredictions ?? 0;
int get lowRiskPredictions => _dashboard?.lowRiskPredictions ?? 0;
int get mediumRiskPredictions => _dashboard?.mediumRiskPredictions ?? 0;
int get highRiskPredictions => _dashboard?.highRiskPredictions ?? 0;


@override
void initState() {
  super.initState();
  _loadDashboard();
  _loadWorkerPerformance();
}

Future<void> _loadDashboard() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final result = await _dashboardService.fetchDashboard();

    if (!mounted) return;

    setState(() {
      _dashboard = result;
      _isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
  }
}
Future<void> _loadWorkerPerformance() async {
  setState(() {
    _isWorkerLoading = true;
    _workerError = null;
  });

  try {
    final result =
        await _workerPerformanceService.fetchWorkerPerformance();

    if (!mounted) return;

    setState(() {
      _workerPerformance = result;
      _isWorkerLoading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _workerError = e.toString();
      _isWorkerLoading = false;
    });
  }
}


@override
Widget build(BuildContext context) {
  final isMobile = MediaQuery.sizeOf(context).width < 700;

  return Scaffold(
    backgroundColor: const Color(0xFFF4F7FC),

    body: selectedIndex == 4
        ? const MoreScreen()
        : SafeArea(
            child: Column(
              children: [
                // Show dashboard header only on mobile.
                if (isMobile) _buildHeader(),

                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _errorMessage != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.cloud_off_outlined,
                                      size: 45,
                                      color: Colors.redAccent,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Unable to load dashboard',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _errorMessage!,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _loadDashboard,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(
                                16, 20, 16, 20,
                              ),
                              children: [
                                _buildGreeting(),
                                const SizedBox(height: 20),
                                _buildStatistics(),
                                const SizedBox(height: 22),
                                _buildCoverageCard(),
                                const SizedBox(height: 22),

                                _buildAiHealthIntelligence(),
                                const SizedBox(height: 22),

                                _buildHouseholdOverview(),
                                const SizedBox(height: 22),

                                _buildAssignmentOverview(),
                                const SizedBox(height: 22),

                                _buildReferralOverview(),
                                const SizedBox(height: 25),

                                _buildQuickActions(),
                                const SizedBox(height: 25),

                                _buildWorkerPerformance(),
                                const SizedBox(height: 20),
                              ],
                            ),
                ),
              ],
            ),
          ),

    // Bottom navigation only on mobile.
    bottomNavigationBar:
        isMobile ? _buildBottomNavigation() : null,
  );
}


  // =====================================================
  // HEADER
  // =====================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),

      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE7EDF5),
          ),
        ),
      ),

      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,

            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.health_and_safety_outlined,
              color: Colors.white,
              size: 27,
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
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),

                SizedBox(height: 3),

                Text(
                  'North Zone Programme',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              _showMessage('Notifications');
            },

            icon: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.primary,
            ),
          ),

          const CircleAvatar(
            radius: 19,
            backgroundColor: Color(0xFFE2EDFC),

            child: Text(
              'AM',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // GREETING
  // =====================================================

  Widget _buildGreeting() {
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good morning'
        : now.hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
    ];
    final dateLabel =
        '${now.day} ${months[now.month - 1]} ${now.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateLabel,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$greeting, Officer',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 21,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Here is the latest community health programme overview.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // NEW DEMOGRAPHIC STATISTICS
  // =====================================================

 
Widget _buildStatistics() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionHeading(
        'POPULATION OVERVIEW',
        'Population statistics',
        null,
      ),
      const SizedBox(height: 12),

      _populationCard(
        title: 'TOTAL POPULATION',
        value: totalPopulation,
        subtitle: 'Registered individuals',
        icon: Icons.groups_rounded,
        color: const Color(0xFF2455C3),
        isLarge: true,
      ),

      const SizedBox(height: 12),

      LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          final columns = width >= 1000
              ? 4
              : width >= 650
                  ? 3
                  : 2;

          return GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: width >= 1000 ? 1.35 : 1.15,
            children: [
              _populationCard(
                title: 'MALE',
                value: malePopulation,
                subtitle: 'Male individuals',
                icon: Icons.male_rounded,
                color: const Color(0xFF2684D9),
              ),
              _populationCard(
                title: 'FEMALE',
                value: femalePopulation,
                subtitle: 'Female individuals',
                icon: Icons.female_rounded,
                color: const Color(0xFFE34D86),
              ),
              _populationCard(
                title: 'SENIOR CITIZENS',
                value: seniorCitizens,
                subtitle: 'Age 60 and above',
                icon: Icons.elderly_rounded,
                color: const Color(0xFF8054C9),
              ),
              _populationCard(
                title: 'CHILDREN',
                value: children,
                subtitle: 'Below 18 years',
                icon: Icons.child_care_rounded,
                color: const Color(0xFFEA9234),
              ),
            ],
          );
        },
      ),
    ],
  );
}

  // POPULATION STAT CARD

 Widget _populationCard({
  required String title,
  required int value,
  required String subtitle,
  required IconData icon,
  required Color color,
  bool isLarge = false,
}) {
  return Container(
    padding: EdgeInsets.all(isLarge ? 14 : 11),

    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(15),

      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.18),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),

    child: isLarge
        ? Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 26,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      _formatNumber(value),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),

      Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),

      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          _formatNumber(value),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 8,
        ),
      ),
    ],
  ),
  );
}

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  // =====================================================
  // SCREENING COVERAGE
  // =====================================================

 
Widget _buildCoverageCard() {
  final progress = totalPopulation > 0
      ? (uniqueIndividualsScreened / totalPopulation)
          .clamp(0.0, 1.0)
      : 0.0;

  final remaining =
      (totalPopulation - uniqueIndividualsScreened)
          .clamp(0, totalPopulation);

  return Container(
    padding: const EdgeInsets.all(17),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'SCREENING COVERAGE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/reports'),
              child: const Text(
                'View report  ›',
                style: TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),

        const Text(
          'Programme progress',
          style: TextStyle(
            fontSize: 17,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 20),

        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 450;

            final chart = SizedBox(
              height: 115,
              width: 115,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 11,
                      backgroundColor: const Color(0xFFE8EDF5),
                      valueColor:
                          const AlwaysStoppedAnimation(
                        AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'completed',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );

            final statistics = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _coverageValue(
                  'Screened',
                  _formatNumber(screened),
                ),
                const SizedBox(height: 15),
                _coverageValue(
                  'Remaining',
                  _formatNumber(remaining),
                ),
                const SizedBox(height: 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE8EDF5),
                    valueColor:
                        const AlwaysStoppedAnimation(
                      AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$inProgressScreenings screenings currently in progress',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );

            if (isCompact) {
              return Column(
                children: [
                  chart,
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: statistics,
                  ),
                ],
              );
            }

            return Row(
              children: [
                chart,
                const SizedBox(width: 25),
                Expanded(child: statistics),
              ],
            );
          },
        ),
      ],
    ),
  );
}


  Widget _coverageValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // HOUSEHOLD OVERVIEW
  // =====================================================


  // =====================================================
  // AI HEALTH INTELLIGENCE
  // =====================================================

  Widget _buildAiHealthIntelligence() {
    final totalRisk =
        lowRiskPredictions + mediumRiskPredictions + highRiskPredictions;

    double riskPercentage(int value) {
      if (totalRisk == 0) return 0;
      return value / totalRisk;
    }

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            'ARTIFICIAL INTELLIGENCE',
            'AI Health Intelligence',
            null,
          ),
          const SizedBox(height: 6),
          const Text(
            'Overview of saved AI health risk assessments.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF15365B), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0x33FFFFFF),
                  child: Icon(Icons.psychology_outlined, color: Colors.white),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL AI PREDICTIONS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatNumber(totalPredictions),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.auto_graph, color: Colors.white70, size: 30),
              ],
            ),
          ),
          const SizedBox(height: 13),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 600 ? 2 : 1;
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: columns == 2 ? 2.4 : 3.2,
                children: [
                  _aiMetricCard(
                    title: 'Diabetes',
                    value: diabetesPredictions,
                    icon: Icons.bloodtype_outlined,
                    color: const Color(0xFF2563EB),
                  ),
                  _aiMetricCard(
                    title: 'Cardiovascular',
                    value: cardiovascularPredictions,
                    icon: Icons.favorite_outline,
                    color: const Color(0xFFE34D68),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'RISK DISTRIBUTION',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 15),
          _aiRiskBar(
            'Low Risk',
            lowRiskPredictions,
            riskPercentage(lowRiskPredictions),
            const Color(0xFF16A36A),
          ),
          const SizedBox(height: 13),
          _aiRiskBar(
            'Medium Risk',
            mediumRiskPredictions,
            riskPercentage(mediumRiskPredictions),
            const Color(0xFFE6A12C),
          ),
          const SizedBox(height: 13),
          _aiRiskBar(
            'High Risk',
            highRiskPredictions,
            riskPercentage(highRiskPredictions),
            const Color(0xFFDC4545),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF5D99A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFB7791F),
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '$experimentalPredictions experimental predictions · '
                    '$nonExperimentalPredictions non-experimental predictions.\n'
                    'Current AI models are experimental and not clinically '
                    'validated. Results must not be used as medical diagnoses '
                    'or treatment decisions.',
                    style: const TextStyle(
                      color: Color(0xFF805B19),
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiMetricCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatNumber(value),
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
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

  Widget _aiRiskBar(
    String title,
    int value,
    double percentage,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$value (${(percentage * 100).toStringAsFixed(1)}%)',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: const Color(0xFFEDF1F7),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // HOUSEHOLD OVERVIEW
  // =====================================================

  Widget _buildHouseholdOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading('HOUSEHOLD MANAGEMENT', 'Household overview', null),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _overviewMetric(
                  'Total households',
                  totalHouseholds,
                  Icons.home_work_outlined,
                  const Color(0xFF2455C3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _overviewMetric(
                  'Assigned',
                  assignedHouseholds,
                  Icons.assignment_turned_in_outlined,
                  const Color(0xFF16845B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _overviewMetric(
                  'Unassigned',
                  unassignedHouseholds,
                  Icons.assignment_late_outlined,
                  const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.pushNamed('households'),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Manage households'),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ASSIGNMENT OVERVIEW
  // =====================================================

  Widget _buildAssignmentOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading('FIELD OPERATIONS', 'Assignment overview', null),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _overviewMetric(
                  'Total',
                  totalAssignments,
                  Icons.assignment_outlined,
                  const Color(0xFF2455C3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _overviewMetric(
                  'Pending',
                  pendingAssignments,
                  Icons.pending_actions_outlined,
                  const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _overviewMetric(
                  'Completed',
                  completedAssignments,
                  Icons.task_alt_outlined,
                  const Color(0xFF16845B),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _overviewMetric(
                  'Overdue',
                  overdueAssignments,
                  Icons.warning_amber_outlined,
                  const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.pushNamed('assignments'),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Manage assignments'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewMetric(
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 19),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _formatNumber(value),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // REFERRAL OVERVIEW
  // =====================================================

  Widget _buildReferralOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            'MEDICAL REFERRALS',
            'Referral overview',
            null,
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 850 ? 4 : 2;

              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: constraints.maxWidth >= 850 ? 1.8 : 2.1,
                children: [
                  _overviewMetric(
                    'Total referrals',
                    totalReferrals,
                    Icons.medical_services_outlined,
                    const Color(0xFF2455C3),
                  ),
                  _overviewMetric(
                    'Pending',
                    pendingReferrals,
                    Icons.pending_actions_outlined,
                    const Color(0xFFD97706),
                  ),
                  _overviewMetric(
                    'Scheduled',
                    scheduledReferrals,
                    Icons.calendar_month_outlined,
                    const Color(0xFF8054C9),
                  ),
                  _overviewMetric(
                    'Completed',
                    completedReferrals,
                    Icons.task_alt_outlined,
                    const Color(0xFF16845B),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/referrals'),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Manage referrals'),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // QUICK ACTIONS
  // =====================================================

 Widget _buildQuickActions() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionHeading(
        'SHORTCUTS',
        'Quick actions',
        null,
      ),
    _actionButton(
  Icons.home_work_outlined,
  'Manage Households',
  () => context.pushNamed('households'),
),
      const SizedBox(height: 13),

      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.5,
        children: [
          _actionButton(
            Icons.add,
            'Assign worker',
            () => context.push('/create-assignment'),
          ),

          _actionButton(
            Icons.assignment_outlined,
            'Manage assignments',
            () => context.pushNamed('assignments'),
          ),

          _actionButton(
            Icons.people_outline,
            'Individuals',
            () => context.push('/individuals'),
          ),

          _actionButton(
            Icons.home_work_outlined,
            'Register Household',
            () => context.pushNamed('household-registration'),
          ),

          _actionButton(
            Icons.calendar_month_outlined,
            'Follow-ups',
            () => context.push('/follow-ups'),
          ),
          _actionButton(
            Icons.medical_services_outlined,
            'Manage referrals',
            () => context.push('/referrals'),
          ),
        ],
      ),
    ],
  );
}

  Widget _actionButton(
  IconData icon,
  String title,
  VoidCallback onTap,
) {
  return Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),

    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),

      child: Container(
        padding: const EdgeInsets.all(12),

        decoration: _cardDecoration(),

        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 20,
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  // =====================================================
  // WORKER PERFORMANCE
  // =====================================================

 Widget _buildWorkerPerformance() {
  final workers = _workerPerformance;

  final backgrounds = [
    const Color(0xFFE1EDFC),
    const Color(0xFFE1F5F2),
    const Color(0xFFF2EAFB),
    const Color(0xFFFFF4DF),
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionHeading(
        'FIELD OPERATIONS',
        'Worker performance',
        'View all',
      ),

      const SizedBox(height: 12),

      if (_isWorkerLoading)
        const Center(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: CircularProgressIndicator(),
          ),
        )

      else if (_workerError != null)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: Colors.redAccent,
                size: 30,
              ),
              const SizedBox(height: 8),
              const Text('Unable to load worker performance'),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _loadWorkerPerformance,
                child: const Text('Retry'),
              ),
            ],
          ),
        )

      else if (workers.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: const Text(
            'No workers registered yet.',
            textAlign: TextAlign.center,
          ),
        )

      else
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _cardDecoration(),
          child: Column(
            children: List.generate(workers.length, (index) {
              final worker = workers[index];

              final names = worker.workerName
                  .trim()
                  .split(RegExp(r'\s+'));

              final initials = names
                  .take(2)
                  .map((name) => name.isNotEmpty
                      ? name[0].toUpperCase()
                      : '')
                  .join();

              final progress = worker.totalAssignments > 0
                  ? (worker.completedAssignments /
                          worker.totalAssignments)
                      .clamp(0.0, 1.0)
                      .toDouble()
                  : 0.0;

              final availability = worker.isAvailable
                  ? 'Available'
                  : 'Unavailable';

              final details =
                  '${worker.area} · '
                  '${worker.completedScreenings} completed screenings · '
                  '$availability';

              return Column(
                children: [
                  _workerRow(
                    initials,
                    worker.workerName,
                    details,
                    progress,
                    backgrounds[index % backgrounds.length],
                  ),

                  if (index != workers.length - 1)
                    const Divider(height: 22),
                ],
              );
            }),
          ),
        ),
    ],
  );
}

  Widget _workerRow(
    String initials,
    String name,
    String details,
    double progress,
    Color background,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: background,

          child: Text(
            initials,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                details,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
          width: 90,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 6),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),

                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE7EDF5),
                  valueColor:
                      const AlwaysStoppedAnimation(
                    AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =====================================================
  // SECTION HEADING
  // =====================================================

  Widget _sectionHeading(
    String label,
    String title,
    String? action,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: AppColors.primaryBlue,
              ),
            ),
           if (action != null)
  GestureDetector(
    onTap: () {
      if (action == 'Explore') {
        context.push('/risk-monitoring');
      } else if (action == 'View all' &&
          title == 'Worker performance') {
        context.pushNamed('worker-performance');
      } else {
        _showMessage(title);
      }
    },
    child: Text(
      action,
      style: const TextStyle(
        color: AppColors.primaryBlue,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
           
              
          ],
        ),

        const SizedBox(height: 6),

        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // =====================================================
  // BOTTOM NAVIGATION
  // =====================================================

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
      border: Border(
        top: BorderSide(
          color: Color(0xFFE7EDF5),
        ),
      ),
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 64,
        child: Row(
          children: List.generate(items.length, (index) {
            final selected = selectedIndex == index;

            return Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                 switch (index) {
  case 0:
    context.go('/dashboard');
    break;

  case 1:
    context.go('/workers');
    break;

  case 2:
    context.go('/individuals');
    break;

  case 3:
    context.go('/alerts');
    break;

  case 4:
  break;
}
                  
                  
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[index].$1,
                        size: 20,
                        color: selected
                            ? AppColors.primaryBlue
                            : Colors.blueGrey,
                      ),
                      const SizedBox(height: 4),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            items[index].$2,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: selected
                                  ? AppColors.primaryBlue
                                  : Colors.blueGrey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}


  // =====================================================
  // COMMON CARD DECORATION
  // =====================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,

      borderRadius: BorderRadius.circular(15),

      border: Border.all(
        color: const Color(0xFFE7EDF5),
      ),

      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // =====================================================
  // TEMPORARY MESSAGE
  // =====================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}