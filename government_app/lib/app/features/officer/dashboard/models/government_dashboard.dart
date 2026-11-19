class GovernmentDashboard {
  // Population statistics
  final int totalPopulation;
  final int malePopulation;
  final int femalePopulation;
  final int seniorCitizens;
  final int children;
  final int activePopulation;

  // Household statistics
  final int totalHouseholds;
  final int assignedHouseholds;
  final int unassignedHouseholds;

  // Worker statistics
  final int totalWorkers;
  final int availableWorkers;
  final int unavailableWorkers;

  // Screening statistics
  final int totalScreenings;
  final int completedScreenings;
  final int uniqueIndividualsScreened;
  final int inProgressScreenings;

  // Assignment statistics
  final int totalAssignments;
  final int pendingAssignments;
  final int completedAssignments;
  final int overdueAssignments;

  // AI prediction statistics (for future integration)
  final int totalPredictions;
  final int experimentalPredictions;
  final int nonExperimentalPredictions;
  final int diabetesPredictions;
  final int cardiovascularPredictions;
  final int lowRiskPredictions;
  final int mediumRiskPredictions;
  final int highRiskPredictions;

  // Alert statistics (for future integration)
  final int totalAlerts;
  final int openAlerts;
  final int criticalAlerts;
  final int resolvedAlerts;

  // Referral statistics
  final int totalReferrals;
  final int pendingReferrals;
  final int scheduledReferrals;
  final int completedReferrals;

  GovernmentDashboard({
    required this.totalPopulation,
    required this.malePopulation,
    required this.femalePopulation,
    required this.seniorCitizens,
    required this.children,
    required this.activePopulation,
    required this.totalHouseholds,
    required this.assignedHouseholds,
    required this.unassignedHouseholds,
    required this.totalWorkers,
    required this.availableWorkers,
    required this.unavailableWorkers,
    required this.totalScreenings,
    required this.completedScreenings,
    required this.uniqueIndividualsScreened,
    required this.inProgressScreenings,
    required this.totalAssignments,
    required this.pendingAssignments,
    required this.completedAssignments,
    required this.overdueAssignments,
    required this.totalPredictions,
    required this.experimentalPredictions,
    required this.nonExperimentalPredictions,
    required this.diabetesPredictions,
    required this.cardiovascularPredictions,
    required this.lowRiskPredictions,
    required this.mediumRiskPredictions,
    required this.highRiskPredictions,
    required this.totalAlerts,
    required this.openAlerts,
    required this.criticalAlerts,
    required this.resolvedAlerts,
    required this.totalReferrals,
    required this.pendingReferrals,
    required this.scheduledReferrals,
    required this.completedReferrals,
  });

  // Safely convert API values into integers.
  factory GovernmentDashboard.fromJson(Map<String, dynamic> json) {
    int number(String key) {
      final value = json[key];

      if (value is num) {
        return value.toInt();
      }

      if (value is String) {
        return int.tryParse(value) ?? 0;
      }

      return 0;
    }

    return GovernmentDashboard(
      // Population
      totalPopulation: number('total_population'),
      malePopulation: number('male_population'),
      femalePopulation: number('female_population'),
      seniorCitizens: number('senior_citizens'),
      children: number('children'),
      activePopulation: number('active_population'),

      // Households
      totalHouseholds: number('total_households'),
      assignedHouseholds: number('assigned_households'),
      unassignedHouseholds: number('unassigned_households'),

      // Workers
      totalWorkers: number('total_workers'),
      availableWorkers: number('available_workers'),
      unavailableWorkers: number('unavailable_workers'),

      // Screenings
      totalScreenings: number('total_screenings'),
      completedScreenings: number('completed_screenings'),
      uniqueIndividualsScreened:
          number('unique_individuals_screened'),
      inProgressScreenings: number('in_progress_screenings'),

      // Assignments
      totalAssignments: number('total_assignments'),
      pendingAssignments: number('pending_assignments'),
      completedAssignments: number('completed_assignments'),
      overdueAssignments: number('overdue_assignments'),

      // AI Predictions
      totalPredictions: number('total_predictions'),
      experimentalPredictions: number('experimental_predictions'),
      nonExperimentalPredictions:
          number('non_experimental_predictions'),
      diabetesPredictions: number('diabetes_predictions'),
      cardiovascularPredictions:
          number('cardiovascular_predictions'),
      lowRiskPredictions: number('low_risk_predictions'),
      mediumRiskPredictions: number('medium_risk_predictions'),
      highRiskPredictions: number('high_risk_predictions'),

      // Alerts
      totalAlerts: number('total_alerts'),
      openAlerts: number('open_alerts'),
      criticalAlerts: number('critical_alerts'),
      resolvedAlerts: number('resolved_alerts'),

      // Referrals
      totalReferrals: number('total_referrals'),
      pendingReferrals: number('pending_referrals'),
      scheduledReferrals: number('scheduled_referrals'),
      completedReferrals: number('completed_referrals'),
    );
  }
}