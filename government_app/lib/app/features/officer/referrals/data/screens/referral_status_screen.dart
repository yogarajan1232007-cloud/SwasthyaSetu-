import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../services/referral_api_service.dart';

class ReferralStatusScreen extends StatefulWidget {
  final Map<String, dynamic> referral;

  const ReferralStatusScreen({
    super.key,
    required this.referral,
  });

  @override
  State<ReferralStatusScreen> createState() => _ReferralStatusScreenState();
}

class _ReferralStatusScreenState extends State<ReferralStatusScreen> {
  final ReferralApiService _apiService = ReferralApiService();
  final TextEditingController remarksController = TextEditingController();

  late String selectedStatus;
  bool isSaving = false;
  String? errorMessage;

  static const List<String> statuses = [
    'Pending',
    'Referred',
    'Scheduled',
    'In Progress',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    selectedStatus = _displayStatus(widget.referral['status']);
    remarksController.text = widget.referral['notes']?.toString() ??
        widget.referral['remarks']?.toString() ?? '';
  }

  String _displayStatus(dynamic value) {
    final raw = (value ?? 'pending').toString().toLowerCase();
    switch (raw) {
      case 'in_progress':
      case 'in progress':
        return 'In Progress';
      default:
        return raw.isEmpty
            ? 'Pending'
            : raw[0].toUpperCase() + raw.substring(1);
    }
  }

  String _apiStatus(String value) =>
      value.toLowerCase().replaceAll(' ', '_');

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  Future<void> _saveStatus() async {
    final referralId = int.tryParse(widget.referral['id'].toString());
    if (referralId == null) {
      setState(() => errorMessage = 'Invalid referral ID.');
      return;
    }

    setState(() {
      isSaving = true;
      errorMessage = null;
    });

    try {
      await _apiService.updateReferral(
        referralId: referralId,
        status: _apiStatus(selectedStatus),
        notes: remarksController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Referral status updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isSaving = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'Scheduled':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _value(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? 'Not provided' : text;
  }

  @override
  Widget build(BuildContext context) {
    final referral = widget.referral;
    final status = _displayStatus(referral['status']);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text('Update referral status'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF16365C),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'REFERRAL INFORMATION',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Referral #${_value(referral['id'])}',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Individual ID: ${_value(referral['individual_id'])}'),
                Text('Facility: ${_value(referral['facility_name'])}'),
                Text('Reason: ${_value(referral['reason'])}'),
                const SizedBox(height: 12),
                Text(
                  'Current status: $status',
                  style: TextStyle(
                    color: _statusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'UPDATE STATUS',
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedStatus,
                isExpanded: true,
                items: statuses.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: isSaving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => selectedStatus = value);
                        }
                      },
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'OFFICER REMARKS',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: remarksController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter consultation or follow-up remarks...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isSaving ? null : _saveStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
