import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';

class IndividualRiskScreen extends StatefulWidget {
  // The existing GoRouter route passes the individual's database ID here.
  // Keep this constructor parameter unchanged to preserve route compatibility.
  final String referralId;

  const IndividualRiskScreen({
    super.key,
    required this.referralId,
  });

  @override
  State<IndividualRiskScreen> createState() => _IndividualRiskScreenState();
}

class _IndividualRiskScreenState extends State<IndividualRiskScreen> {
  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color muted = Color(0xFF718096);

  final ApiClient _apiClient = ApiClient();

  bool _isLoading = true;
  String? _errorMessage;
  String? _predictionError;
  Map<String, dynamic>? _individual;
  List<Map<String, dynamic>> _predictions = [];
  List<Map<String, dynamic>> _screenings = [];
  int? _selectedScreeningId;
  String? _runningPredictionType;
  String? _screeningError;

  int? get _individualId => int.tryParse(widget.referralId);

  @override
  void initState() {
    super.initState();
    _loadScreen();
  }

  Future<void> _loadScreen() async {
    final id = _individualId;
    if (id == null || id <= 0) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid individual ID.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _predictionError = null;
    });

    try {
      final individualResponse = await _apiClient.get('/individuals/$id');

      if (individualResponse.statusCode != 200 ||
          individualResponse.data is! Map) {
        throw Exception('The server returned an invalid individual record.');
      }

      if (!mounted) return;
      setState(() {
        _individual =
            Map<String, dynamic>.from(individualResponse.data as Map);
        _isLoading = false;
      });

      // Load prediction history separately so a prediction API issue does not
      // prevent the officer from viewing the individual's registration data.
      await Future.wait([_loadPredictions(id), _loadScreenings(id)]);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = _friendlyError(error);
      });
    }
  }

  Future<void> _loadPredictions(int individualId) async {
    try {
      final response = await _apiClient.get(
        '/ai-predictions/',
        queryParameters: {'individual_id': individualId},
      );

      if (response.statusCode != 200 || response.data is! List) {
        throw Exception('Invalid AI predictions response from server.');
      }

      final records = (response.data as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      records.sort((a, b) {
        final aDate = DateTime.tryParse((a['created_at'] ?? '').toString());
        final bDate = DateTime.tryParse((b['created_at'] ?? '').toString());
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      if (!mounted) return;
      setState(() {
        _predictions = records;
        _predictionError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _predictions = [];
        _predictionError = _friendlyError(error);
      });
    }
  }

  Future<void> _loadScreenings(int individualId) async {
    try {
      final response = await _apiClient.get(
        '/screenings/',
        queryParameters: {'individual_id': individualId},
      );
      if (response.statusCode != 200 || response.data is! List) {
        throw Exception('Invalid screenings response from server.');
      }
      final records = (response.data as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      if (!mounted) return;
      setState(() {
        _screenings = records;
        final selectedStillExists = records.any(
          (item) => item['id'] == _selectedScreeningId &&
              (item['status'] ?? '').toString().toLowerCase() == 'completed',
        );
        if (!selectedStillExists) {
          final firstCompleted = records.where((item) =>
              (item['status'] ?? '').toString().toLowerCase() == 'completed');
          _selectedScreeningId = firstCompleted.isEmpty
              ? null
              : int.tryParse(firstCompleted.first['id'].toString());
        }
        _screeningError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _screenings = [];
        _screeningError = _friendlyError(error);
      });
    }
  }

  Future<void> _runPrediction(String predictionType) async {
    final screeningId = _selectedScreeningId;
    if (screeningId == null || _runningPredictionType != null) return;

    setState(() {
      _runningPredictionType = predictionType;
      _predictionError = null;
    });
    try {
      await _apiClient.post(
        '/ai-predictions/run/$screeningId/$predictionType',
      );
      final individualId = _individualId;
      if (individualId != null) await _loadPredictions(individualId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${predictionType == 'diabetes' ? 'Diabetes' : 'Cardiovascular'} prediction completed and saved.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyError(error))),
      );
    } finally {
      if (mounted) setState(() => _runningPredictionType = null);
    }
  }

  String _friendlyError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
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

  String _value(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Not provided';
    }
    return value.toString();
  }

  List<Map<String, dynamic>> _predictionsFor(String type) {
    return _predictions.where((prediction) {
      return (prediction['prediction_type'] ?? '')
          .toString()
          .toLowerCase()
          .trim() == type;
    }).toList();
  }

  Map<String, dynamic>? _latestPrediction(String type) {
    final matching = _predictionsFor(type);
    return matching.isEmpty ? null : matching.first;
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
                      : _individual == null
                          ? _buildNotFound()
                          : _buildDetails(_individual!),
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
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: navy,
            ),
          ),
          const Spacer(),
          const Text(
            'Individual details',
            style: TextStyle(
              fontSize: 15,
              color: navy,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadScreen,
            icon: const Icon(Icons.refresh, color: navy, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Unable to load individual',
              style: TextStyle(
                color: navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: muted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _loadScreen,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound() {
    return const Center(
      child: Text(
        'No individual record found for this ID.',
        style: TextStyle(color: navy),
      ),
    );
  }

  Widget _buildDetails(Map<String, dynamic> person) {
    final name = _value(person['full_name']);
    final age = _ageFromDob(person['date_of_birth']);
    final code = _value(person['individual_code']);

    return RefreshIndicator(
      onRefresh: _loadScreen,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          _buildProfile(person, name, code, age),
          const SizedBox(height: 20),
          _sectionTitle('REGISTRATION STATUS', 'Account information'),
          const SizedBox(height: 12),
          _infoCard([
            _detailRow('Individual database ID', _value(person['id'])),
            _detailRow('Individual code', code),
            _detailRow('Household ID', _value(person['household_id'])),
            _detailRow(
              'Account status',
              person['is_active'] == true ? 'Active' : 'Inactive',
            ),
            _detailRow('Registered on', _formatDate(person['created_at'])),
          ]),
          const SizedBox(height: 20),
          _sectionTitle('PERSONAL DETAILS', 'Personal information'),
          const SizedBox(height: 12),
          _infoCard([
            _detailRow('Full name', name),
            _detailRow('Date of birth', _formatDate(person['date_of_birth'])),
            _detailRow('Age', age == null ? 'Not available' : '$age years'),
            _detailRow('Gender', _value(person['gender'])),
            _detailRow('Mobile number', _value(person['mobile_number'])),
            _detailRow('Blood group', _value(person['blood_group'])),
          ]),
          const SizedBox(height: 20),
          _sectionTitle('AI SCREENING ASSESSMENT', 'AI risk assessment'),
          const SizedBox(height: 12),
          _buildAiAssessment(),
          const SizedBox(height: 20),
          _sectionTitle('SCREENING RECORDS', 'Select a completed screening'),
          const SizedBox(height: 12),
          _buildScreeningActions(),
          const SizedBox(height: 20),
          _sectionTitle('PREDICTION HISTORY', 'Saved AI predictions'),
          const SizedBox(height: 12),
          _buildPredictionHistory(),
          const SizedBox(height: 20),
          _sectionTitle('HEALTH MEASUREMENTS', 'Latest screening readings'),
          const SizedBox(height: 12),
          _emptyDataCard(
            'Measurement history is not included in the individual details '
            'or AI prediction response. It requires the screening and '
            'measurement APIs.',
          ),
          const SizedBox(height: 20),
          _sectionTitle('REFERRAL & FOLLOW-UP', 'Care coordination'),
          const SizedBox(height: 12),
          _emptyDataCard(
            'Referral and follow-up information is not included in these '
            'responses. It will be displayed when the related records are '
            'connected.',
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(
    Map<String, dynamic> person,
    String name,
    String code,
    int? age,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFFE0ECFA),
          child: Text(
            _initials(name),
            style: const TextStyle(
              color: navy,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 19,
                  color: navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$code · ${age == null ? 'Age unavailable' : '$age years'} · '
                '${_value(person['gender'])}',
                style: const TextStyle(fontSize: 10, color: muted),
              ),
              const SizedBox(height: 5),
              Text(
                'Household ID: ${_value(person['household_id'])}',
                style: const TextStyle(fontSize: 10, color: muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAiAssessment() {
    if (_predictionError != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Unable to load AI prediction history.',
              style: TextStyle(
                color: navy,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _predictionError!,
              style: const TextStyle(color: muted, fontSize: 10),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  final id = _individualId;
                  if (id != null) _loadPredictions(id);
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            ),
          ],
        ),
      );
    }

    final diabetes = _latestPrediction('diabetes');
    final cardiovascular = _latestPrediction('cardiovascular');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _predictionSummaryRow(
            title: 'Diabetes',
            prediction: diabetes,
            icon: Icons.bloodtype_outlined,
            accent: const Color(0xFF2563EB),
          ),
          const Divider(height: 22),
          _predictionSummaryRow(
            title: 'Cardiovascular',
            prediction: cardiovascular,
            icon: Icons.favorite_outline,
            accent: const Color(0xFFE34D68),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFF5D99A)),
            ),
            child: const Text(
              'AI model outputs are experimental and not clinically validated. '
              'Risk categories are screening support only, not a diagnosis '
              'or a substitute for clinical assessment.',
              style: TextStyle(
                color: Color(0xFF805B19),
                fontSize: 9,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _predictionSummaryRow({
    required String title,
    required Map<String, dynamic>? prediction,
    required IconData icon,
    required Color accent,
  }) {
    final risk = prediction == null
        ? 'Not assessed'
        : _value(prediction['risk_level']);
    final confidence = prediction?['confidence_score'];
    final confidenceText = confidence is num
        ? '${(confidence * 100).toStringAsFixed(1)}%'
        : 'Not available';
    final experimental = prediction?['is_experimental'] == true;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 19,
          backgroundColor: accent.withValues(alpha: 0.10),
          child: Icon(icon, color: accent, size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  _riskChip(risk),
                  const SizedBox(width: 7),
                  if (prediction != null && experimental)
                    const Text(
                      'Experimental',
                      style: TextStyle(color: muted, fontSize: 9),
                    ),
                ],
              ),
              if (prediction != null) ...[
                const SizedBox(height: 5),
                Text(
                  'Confidence: $confidenceText · '
                  'Screening ID: ${_value(prediction['screening_id'])}',
                  style: const TextStyle(color: muted, fontSize: 9),
                ),
                const SizedBox(height: 3),
                Text(
                  'Recorded: ${_formatDate(prediction['created_at'])}',
                  style: const TextStyle(color: muted, fontSize: 9),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _riskChip(String risk) {
    final normalized = risk.toLowerCase();
    final Color foreground;
    final Color background;

    if (normalized == 'high') {
      foreground = const Color(0xFFB42318);
      background = const Color(0xFFFEE4E2);
    } else if (normalized == 'medium' || normalized == 'moderate') {
      foreground = const Color(0xFFB7791F);
      background = const Color(0xFFFFF1D6);
    } else if (normalized == 'low') {
      foreground = const Color(0xFF16845B);
      background = const Color(0xFFE1F5EC);
    } else {
      foreground = const Color(0xFF64748B);
      background = const Color(0xFFF0F2F5);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        risk,
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildScreeningActions() {
    if (_screeningError != null) {
      return _emptyDataCard('Could not load screening records: $_screeningError');
    }
    if (_screenings.isEmpty) {
      return _emptyDataCard('No screening records were found for this individual.');
    }

    final completed = _screenings.where((screening) =>
        (screening['status'] ?? '').toString().toLowerCase() == 'completed').toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: RadioGroup<int>(
        groupValue: _selectedScreeningId,
        onChanged: (int? value) {
          if (value == null) return;
          setState(() => _selectedScreeningId = value);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._screenings.map((screening) {
            final id = int.tryParse(screening['id'].toString());
            final status = (screening['status'] ?? 'unknown').toString();
            final isCompleted = status.toLowerCase() == 'completed';
            return RadioListTile<int>(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: id ?? -1,
              enabled: isCompleted && id != null,
              title: Text(
                'Screening #${id ?? '—'}',
                style: const TextStyle(
                  color: navy,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                '${_formatDate(screening['screening_date'])} · '
                '${status.replaceAll('_', ' ')}',
                style: const TextStyle(color: muted, fontSize: 10),
              ),
              activeColor: blue,
            );
          }),
          const SizedBox(height: 8),
          if (completed.isEmpty)
            const Text('AI predictions are enabled only after a screening is completed and the backend has validated its measurements.', style: TextStyle(color: muted, fontSize: 10, height: 1.4))
          else ...[
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: _selectedScreeningId == null || _runningPredictionType != null ? null : () => _runPrediction('diabetes'),
                  icon: _runningPredictionType == 'diabetes' ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.bloodtype_outlined, size: 16),
                  label: const Text('Diabetes'),
                )),
                const SizedBox(width: 9),
                Expanded(child: OutlinedButton.icon(
                  onPressed: _selectedScreeningId == null || _runningPredictionType != null ? null : () => _runPrediction('cardiovascular'),
                  icon: _runningPredictionType == 'cardiovascular' ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.favorite_outline, size: 16),
                  label: const Text('Cardiovascular'),
                )),
              ],
            ),
                        const Text(
              'Predictions use the selected completed screening. '
              'Missing required measurements may be rejected by the backend.',
              style: TextStyle(
                color: muted,
                fontSize: 9,
                height: 1.4,
              ),
            ),
          ],
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionHistory() {
    if (_predictionError != null) {
      return _emptyDataCard('Prediction history could not be loaded.');
    }

    if (_predictions.isEmpty) {
      return _emptyDataCard(
        'No saved AI prediction records were found for this individual.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: List.generate(_predictions.length, (index) {
          final prediction = _predictions[index];
          final type = (prediction['prediction_type'] ?? 'Unknown')
              .toString()
              .toUpperCase();
          final risk = _value(prediction['risk_level']);
          final confidence = prediction['confidence_score'];
          final confidenceText = confidence is num
              ? '${(confidence * 100).toStringAsFixed(1)}%'
              : 'Not available';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _riskChip(risk),
                ],
              ),
              const SizedBox(height: 7),
              _detailRow('Prediction ID', _value(prediction['id'])),
              _detailRow('Screening ID', _value(prediction['screening_id'])),
              _detailRow('Confidence', confidenceText),
              _detailRow(
                'Model status',
                prediction['is_experimental'] == true
                    ? 'Experimental'
                    : 'Non-experimental',
              ),
              _detailRow('Created', _formatDate(prediction['created_at'])),
              if (index != _predictions.length - 1)
                const Divider(height: 22),
            ],
          );
        }),
      ),
    );
  }

  Widget _sectionTitle(String label, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: blue,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            color: navy,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Column(children: children),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: muted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10,
                color: navy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyDataCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Text(
        message,
        style: const TextStyle(
          color: muted,
          fontSize: 11,
          height: 1.5,
        ),
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) return 'Not available';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day-$month-${parsed.year}';
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFE5EBF3)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
