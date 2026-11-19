import 'package:material_ui/material_ui.dart';

class AddReminderScreen extends StatefulWidget {
  const AddReminderScreen({super.key});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  static const Color navy = Color(0xFF15385B);
  static const Color blue = Color(0xFF2864ED);
  static const Color muted = Color(0xFF71829B);
  static const Color background = Color(0xFFF3F7FC);

  DateTime selectedDate = DateTime(2026, 12, 18);
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

  String reminderType = 'Routine health screening';
  String reminderBefore = '1 day before';

  bool screeningReminder = true;
  bool followUpReminder = false;

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate.isBefore(DateTime.now())
          ? DateTime.now().add(const Duration(days: 1))
          : selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (time != null && mounted) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  void _saveReminder() {
    final now = DateTime.now();

    final scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (!scheduledDateTime.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a future date and time.'),
        ),
      );
      return;
    }

    if (!screeningReminder && !followUpReminder) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a reminder notification.'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      {
        'date': selectedDate,
        'time': selectedTime,
        'type': reminderType,
        'reminderBefore': reminderBefore,
        'screeningReminder': screeningReminder,
        'followUpReminder': followUpReminder,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(17),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeading(),

                    const SizedBox(height: 23),

                    _buildScreeningCard(),

                    const SizedBox(height: 22),

                    _buildDateTimeCard(),

                    const SizedBox(height: 20),

                    _buildReminderPreference(),

                    const SizedBox(height: 20),

                    _buildNotificationOptions(),

                    const SizedBox(height: 22),

                    _buildInformationCard(),

                    const SizedBox(height: 25),

                    _buildSaveButton(),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER

  Widget _buildHeader() {
    return Container(
      height: 49,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8EDF4),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: navy,
              size: 19,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Add Reminder',
                style: TextStyle(
                  color: navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 45),
        ],
      ),
    );
  }

  // HEADING

  Widget _buildHeading() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERSONAL HEALTH REMINDER',
          style: TextStyle(
            color: blue,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Stay on track with your health',
          style: TextStyle(
            color: navy,
            fontSize: 21,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 7),
        Text(
          'Set a reminder for your upcoming screening or follow-up.',
          style: TextStyle(
            color: muted,
            fontSize: 11,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // SCREENING CARD

  Widget _buildScreeningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.health_and_safety_outlined,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UPCOMING HEALTH SCREENING',
                  style: TextStyle(
                    color: Color(0xFF68DDD0),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '18 December 2026',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: Color(0xFF68DDD0),
            size: 21,
          ),
        ],
      ),
    );
  }

  // DATE AND TIME

  Widget _buildDateTimeCard() {
    return _sectionCard(
      title: 'Reminder date & time',
      subtitle: 'Choose when you want to be reminded.',
      child: Column(
        children: [
          _selectionTile(
            icon: Icons.calendar_month_outlined,
            title: 'Date',
            value:
                '${selectedDate.day.toString().padLeft(2, '0')} '
                '${_monthName(selectedDate.month)} '
                '${selectedDate.year}',
            onTap: _selectDate,
          ),
          const SizedBox(height: 11),
          _selectionTile(
            icon: Icons.access_time_rounded,
            title: 'Time',
            value: selectedTime.format(context),
            onTap: _selectTime,
          ),
        ],
      ),
    );
  }

  // REMINDER PREFERENCE

  Widget _buildReminderPreference() {
    return _sectionCard(
      title: 'Remind me',
      subtitle: 'Choose how early you want to receive a reminder.',
      child: RadioGroup<String>(
        groupValue: reminderBefore,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              reminderBefore = value;
            });
          }
        },
        child: Column(
          children: [
            _radioOption('On the same day'),
            _radioOption('1 day before'),
            _radioOption('1 week before'),
          ],
        ),
      ),
    );
  }

  Widget _radioOption(String value) {
    // ListTile needs its own Material surface when placed inside
    // the decorated reminder section card.
    return Material(
      color: Colors.white,
      child: RadioListTile<String>(
        value: value,
        activeColor: blue,
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(
          value,
          style: const TextStyle(
            color: navy,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  // NOTIFICATION OPTIONS

  Widget _buildNotificationOptions() {
    return _sectionCard(
      title: 'Notification preferences',
      subtitle: 'Select which reminders you want to receive.',
      child: Column(
        children: [
          Material(
            color: Colors.white,
            child: CheckboxListTile(
              value: screeningReminder,
              activeColor: blue,
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'Screening reminder',
                style: TextStyle(
                  color: navy,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Remind me about my routine health screening.',
                style: TextStyle(
                  color: muted,
                  fontSize: 9,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  screeningReminder = value ?? false;
                });
              },
            ),
          ),
          const Divider(height: 1),
          Material(
            color: Colors.white,
            child: CheckboxListTile(
              value: followUpReminder,
              activeColor: blue,
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'Follow-up reminder',
                style: TextStyle(
                  color: navy,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Remind me about my healthcare follow-up.',
                style: TextStyle(
                  color: muted,
                  fontSize: 9,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  followUpReminder = value ?? false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // INFORMATION CARD

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF54799F),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This reminder is for your personal health planning. '
              'It does not replace appointment confirmation from '
              'your healthcare provider.',
              style: TextStyle(
                color: navy,
                fontSize: 9,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SAVE BUTTON

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 49,
      child: ElevatedButton.icon(
        onPressed: _saveReminder,
        icon: const Icon(
          Icons.notifications_active_outlined,
          size: 18,
        ),
        label: const Text(
          'Save reminder',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // REUSABLE SECTION CARD

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFE2EAF3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: muted,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // SELECTION TILE

  Widget _selectionTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: blue,
              size: 20,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: navy,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: blue,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.chevron_right,
              color: muted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }
}
