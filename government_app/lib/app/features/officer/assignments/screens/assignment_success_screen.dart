import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class AssignmentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> assignment;

  const AssignmentSuccessScreen({
    super.key,
    required this.assignment,
  });

  static const Color blue = Color(0xFF2563EB);
  static const Color navy = Color(0xFF15365B);

  String formatDate(dynamic value) {
    if (value is! DateTime) {
      return value?.toString() ?? 'Not available';
    }

    return '${value.day.toString().padLeft(2, '0')} '
        '${_monthName(value.month)} ${value.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final assignmentId = assignment['id']?.toString() ?? 'N/A';
    final worker = assignment['workerName']?.toString() ?? 'N/A';
    final workerId = assignment['workerId']?.toString() ?? 'N/A';
    final area = assignment['area']?.toString() ?? 'N/A';

    final households =
        assignment['householdCount']?.toString() ?? '0';

    final individuals =
        assignment['individuals']?.toString() ?? '0';

    final assignmentDate =
        formatDate(assignment['assignmentDate']);

    final dueDate = formatDate(assignment['dueDate']);

    final status = assignment['status']?.toString() ?? 'Active';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,

        title: const Text(
          'Assignment created',
          style: TextStyle(
            color: navy,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),

        centerTitle: true,
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Container(
              width: double.infinity,

              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE5EBF3),
                ),
              ),

              child: Column(
                children: [
                  // SUCCESS ICON
                  Container(
                    height: 65,
                    width: 65,

                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F8EF),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF16A34A),
                      size: 36,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Assignment created',
                    textAlign: TextAlign.center,

                    style: TextStyle(
                      color: navy,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '$households households have been assigned to $worker.',
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '$individuals estimated individuals are included in this assignment.',
                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Color(0xFF718096),
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ASSIGNMENT DETAILS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7FC),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Column(
                      children: [
                        _detail('Assignment ID', assignmentId),
                        const SizedBox(height: 12),

                        _detail('Area', area),
                        const SizedBox(height: 12),

                        _detail('Health worker', worker),
                        const SizedBox(height: 12),

                        _detail('Worker ID', workerId),
                        const SizedBox(height: 12),

                        _detail('Households', households),
                        const SizedBox(height: 12),

                        _detail('Individuals', individuals),
                        const SizedBox(height: 12),

                        _detail('Assignment date', assignmentDate),
                        const SizedBox(height: 12),

                        _detail('Due date', dueDate),
                        const SizedBox(height: 12),

                        _detail('Status', status),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // BACK TO WORKERS
                  SizedBox(
                    width: double.infinity,
                    height: 46,

                    child: ElevatedButton(
                      onPressed: () {
                        context.goNamed('workers');
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                        elevation: 2,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),

                      child: const Text(
                        'Back to workers',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BACK TO DASHBOARD
                  TextButton(
                    onPressed: () {
                      context.goNamed('dashboard');
                    },

                    child: const Text(
                      'Go to dashboard',
                      style: TextStyle(
                        color: blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF718096),
              fontSize: 11,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,

            style: const TextStyle(
              color: navy,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}