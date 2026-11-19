import 'package:material_ui/material_ui.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/network/api_client.dart';
import '../data/medical_report_service.dart';

class UploadMedicalReportScreen extends StatefulWidget {
  const UploadMedicalReportScreen({super.key});

  @override
  State<UploadMedicalReportScreen> createState() =>
      _UploadMedicalReportScreenState();
}

class _UploadMedicalReportScreenState
    extends State<UploadMedicalReportScreen> {
  final MedicalReportService _service = MedicalReportService();
  final ApiClient _apiClient = ApiClient();

  static const Color navy = Color(0xFF15365B);
  static const Color blue = Color(0xFF2563EB);
  static const Color background = Color(0xFFF4F7FC);

  final _formKey = GlobalKey<FormState>();

  final _reportNameController = TextEditingController();
  final _notesController = TextEditingController();

  List<Map<String, dynamic>> _individuals = [];
  List<Map<String, dynamic>> _screenings = [];

  int? _selectedIndividualId;
  int? _selectedScreeningId;

  String _reportType = 'Laboratory Report';

  String? _filePath;
  String? _fileName;
  String? _fileExtension;

  bool _loading = true;
  bool _uploading = false;

  String? _loadError;

  final List<String> _reportTypes = [
    'Laboratory Report',
    'Blood Test',
    'Urine Test',
    'ECG Report',
    'Medical Certificate',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  @override
  void dispose() {
    _reportNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD INDIVIDUALS AND SCREENINGS
  // ============================================================

  Future<void> _loadDropdownData() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }

    try {
      final responses = await Future.wait([
        _apiClient.get('/individuals/'),
        _apiClient.get('/screenings/'),
      ]);

      final individualsResponse = responses[0].data;
      final screeningsResponse = responses[1].data;

      if (individualsResponse is! List) {
        throw Exception('Invalid individuals response');
      }

      if (screeningsResponse is! List) {
        throw Exception('Invalid screenings response');
      }

      if (!mounted) return;

      setState(() {
        _individuals = individualsResponse
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

        _screenings = screeningsResponse
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadError = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  // ============================================================
  // AVAILABLE SCREENINGS FOR SELECTED INDIVIDUAL
  // ============================================================

  List<Map<String, dynamic>> get _availableScreenings {
    if (_selectedIndividualId == null) return [];

    return _screenings.where((screening) {
      final individualId = int.tryParse(
        screening['individual_id']?.toString() ?? '',
      );

      return individualId == _selectedIndividualId;
    }).toList();
  }

  // ============================================================
  // INDIVIDUAL NAME
  // ============================================================

  String _individualName(Map<String, dynamic> individual) {
    final name = individual['full_name']?.toString();

    if (name != null && name.trim().isNotEmpty) {
      return name;
    }

    return 'Individual #${individual['id']}';
  }

  // ============================================================
  // FILE PICKER - FILE_PICKER 13.4.0
  // ============================================================

  Future<void> _selectFile() async {
    try {
      final PlatformFile? file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (file == null) return;

      final extension = file.extension?.toLowerCase();

      if (extension == null ||
          !['pdf', 'jpg', 'jpeg', 'png'].contains(extension)) {
        _showMessage(
          'Unsupported file format.',
          isError: true,
        );
        return;
      }

      if (file.path == null || file.path!.isEmpty) {
        _showMessage(
          'Unable to access the selected file path.',
          isError: true,
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        _filePath = file.path;
        _fileName = file.name;
        _fileExtension = extension;
      });

      if (_reportNameController.text.trim().isEmpty) {
        _reportNameController.text =
            file.name.replaceFirst(RegExp(r'\.[^.]+$'), '');
      }
    } catch (error) {
      _showMessage(
        'File selection failed: $error',
        isError: true,
      );
    }
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : const Color(0xFF15803D),
      ),
    );
  }

  // ============================================================
  // UPLOAD MEDICAL REPORT
  // ============================================================

  Future<void> _uploadReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedIndividualId == null) {
      _showMessage(
        'Please select an individual.',
        isError: true,
      );
      return;
    }

    if (_filePath == null) {
      _showMessage(
        'Please select a report file.',
        isError: true,
      );
      return;
    }

    setState(() {
      _uploading = true;
    });

    try {
      await _service.uploadReport(
        individualId: _selectedIndividualId!,
        screeningId: _selectedScreeningId,
        reportType: _reportType,
        reportName: _reportNameController.text.trim(),
        filePath: _filePath!,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;

      _showMessage('Medical report uploaded successfully.');

      Navigator.of(context).pop(true);
    } catch (error) {
      _showMessage(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: blue, size: 19),
          const SizedBox(width: 9),
          Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: blue),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE5EBF3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE5EBF3),
        ),
      ),
    );
  }

  // ============================================================
  // FILE PICKER CARD
  // ============================================================

  Widget _buildFilePicker() {
    final selected = _filePath != null;

    return InkWell(
      onTap: _uploading ? null : _selectFile,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFEFF6FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? blue : const Color(0xFFD5DEEA),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              selected
                  ? Icons.insert_drive_file
                  : Icons.cloud_upload_outlined,
              size: 38,
              color: blue,
            ),
            const SizedBox(height: 12),
            Text(
              selected ? _fileName! : 'Select Medical Report',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              selected
                  ? '${_fileExtension!.toUpperCase()} file selected'
                  : 'PDF, JPG, JPEG or PNG',
              style: const TextStyle(
                color: Color(0xFF718096),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              selected ? 'Change File' : 'Browse Files',
              style: const TextStyle(
                color: blue,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOADING ERROR VIEW
  // ============================================================

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 42,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 12),
            Text(
              _loadError ?? 'Unable to load data.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadDropdownData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Upload Medical Report',
          style: TextStyle(
            color: navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _loadError != null
              ? _buildErrorView()
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Header card
                      Container(
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: navy,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.medical_information_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Medical Document Upload',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Upload laboratory reports and medical '
                              'records for registered individuals.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Individual information
                      _sectionTitle(
                        'Individual Information',
                        Icons.person_outline,
                      ),

                      DropdownButtonFormField<int>(
                        key: ValueKey(_selectedIndividualId),
                        initialValue: _selectedIndividualId,
                        isExpanded: true,
                        decoration: _inputDecoration(
                          'Select Individual',
                          Icons.person,
                        ),
                        items: _individuals.map((individual) {
                          final id = int.tryParse(
                            individual['id']?.toString() ?? '',
                          );

                          if (id == null) return null;

                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(
                              '${_individualName(individual)} (ID: $id)',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).whereType<DropdownMenuItem<int>>().toList(),
                        onChanged: _uploading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedIndividualId = value;
                                  _selectedScreeningId = null;
                                });
                              },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an individual';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 15),

                      // Associated screening
                      DropdownButtonFormField<int?>(
                        key: ValueKey(
                          '$_selectedIndividualId$_selectedScreeningId',
                        ),
                        initialValue: _selectedScreeningId,
                        isExpanded: true,
                        decoration: _inputDecoration(
                          'Associated Screening (Optional)',
                          Icons.assignment_outlined,
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('No screening selected'),
                          ),
                          ..._availableScreenings.map((screening) {
                            final id = int.tryParse(
                              screening['id']?.toString() ?? '',
                            );

                            return DropdownMenuItem<int?>(
                              value: id,
                              child: Text(
                                'Screening #${id ?? '-'} - '
                                '${screening['status'] ?? 'Unknown'}',
                              ),
                            );
                          }),
                        ],
                        onChanged: _uploading
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedScreeningId = value;
                                });
                              },
                      ),

                      const SizedBox(height: 24),

                      // Report information
                      _sectionTitle(
                        'Report Information',
                        Icons.description_outlined,
                      ),

                      DropdownButtonFormField<String>(
                        key: ValueKey(_reportType),
                        initialValue: _reportType,
                        isExpanded: true,
                        decoration: _inputDecoration(
                          'Report Type',
                          Icons.category_outlined,
                        ),
                        items: _reportTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: _uploading
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() {
                                    _reportType = value;
                                  });
                                }
                              },
                      ),

                      const SizedBox(height: 15),

                      // Report name
                      TextFormField(
                        controller: _reportNameController,
                        enabled: !_uploading,
                        decoration: _inputDecoration(
                          'Report Name',
                          Icons.title,
                          hint: 'Enter report name',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter report name';
                          }

                          if (value.trim().length < 2) {
                            return 'Report name must contain at least 2 characters';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Attachment
                      _sectionTitle(
                        'Attach Document',
                        Icons.attach_file,
                      ),

                      _buildFilePicker(),

                      const SizedBox(height: 24),

                      // Additional information
                      _sectionTitle(
                        'Additional Information',
                        Icons.notes_outlined,
                      ),

                      TextFormField(
                        controller: _notesController,
                        enabled: !_uploading,
                        maxLines: 4,
                        decoration: _inputDecoration(
                          'Notes',
                          Icons.edit_note,
                          hint: 'Enter additional notes (optional)',
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Upload button
                      SizedBox(
                        height: 53,
                        child: ElevatedButton.icon(
                          onPressed: _uploading ? null : _uploadReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navy,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                navy.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          icon: _uploading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.cloud_upload_outlined,
                                ),
                          label: Text(
                            _uploading
                                ? 'Uploading Report...'
                                : 'Upload Medical Report',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }
}