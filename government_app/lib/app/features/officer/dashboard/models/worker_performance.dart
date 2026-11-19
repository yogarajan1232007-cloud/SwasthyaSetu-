class WorkerPerformance {
  // Worker information
  final int workerId;
  final String workerName;
  final String employeeId;
  final String employeeCode;
  final String designation;
  final String area;
  final bool isAvailable;
  final bool isActive;

  // Performance statistics
  final int assignedHouseholds;
  final int totalIndividuals;
  final int totalAssignments;
  final int pendingAssignments;
  final int completedAssignments;
  final int overdueAssignments;

  final int totalScreenings;
  final int completedScreenings;
  final int inProgressScreenings;
  final int todaysVisits;

  final int totalFollowups;
  final int pendingFollowups;
  final int completedFollowups;

  WorkerPerformance({
    required this.workerId,
    required this.workerName,
    required this.employeeId,
    required this.employeeCode,
    required this.designation,
    required this.area,
    required this.isAvailable,
    required this.isActive,
    required this.assignedHouseholds,
    required this.totalIndividuals,
    required this.totalAssignments,
    required this.pendingAssignments,
    required this.completedAssignments,
    required this.overdueAssignments,
    required this.totalScreenings,
    required this.completedScreenings,
    required this.inProgressScreenings,
    required this.todaysVisits,
    required this.totalFollowups,
    required this.pendingFollowups,
    required this.completedFollowups,
  });

  factory WorkerPerformance.fromJson(
    Map<String, dynamic> worker,
    Map<String, dynamic> dashboard,
  ) {
    int number(Map<String, dynamic> json, String key) {
      return (json[key] as num?)?.toInt() ?? 0;
    }

    return WorkerPerformance(
      workerId: number(worker, 'id'),
      workerName: worker['full_name'] ?? 'Unknown Worker',
      employeeId: worker['employee_id'] ?? '',
      employeeCode: worker['employee_code'] ?? '',
      designation: worker['designation'] ?? 'Health Worker',
      area: worker['area'] ?? 'Unassigned',
      isAvailable: worker['is_available'] ?? false,
      isActive: worker['is_active'] ?? false,

      assignedHouseholds: number(dashboard, 'assigned_households'),
      totalIndividuals: number(dashboard, 'total_individuals'),
      totalAssignments: number(dashboard, 'total_assignments'),
      pendingAssignments: number(dashboard, 'pending_assignments'),
      completedAssignments: number(dashboard, 'completed_assignments'),
      overdueAssignments: number(dashboard, 'overdue_assignments'),

      totalScreenings: number(dashboard, 'total_screenings'),
      completedScreenings: number(dashboard, 'completed_screenings'),
      inProgressScreenings: number(dashboard, 'in_progress_screenings'),
      todaysVisits: number(dashboard, 'todays_visits'),

      totalFollowups: number(dashboard, 'total_followups'),
      pendingFollowups: number(dashboard, 'pending_followups'),
      completedFollowups: number(dashboard, 'completed_followups'),
    );
  }
}