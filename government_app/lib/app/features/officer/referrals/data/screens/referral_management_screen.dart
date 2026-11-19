import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../services/referral_api_service.dart';

class ReferralManagementScreen extends StatefulWidget {
  const ReferralManagementScreen({super.key});

  @override
  State<ReferralManagementScreen> createState() =>
      _ReferralManagementScreenState();
}

class _ReferralManagementScreenState extends State<ReferralManagementScreen> {
  final ReferralApiService _referralApiService = ReferralApiService();

  List<Map<String, dynamic>> referrals = [];
  String selectedFilter = 'All';
  bool isLoading = true;
  String? errorMessage;

  final Color primaryBlue = const Color(0xFF2563EB);
  final Color backgroundColor = const Color(0xFFF4F7FC);

  @override
  void initState() {
    super.initState();
    _loadReferrals();
  }

  Future<void> _loadReferrals() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final result = await _referralApiService.getReferrals();
      if (!mounted) return;

      setState(() {
        referrals = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  String _normaliseStatus(dynamic value) {
    final raw = (value ?? '').toString().trim().toLowerCase();
    switch (raw) {
      case 'in_progress':
      case 'in progress':
        return 'In Progress';
      case 'pending':
        return 'Pending';
      case 'referred':
        return 'Referred';
      case 'scheduled':
        return 'Scheduled';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return raw.isEmpty
            ? 'Unknown'
            : raw[0].toUpperCase() + raw.substring(1);
    }
  }

  List<Map<String, dynamic>> get filteredReferrals {
    if (selectedFilter == 'All') return referrals;
    return referrals.where((item) {
      return _normaliseStatus(item['status']) == selectedFilter;
    }).toList();
  }

  int getCount(String status) {
    return referrals
        .where((item) => _normaliseStatus(item['status']) == status)
        .length;
  }

  String _formatDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return 'Not specified';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    final date = parsed.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _display(dynamic value, {String fallback = 'Not provided'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadReferrals,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CARE COORDINATION',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Referral management',
                        style: TextStyle(
                          fontSize: 23,
                          color: Color(0xFF15365B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Track consultations from referral to completion.',
                        style: TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildStatistics(),
                      const SizedBox(height: 22),
                      _buildFilters(),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Referral records',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF15365B),
                            ),
                          ),
                          Text(
                            '${filteredReferrals.length} records',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 50),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (errorMessage != null)
                        _buildErrorState()
                      else if (filteredReferrals.isEmpty)
                        _buildEmptyState()
                      else
                        ...filteredReferrals.map(_buildReferralCard),
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
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8EDF5)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Color(0xFF15365B),
            ),
          ),
          const Spacer(),
          const Text(
            'SWASTHYASETU',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF15365B),
              letterSpacing: 0.6,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Refresh referrals',
            onPressed: _loadReferrals,
            icon: const Icon(Icons.refresh, color: Color(0xFF15365B)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Pending',
            getCount('Pending'),
            const Color(0xFFFFF5DF),
            const Color(0xFFD68A00),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            'Scheduled',
            getCount('Scheduled'),
            const Color(0xFFEAF1FF),
            const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            'In progress',
            getCount('In Progress'),
            const Color(0xFFE8F8F2),
            const Color(0xFF07966F),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            'Completed',
            getCount('Completed'),
            const Color(0xFFEAF7ED),
            const Color(0xFF16803D),
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    int count,
    Color background,
    Color foreground,
  ) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    const filters = [
      'All',
      'Pending',
      'Referred',
      'Scheduled',
      'In Progress',
      'Completed',
      'Cancelled',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => selectedFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF15365B) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF15365B)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReferralCard(Map<String, dynamic> referral) {
    final status = _normaliseStatus(referral['status']);
    final urgency = _display(referral['urgency'], fallback: 'Routine');
    final individualId = referral['individual_id'];
    final referralId = referral['id'];

    final statusColor = status == 'Completed'
        ? const Color(0xFF16803D)
        : status == 'In Progress'
            ? const Color(0xFF07966F)
            : status == 'Scheduled'
                ? const Color(0xFF2563EB)
                : status == 'Cancelled'
                    ? const Color(0xFF64748B)
                    : const Color(0xFFD68A00);

    final urgencyColor = urgency.toLowerCase() == 'emergency'
        ? const Color(0xFFDC2626)
        : urgency.toLowerCase() == 'urgent'
            ? const Color(0xFFEA580C)
            : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4EAF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: const Color(0xFFE2EDFA),
                child: Text(
                  'I${individualId ?? '-'}',
                  style: const TextStyle(
                    color: Color(0xFF15365B),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Individual #${individualId ?? 'Unknown'}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF15365B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Referral #${referralId ?? '-'}'
                      '${referral['screening_id'] == null ? '' : ' • Screening #${referral['screening_id']}'}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),
              _badge(
                urgency,
                urgencyColor.withValues(alpha: 0.12),
                urgencyColor,
              ),
            ],
          ),
          const SizedBox(height: 17),
          _detailRow('Referral reason', _display(referral['reason'])),
          _detailRow(
            'Referred facility',
            _display(referral['facility_name']),
          ),
          _detailRow('Referral date', _formatDate(referral['referred_at'])),
          _detailRow(
            'Appointment',
            _formatDate(referral['appointment_at']),
          ),
          _detailRow(
            'Clinician',
            _display(referral['clinician_name']),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Current status',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF718096),
                ),
              ),
              const Spacer(),
              _badge(
                status,
                statusColor.withValues(alpha: 0.12),
                statusColor,
              ),
            ],
          ),
          if (_display(referral['notes'], fallback: '').isNotEmpty) ...[
            const SizedBox(height: 10),
            _detailRow('Notes', _display(referral['notes'])),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE9EEF5)),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: individualId == null
                      ? null
                      : () {
                          context.pushNamed(
                            'individual-risk',
                            pathParameters: {'id': individualId.toString()},
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    side: const BorderSide(color: Color(0xFFDCE5F1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'View individual',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    context.pushNamed(
                      'referral-status',
                      extra: referral,
                    ).then((_) => _loadReferrals());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    status == 'Completed' ? 'View status' : 'Update status',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF718096),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF15365B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 35,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(height: 10),
          const Text(
            'Unable to load referrals',
            style: TextStyle(
              color: Color(0xFF15365B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            errorMessage ?? 'Please check your connection and try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF718096),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: _loadReferrals,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 35,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 10),
          Text(
            'No referrals found',
            style: TextStyle(
              color: Color(0xFF15365B),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'There are no records in this category.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }
}
