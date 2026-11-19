import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../data/medical_report_service.dart';

class MedicalReportsScreen extends StatefulWidget {
  const MedicalReportsScreen({super.key});

  @override
  State<MedicalReportsScreen> createState() =>
      _MedicalReportsScreenState();
}

class _MedicalReportsScreenState extends State<MedicalReportsScreen> {
  final MedicalReportService _service = MedicalReportService();

  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F7FC);

  List<Map<String, dynamic>> _reports = [];
  Map<int, Map<String, dynamic>> _individuals = {};

  bool _loading = true;
  String? _error;

  String _search = '';
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final reports = await _service.fetchReports();

      final ids = reports
          .map((r) => int.tryParse(r['individual_id']?.toString() ?? ''))
          .whereType<int>()
          .toSet();

      final results = await Future.wait(
        ids.map((id) async {
          try {
            return MapEntry(id, await _service.fetchIndividual(id));
          } catch (_) {
            return MapEntry(id, <String, dynamic>{});
          }
        }),
      );

      if (!mounted) return;

      setState(() {
        _reports = reports;
        _individuals = Map.fromEntries(results);
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

  String _status(Map<String, dynamic> report) {
    return (report['verification_status'] ?? 'pending')
        .toString()
        .toLowerCase();
  }

  String _individualName(Map<String, dynamic> report) {
    final id = int.tryParse(
      report['individual_id']?.toString() ?? '',
    );

    if (id == null) return 'Unknown individual';

    final person = _individuals[id];

    if (person == null || person.isEmpty) {
      return 'Individual #$id';
    }

    final name = person['full_name']?.toString();

    return name != null && name.trim().isNotEmpty
        ? name
        : 'Individual #$id';
  }

  List<Map<String, dynamic>> get _filteredReports {
    return _reports.where((report) {
      final name = _individualName(report).toLowerCase();
      final id = (report['individual_id'] ?? '').toString();
      final reportName =
          (report['report_name'] ?? '').toString().toLowerCase();

      final matchesSearch = name.contains(_search) ||
          id.contains(_search) ||
          reportName.contains(_search);

      final matchesFilter =
          _filter == 'All' || _status(report) == _filter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int _count(String status) {
    return _reports.where((r) => _status(r) == status).length;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'verified':
        return const Color(0xFF15803D);
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFB76A00);
    }
  }

  IconData _fileIcon(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Widget _statCard(
    String title,
    int value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          const SizedBox(height: 11),
          Text(
            value.toString(),
            style: const TextStyle(
              color: navy,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _reportCard(Map<String, dynamic> report) {
    final status = _status(report);
    final color = _statusColor(status);
    final format = report['file_format']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5EBF3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          final id = report['id'];
          context.push('/medical-report-details/$id');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: const Color(0xFFE0ECFA),
                    child: Icon(
                      _fileIcon(format),
                      color: blue,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report['report_name']?.toString() ??
                              'Untitled report',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _individualName(report),
                          style: const TextStyle(
                            color: Color(0xFF718096),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: navy),
                ],
              ),
              const SizedBox(height: 13),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _chip(
                    'Type: ${report['report_type'] ?? '-'}',
                    blue,
                  ),
                  _chip(
                    format.isEmpty ? 'Unknown format' : format.toUpperCase(),
                    const Color(0xFF64748B),
                  ),
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
                      report['report_date']?.toString() ??
                          'Date unavailable',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 10,
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
    );
  }

  Future<void> _openUploadScreen() async {
    await context.push('/upload-medical-report');

    if (!mounted) return;

    _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredReports;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
        title: const Text(
          'Medical Reports',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh reports',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUploadScreen,
        backgroundColor: navy,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload Report'),
      ),
      body: _loading
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
                          onPressed: _loadReports,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'LABORATORY & HEALTH RECORDS',
                        style: TextStyle(
                          color: blue,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Medical Reports',
                        style: TextStyle(
                          color: navy,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Review and verify uploaded medical documents.',
                        style: TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 112,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _statCard(
                              'Total Reports',
                              _reports.length,
                              Icons.folder_outlined,
                              blue,
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              'Pending',
                              _count('pending'),
                              Icons.pending_actions,
                              const Color(0xFFB76A00),
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              'Verified',
                              _count('verified'),
                              Icons.verified_outlined,
                              const Color(0xFF15803D),
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              'Rejected',
                              _count('rejected'),
                              Icons.cancel_outlined,
                              const Color(0xFFDC2626),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _search = value.trim().toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search report or individual',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'All',
                            'Pending',
                            'Verified',
                            'Rejected',
                          ].map((filter) {
                            final selected = _filter == filter;

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
                                onSelected: (_) {
                                  setState(() {
                                    _filter = filter;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'REPORT RECORDS',
                            style: TextStyle(
                              color: navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${filtered.length} reports',
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
                              'No medical reports found.',
                              style: TextStyle(color: navy),
                            ),
                          ),
                        ),
                      ...filtered.map(_reportCard),
                      const SizedBox(height: 75),
                    ],
                  ),
                ),
    );
  }
}