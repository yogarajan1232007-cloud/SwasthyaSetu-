import 'package:material_ui/material_ui.dart';
import 'package:dio/dio.dart';

import '../../../../../core/network/api_client.dart';
import '../household_service.dart';
import '../individual_service.dart';

class ConsentManagementScreen extends StatefulWidget {
  final String householdId;

  const ConsentManagementScreen({
    super.key,
    required this.householdId,
  });

  @override
  State<ConsentManagementScreen> createState() =>
      _ConsentManagementScreenState();
}

class _ConsentManagementScreenState
    extends State<ConsentManagementScreen> {
  final HouseholdService _householdService = HouseholdService();
  final IndividualService _individualService = IndividualService();
  final ApiClient _apiClient = ApiClient();

  Map<String, dynamic>? household;

  List<Map<String, dynamic>> members = [];

  bool _isLoading = true;
  bool _isUpdating = false;

  String? _errorMessage;

  // ============================================================
  // LOAD HOUSEHOLD AND INDIVIDUALS
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final householdId = int.tryParse(widget.householdId);

      if (householdId == null) {
        throw Exception('Invalid household ID');
      }

      // Fetch household from backend.
      final householdData =
          await _householdService.fetchHousehold(householdId);

      // Fetch family members from backend.
      final individualList =
          await _individualService.fetchHouseholdIndividuals(
        householdId,
      );

      // Retrieve consent for each individual.
      final updatedMembers = await Future.wait(
        individualList.map((individual) async {
          final member = Map<String, dynamic>.from(individual);

          member['consentStatus'] = 'Pending';
          member['consentRecord'] = null;

          try {
            final response = await _apiClient.get(
              '/consents/individual/${member['id']}',
            );

            if (response.data is Map) {
              final consent =
                  Map<String, dynamic>.from(response.data);

              member['consentRecord'] = consent;

              final status =
                  consent['consent_status']?.toString().toLowerCase();

              member['consentStatus'] =
                  _formatStatus(status);
            }
          } on DioException catch (error) {
            // No consent record means Pending.
            if (error.response?.statusCode == 404) {
              member['consentStatus'] = 'Pending';
            } else {
              rethrow;
            }
          }

          return member;
        }),
      );

      if (!mounted) return;

      setState(() {
        household = householdData;
        members = updatedMembers;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // FORMAT CONSENT STATUS
  // ============================================================

  String _formatStatus(String? status) {
    switch (status) {
      case 'granted':
        return 'Granted';

      case 'declined':
        return 'Declined';

      case 'revoked':
        return 'Revoked';

      default:
        return 'Pending';
    }
  }

  // ============================================================
  // GRANT / DECLINE CONSENT
  // ============================================================

  Future<void> _updateConsent(
    Map<String, dynamic> member,
    String status,
  ) async {
    if (_isUpdating) return;

    final name = member['full_name']?.toString() ?? 'Individual';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$status Consent?'),
          content: Text(
            'Confirm that $name has voluntarily provided '
            'this consent decision and that it has been '
            'appropriately documented.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      setState(() {
        _isUpdating = true;
      });

      final individualId = int.parse(
        member['id'].toString(),
      );

      await _apiClient.post(
        '/consents/',
        data: {
          'individual_id': individualId,
          'consent_status': status.toLowerCase(),
          'consent_method': 'in_person',
          'consent_version': '1.0',
          'remarks': 'Recorded by Health Officer',
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name: consent marked $status'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadData();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Consent update failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  // ============================================================
  // REVOKE CONSENT
  // ============================================================

  Future<void> _revokeConsent(
    Map<String, dynamic> member,
  ) async {
    if (_isUpdating) return;

    final consent =
        member['consentRecord'] as Map<String, dynamic>?;

    if (consent == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Revoke Consent?'),
          content: Text(
            'Are you sure you want to revoke consent for '
            '${member['full_name']}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Revoke'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      setState(() {
        _isUpdating = true;
      });

      final consentId = consent['id'];

      await _apiClient.post(
        '/consents/$consentId/revoke',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consent revoked successfully'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadData();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to revoke consent: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  // ============================================================
  // CONSENT STATISTICS
  // ============================================================

  int _countStatus(String status) {
    return members.where(
      (member) => member['consentStatus'] == status,
    ).length;
  }

  // ============================================================
  // BUILD SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Consent Management'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Consent Management'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 45,
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final data = household!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        title: const Text('Consent Management'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172B4D),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHouseholdCard(data),

                const SizedBox(height: 18),

                _buildStatistics(),

                const SizedBox(height: 22),

                const Text(
                  'INDIVIDUAL CONSENT RECORDS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 12),

                if (members.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Center(
                        child: Text(
                          'No individuals registered yet.',
                        ),
                      ),
                    ),
                  )
                else
                  ...members.map(_memberCard),

                const SizedBox(height: 30),
              ],
            ),
          ),

          if (_isUpdating)
            Container(
              color: Colors.black.withValues(alpha: 0.08),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // HOUSEHOLD INFORMATION
  // ============================================================

  Widget _buildHouseholdCard(
    Map<String, dynamic> data,
  ) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HOUSEHOLD INFORMATION',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              data['household_code']?.toString() ?? '-',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Household Head: ${data['head_of_family'] ?? '-'}',
            ),

            const SizedBox(height: 5),

            Text(
              'Household ID: ${data['id'] ?? '-'}',
            ),

            const SizedBox(height: 5),

            Text(
              'Area: ${data['area'] ?? '-'}',
            ),

            const SizedBox(height: 5),

            Text(
              'Address: ${data['address'] ?? '-'}',
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStatistics() {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONSENT OVERVIEW',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _count(
                  'Granted',
                  _countStatus('Granted'),
                  Colors.green,
                ),
                _count(
                  'Declined',
                  _countStatus('Declined'),
                  Colors.red,
                ),
                _count(
                  'Pending',
                  _countStatus('Pending'),
                  Colors.orange,
                ),
                _count(
                  'Revoked',
                  _countStatus('Revoked'),
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _count(
    String label,
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
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  // ============================================================
  // INDIVIDUAL CONSENT CARD
  // ============================================================

  Widget _memberCard(
    Map<String, dynamic> member,
  ) {
    final status =
        member['consentStatus']?.toString() ?? 'Pending';

    final color = status == 'Granted'
        ? Colors.green
        : status == 'Declined'
            ? Colors.red
            : status == 'Revoked'
                ? Colors.purple
                : Colors.orange;

    final consent =
        member['consentRecord'] as Map<String, dynamic>?;

    return Card(
      margin: const EdgeInsets.only(bottom: 13),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFEAF1FF),
                  child: Icon(
                    Icons.person_outline,
                    color: Color(0xFF2563EB),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member['full_name']?.toString() ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF172B4D),
                        ),
                      ),

                      Text(
                        member['individual_code']?.toString() ?? '-',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                Chip(
                  label: Text(status),
                  backgroundColor:
                      color.withValues(alpha: 0.12),
                  labelStyle: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _infoRow(
              'Individual ID',
              member['id'],
            ),

            _infoRow(
              'Gender',
              member['gender'],
            ),

            _infoRow(
              'Mobile Number',
              member['mobile_number'],
            ),

            _infoRow(
              'Blood Group',
              member['blood_group'],
            ),

            if (consent != null) ...[
              const Divider(height: 22),

              _infoRow(
                'Consent Method',
                consent['consent_method'],
              ),

              _infoRow(
                'Consent Version',
                consent['consent_version'],
              ),

              _infoRow(
                'Recorded Date',
                consent['created_at'],
              ),

              if (consent['remarks'] != null)
                _infoRow(
                  'Remarks',
                  consent['remarks'],
                ),
            ],

            const Divider(height: 22),

            const Text(
              'RECORD CONSENT DECISION',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: status == 'Granted' ||
                          _isUpdating
                      ? null
                      : () => _updateConsent(
                            member,
                            'Granted',
                          ),
                  child: const Text('Grant'),
                ),

                OutlinedButton(
                  onPressed: status == 'Declined' ||
                          _isUpdating
                      ? null
                      : () => _updateConsent(
                            member,
                            'Declined',
                          ),
                  child: const Text('Decline'),
                ),

                OutlinedButton(
                  onPressed: status == 'Granted' &&
                          !_isUpdating
                      ? () => _revokeConsent(member)
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Revoke'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _infoRow(
    String title,
    dynamic value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF172B4D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}