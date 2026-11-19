


import 'package:material_ui/material_ui.dart';

import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import '../data/medical_report_service.dart';

class MedicalReportDetailsScreen extends StatefulWidget {
  final int reportId;

  const MedicalReportDetailsScreen({
    super.key,
    required this.reportId,
  });

  @override
  State<MedicalReportDetailsScreen> createState() =>
      _MedicalReportDetailsScreenState();
}

class _MedicalReportDetailsScreenState
    extends State<MedicalReportDetailsScreen> {
  final MedicalReportService _service = MedicalReportService();

  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F7FC);

  Map<String, dynamic>? _report;
  Map<String, dynamic>? _individual;

  bool _loading = true;
  bool _downloading = false;
  bool _updating = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  // ============================================================
  // LOAD REPORT DETAILS
  // ============================================================

  Future<void> _loadDetails() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final report = await _service.fetchReportDetails(
        widget.reportId,
      );

      final individualId = int.tryParse(
        report['individual_id']?.toString() ?? '',
      );

      Map<String, dynamic>? individual;

      if (individualId != null) {
        try {
          individual = await _service.fetchIndividual(individualId);
        } catch (_) {
          individual = null;
        }
      }

      if (!mounted) return;

      setState(() {
        _report = report;
        _individual = individual;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  // ============================================================
  // STATUS
  // ============================================================

  String get _status {
    return (_report?['verification_status'] ?? 'pending')
        .toString()
        .toLowerCase();
  }

  Color get _statusColor {
    switch (_status) {
      case 'verified':
        return const Color(0xFF15803D);
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFB76A00);
    }
  }

  // ============================================================
  // INDIVIDUAL NAME
  // ============================================================

  String get _individualName {
    return _individual?['full_name']?.toString() ??
        'Individual #${_report?['individual_id'] ?? '-'}';
  }

  // ============================================================
  // UPDATE VERIFICATION STATUS
  // ============================================================

  Future<void> _updateStatus(
    String status, {
    String? notes,
  }) async {
    if (_report == null) return;

    setState(() => _updating = true);

    try {
      final updated = await _service.updateReportStatus(
        reportId: widget.reportId,
        status: status,
        notes: notes,
      );

      if (!mounted) return;

      setState(() {
        _report = updated;
        _updating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Report ${status.toUpperCase()} successfully',
          ),
          backgroundColor: status == 'verified'
              ? Colors.green
              : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _updating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // ============================================================
  // REJECTION DIALOG
  // ============================================================

  Future<void> _showRejectDialog() async {
    final controller = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject Medical Report'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter rejection reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final value = controller.text.trim();

                if (value.isEmpty) return;

                Navigator.pop(dialogContext, value);
              },
              child: const Text('Reject Report'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (reason == null || reason.isEmpty) return;

    final existingNotes = _report?['notes']?.toString() ?? '';

    final updatedNotes = existingNotes.isEmpty
        ? 'Rejection reason: $reason'
        : '$existingNotes\nRejection reason: $reason';

    await _updateStatus(
      'rejected',
      notes: updatedNotes,
    );
  }

  // ============================================================
  // DOWNLOAD AND OPEN REPORT
  // ============================================================

  Future<void> _downloadAndOpen() async {
    if (_report == null) return;

    setState(() => _downloading = true);

    try {
      final directory = await getApplicationDocumentsDirectory();

      final format =
          (_report!['file_format'] ?? 'pdf').toString().toLowerCase();

      final extension = format == 'jpeg' ? 'jpg' : format;

      final reportName = 'medical_report_${widget.reportId}.$extension';

      final savePath = '${directory.path}/$reportName';

      final path = await _service.downloadReport(
        reportId: widget.reportId,
        savePath: savePath,
      );

      if (!mounted) return;

      final result = await OpenFilex.open(path);

      if (!mounted) return;

      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File downloaded, but could not be opened: ${result.message}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _downloading = false);
      }
    }
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _infoCard({
    required String title,
    required String value,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE5EBF3),
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: blue, size: 20),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF718096),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 12,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: navy,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        title: const Text(
          'Report Details',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadDetails,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
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
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: _loadDetails,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _report == null
                  ? const Center(child: Text('Report not found'))
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    final report = _report!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // REPORT HEADER

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE5EBF3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.description_outlined,
                color: blue,
                size: 35,
              ),
              const SizedBox(height: 12),
              Text(
                report['report_name']?.toString() ?? 'Medical Report',
                style: const TextStyle(
                  color: navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Report ID: ${report['id']}',
                style: const TextStyle(
                  color: Color(0xFF718096),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _status.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),

        // INDIVIDUAL DETAILS

        _sectionTitle('Individual Information'),

        _infoCard(
          title: 'Individual Name',
          value: _individualName,
          icon: Icons.person_outline,
        ),

        _infoCard(
          title: 'Individual Code',
          value: _individual?['individual_code']?.toString() ?? '-',
          icon: Icons.badge_outlined,
        ),

        _infoCard(
          title: 'Individual ID',
          value: report['individual_id']?.toString() ?? '-',
        ),

        // REPORT DETAILS

        _sectionTitle('Medical Report Information'),

        _infoCard(
          title: 'Report Type',
          value: report['report_type']?.toString() ?? '-',
          icon: Icons.medical_information_outlined,
        ),

        _infoCard(
          title: 'Report Date',
          value: report['report_date']?.toString() ?? '-',
          icon: Icons.calendar_today_outlined,
        ),

        _infoCard(
          title: 'File Format',
          value: report['file_format']?.toString().toUpperCase() ?? '-',
          icon: Icons.insert_drive_file_outlined,
        ),

        _infoCard(
          title: 'Screening ID',
          value: report['screening_id']?.toString() ?? '-',
        ),

        _infoCard(
          title: 'Uploaded By',
          value: report['uploaded_by']?.toString() ?? '-',
        ),

        _infoCard(
          title: 'Created At',
          value: report['created_at']?.toString() ?? '-',
        ),

        // NOTES

        _sectionTitle('Report Notes'),

        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: const Color(0xFFE5EBF3),
            ),
          ),
          child: Text(
            report['notes']?.toString().isNotEmpty == true
                ? report['notes'].toString()
                : 'No notes available.',
            style: const TextStyle(
              color: navy,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ),

        // DOWNLOAD

        _sectionTitle('Report Document'),

        SizedBox(
          height: 49,
          child: ElevatedButton.icon(
            onPressed: _downloading ? null : _downloadAndOpen,
            icon: _downloading
                ? const SizedBox(
                    height: 17,
                    width: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.download_outlined),
            label: Text(
              _downloading
                  ? 'Downloading...'
                  : 'Download & Open Report',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: navy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
          ),
        ),

        // VERIFICATION ACTIONS

        if (_status == 'pending') ...[
          _sectionTitle('Verification Actions'),

          SizedBox(
            height: 49,
            child: ElevatedButton.icon(
              onPressed: _updating
                  ? null
                  : () => _updateStatus('verified'),
              icon: const Icon(Icons.verified_outlined),
              label: const Text('Verify Medical Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 49,
            child: OutlinedButton.icon(
              onPressed: _updating ? null : _showRejectDialog,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Reject Medical Report'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
        ],

        if (_updating) ...[
          const SizedBox(height: 15),
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],

        const SizedBox(height: 35),
      ],
    );
  }
}
