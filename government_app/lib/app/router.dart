
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

// =====================================================
// AUTHENTICATION
// =====================================================

import 'features/authentication/screens/login_screen.dart';

// =====================================================
// RESPONSIVE OFFICER SHELL
// =====================================================

import 'core/widgets/responsive_officer_shell.dart';

// =====================================================
// OFFICER DASHBOARD
// =====================================================

import 'features/officer/dashboard/dashboard_screen.dart';

// =====================================================
// ANALYTICS
// =====================================================

import 'features/officer/analytics/reports_screen.dart';

// =====================================================
// RISK MONITORING
// =====================================================

import 'features/officer/risk_monitoring/screens/alerts_screen.dart';
import 'features/officer/risk_monitoring/screens/individual_risk_screen.dart';
import 'features/officer/risk_monitoring/screens/risk_monitoring_screen.dart';
import 'features/officer/risk_monitoring/screens/high_risk_individuals_screen.dart';

// =====================================================
// REFERRAL MANAGEMENT
// =====================================================

import 'features/officer/referrals/data/screens/referral_management_screen.dart';
import 'features/officer/referrals/data/screens/schedule_confirmation_screen.dart';
import 'features/officer/referrals/data/screens/referral_status_screen.dart';

// =====================================================
// HEALTH WORKER MANAGEMENT
// =====================================================

import 'features/officer/workers/screens/worker_management_screen.dart';
import 'features/officer/workers/screens/add_worker_screen.dart';
import 'features/officer/workers/screens/worker_individuals_screen.dart';
import 'features/officer/workers/screens/edit_worker_screen.dart';
import 'features/officer/workers/screens/worker_performance_screen.dart';

// =====================================================
// ASSIGNMENT MANAGEMENT
// =====================================================

import 'features/officer/assignments/screens/create_assignment_screen.dart';
import 'features/officer/assignments/screens/assignment_success_screen.dart';
import 'features/officer/assignments/screens/assignment_management_screen.dart';
import 'features/officer/assignments/screens/assignment_details_screen.dart';

// =====================================================
// INDIVIDUALS
// =====================================================

import 'features/officer/individuals/screens/individuals_screen.dart';

// =====================================================
// HOUSEHOLD MANAGEMENT
// =====================================================

import 'features/officer/households/data/screens/household_registration_screen.dart';
import 'features/officer/households/data/screens/household_management_screen.dart';
import 'features/officer/households/data/screens/household_details_screen.dart';
import 'features/officer/households/data/screens/consent_management_screen.dart';
import 'features/officer/households/data/screens/individual_registration_screen.dart';
import 'features/officer/households/data/individuals/individual_details_screen.dart';
import 'features/officer/households/data/individuals/individual_edit_screen.dart';

// =====================================================
// MORE / ALL SERVICES
// =====================================================

import 'features/officer/more/screens/all_services_screen.dart';
import 'features/officer/areas/screens/area_management_screen.dart';

// =====================================================
// FOLLOW-UPS
// =====================================================

import 'features/officer/followups/screens/followups_screen.dart';

// =====================================================
// OFFICER SCREENING MONITORING
// =====================================================

import 'features/officer/screenings/screens/screening_monitoring_screen.dart';
import 'features/officer/screenings/screens/screening_details_screen.dart';

// =====================================================
// OFFICER MEDICAL REPORTS
// =====================================================

import 'features/officer/medical_reports/screens/medical_reports_screen.dart';
import 'features/officer/medical_reports/screens/medical_report_details_screen.dart';
import 'features/officer/medical_reports/screens/upload_medical_report_screen.dart';

// =====================================================
// WORKER APP
// =====================================================

import 'features/worker/dashboard/screens/worker_dashboard_screen.dart';
import 'features/worker/households/screens/assigned_households_screen.dart';
import 'features/worker/households/screens/worker_household_details_screen.dart';

import 'features/worker/screening/screens/personal_details_screen.dart';
import 'features/worker/screening/screens/consent_capture_screen.dart';
import 'features/worker/screening/screens/medical_history_screen.dart';
import 'features/worker/screening/screens/measurements_screen.dart';
import 'features/worker/screening/screens/measurement_review_screen.dart';
import 'features/worker/screening/screens/screening_summary_screen.dart';
import 'features/worker/screening/screens/screening_result_screen.dart';

import 'features/worker/visits/screens/worker_visits_screen.dart';
import 'features/worker/followups/screens/worker_followups_screen.dart';
import 'features/worker/profile/screens/worker_profile_screen.dart';

// =====================================================
// OFFICER SHELL HELPER
// =====================================================

Widget _officerPage(Widget child) {
  return ResponsiveOfficerShell(
    child: child,
  );
}

// =====================================================
// MAIN APP ROUTER
// =====================================================

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',

  routes: [

    // =================================================
    // 1. LOGIN
    // =================================================

    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // =================================================
    // 2. OFFICER DASHBOARD
    // =================================================

    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) =>
          _officerPage(const DashboardScreen()),
    ),

    // =================================================
    // 3. REPORTS
    // =================================================

    GoRoute(
      path: '/reports',
      name: 'reports',
      builder: (context, state) =>
          _officerPage(const ReportsScreen()),
    ),

    // =================================================
    // 4. ALERTS
    // =================================================

    GoRoute(
      path: '/alerts',
      name: 'alerts',
      builder: (context, state) =>
          _officerPage(const AlertsScreen()),
    ),

    // =================================================
    // 5. INDIVIDUAL RISK DETAILS
    // =================================================

    GoRoute(
      path: '/individual-risk/:id',
      name: 'individual-risk',
      builder: (context, state) {
        final id = state.pathParameters['id']!;

        return _officerPage(
          IndividualRiskScreen(referralId: id),
        );
      },
    ),

    // =================================================
    // 6. REFERRAL MANAGEMENT
    // =================================================

    GoRoute(
      path: '/referrals',
      name: 'referrals',
      builder: (context, state) =>
          _officerPage(const ReferralManagementScreen()),
    ),

    // =================================================
    // 7. SCHEDULE CONFIRMATION
    // =================================================

    GoRoute(
      path: '/schedule-confirmation',
      name: 'schedule-confirmation',
      builder: (context, state) {
        final extra = state.extra;

        if (extra is! Map) {
          return _officerPage(
            const Scaffold(
              body: Center(
                child: Text('Referral information not found'),
              ),
            ),
          );
        }

        final referral = Map<String, dynamic>.from(extra);

        return _officerPage(
          ScheduleConfirmationScreen(referral: referral),
        );
      },
    ),

    // =================================================
    // 8. REFERRAL STATUS
    // =================================================

    GoRoute(
      path: '/referral-status',
      name: 'referral-status',
      builder: (context, state) {
        final extra = state.extra;

        if (extra is! Map) {
          return _officerPage(
            const Scaffold(
              body: Center(
                child: Text('Referral information not found'),
              ),
            ),
          );
        }

        final referral = Map<String, dynamic>.from(extra);

        return _officerPage(
          ReferralStatusScreen(referral: referral),
        );
      },
    ),

    // =================================================
    // 9. RISK MONITORING
    // =================================================

    GoRoute(
      path: '/risk-monitoring',
      name: 'risk-monitoring',
      builder: (context, state) =>
          _officerPage(const RiskMonitoringScreen()),
    ),

    // =================================================
    // 10. HIGH-RISK INDIVIDUALS
    // =================================================

    GoRoute(
      path: '/high-risk-individuals',
      name: 'high-risk-individuals',
      builder: (context, state) {
        final diseaseType =
            state.uri.queryParameters['type'] ?? 'diabetes';

        return _officerPage(
          HighRiskIndividualsScreen(
            diseaseType: diseaseType,
          ),
        );
      },
    ),

    // =================================================
    // 11. HEALTH WORKERS
    // =================================================

    GoRoute(
      path: '/workers',
      name: 'workers',
      builder: (context, state) =>
          _officerPage(const WorkerManagementScreen()),
    ),

    // =================================================
    // 12. ADD HEALTH WORKER
    // =================================================

    GoRoute(
      path: '/add-worker',
      name: 'add-worker',
      builder: (context, state) =>
          _officerPage(const AddWorkerScreen()),
    ),

    // =================================================
    // 13. WORKER ASSIGNED INDIVIDUALS
    // =================================================

    GoRoute(
      path: '/worker-individuals/:workerId',
      name: 'worker-individuals',
      builder: (context, state) {
        final extra = state.extra;

        if (extra is! Map) {
          return _officerPage(
            const Scaffold(
              body: Center(
                child: Text('Worker information not found'),
              ),
            ),
          );
        }

        final worker = Map<String, dynamic>.from(extra);

        return _officerPage(
          WorkerIndividualsScreen(worker: worker),
        );
      },
    ),

    // =================================================
    // 14. EDIT WORKER
    // =================================================

    GoRoute(
      path: '/edit-worker/:workerId',
      name: 'edit-worker',
      builder: (context, state) {
        final extra = state.extra;

        if (extra is! Map) {
          return _officerPage(
            const Scaffold(
              body: Center(
                child: Text('Worker information not found'),
              ),
            ),
          );
        }

        return _officerPage(
          EditWorkerScreen(
            worker: Map<String, dynamic>.from(extra),
          ),
        );
      },
    ),

    // =================================================
    // 15. WORKER PERFORMANCE
    // =================================================

    GoRoute(
      path: '/worker-performance',
      name: 'worker-performance',
      builder: (context, state) =>
          _officerPage(const WorkerPerformanceScreen()),
    ),

    // =================================================
    // 16. CREATE ASSIGNMENT
    // =================================================

    GoRoute(
      path: '/create-assignment',
      name: 'create-assignment',
      builder: (context, state) =>
          _officerPage(const CreateAssignmentScreen()),
    ),

    // =================================================
    // 17. ASSIGNMENT SUCCESS
    // =================================================

    GoRoute(
      path: '/assignment-success',
      name: 'assignment-success',
      builder: (context, state) {
        final extra = state.extra;

        if (extra is! Map) {
          return _officerPage(
            const Scaffold(
              backgroundColor: Color(0xFFF4F7FC),
              body: Center(
                child: Text('Assignment information not found'),
              ),
            ),
          );
        }

        final assignment = Map<String, dynamic>.from(extra);

        return _officerPage(
          AssignmentSuccessScreen(assignment: assignment),
        );
      },
    ),

    // =================================================
    // 18. ASSIGNMENT MANAGEMENT
    // =================================================

    GoRoute(
      path: '/assignments',
      name: 'assignments',
      builder: (context, state) =>
          _officerPage(const AssignmentManagementScreen()),
    ),

    // =================================================
    // 19. ASSIGNMENT DETAILS
    // =================================================

    GoRoute(
      path: '/assignment-details/:assignmentId',
      name: 'assignment-details',
      builder: (context, state) {
        final assignmentId =
            state.pathParameters['assignmentId']!;

        return _officerPage(
          AssignmentDetailsScreen(
            assignmentId: assignmentId,
          ),
        );
      },
    ),

    // =================================================
    // 20. ALL INDIVIDUALS
    // =================================================

    GoRoute(
      path: '/individuals',
      name: 'individuals',
      builder: (context, state) =>
          _officerPage(const IndividualsScreen()),
    ),

    // =================================================
    // 21. HOUSEHOLD REGISTRATION
    // =================================================

    GoRoute(
      path: '/household-registration',
      name: 'household-registration',
      builder: (context, state) =>
          _officerPage(const HouseholdRegistrationScreen()),
    ),

    // =================================================
    // 22. HOUSEHOLD MANAGEMENT
    // =================================================

    GoRoute(
      path: '/households',
      name: 'households',
      builder: (context, state) =>
          _officerPage(const HouseholdManagementScreen()),
    ),

    // =================================================
    // 23. HOUSEHOLD DETAILS
    // =================================================

    GoRoute(
      path: '/household-details/:householdId',
      name: 'household-details',
      builder: (context, state) {
        return _officerPage(
          HouseholdDetailsScreen(
            householdId:
                state.pathParameters['householdId']!,
          ),
        );
      },
    ),

    // =================================================
    // 24. INDIVIDUAL REGISTRATION
    // =================================================

    GoRoute(
      path: '/individual-registration/:householdId',
      name: 'individual-registration',
      builder: (context, state) {
        return _officerPage(
          IndividualRegistrationScreen(
            householdId:
                state.pathParameters['householdId']!,
          ),
        );
      },
    ),

    // =================================================
    // 25. CONSENT MANAGEMENT
    // =================================================

    GoRoute(
      path: '/consent-management/:householdId',
      name: 'consent-management',
      builder: (context, state) {
        return _officerPage(
          ConsentManagementScreen(
            householdId:
                state.pathParameters['householdId']!,
          ),
        );
      },
    ),

    // =================================================
    // 26. INDIVIDUAL DETAILS
    // =================================================

    GoRoute(
      path: '/individual-details/:householdId/:individualId',
      name: 'individual-details',
      builder: (context, state) {
        return _officerPage(
          IndividualDetailsScreen(
            householdId:
                state.pathParameters['householdId']!,
            individualId:
                state.pathParameters['individualId']!,
          ),
        );
      },
    ),

    // =================================================
    // 27. EDIT INDIVIDUAL
    // =================================================

    GoRoute(
      path: '/individual-edit/:householdId/:individualId',
      name: 'individual-edit',
      builder: (context, state) {
        return _officerPage(
          IndividualEditScreen(
            householdId:
                state.pathParameters['householdId']!,
            individualId:
                state.pathParameters['individualId']!,
          ),
        );
      },
    ),

    // =================================================
    // 28. AREA MANAGEMENT
    // =================================================

    GoRoute(
      path: '/areas',
      name: 'areas',
      builder: (context, state) =>
          _officerPage(const AreaManagementScreen()),
    ),

    // =================================================
    // 29. ALL SERVICES
    // =================================================

    GoRoute(
      path: '/all-services',
      name: 'all-services',
      builder: (context, state) =>
          _officerPage(const AllServicesScreen()),
    ),

    // =================================================
    // 30. FOLLOW-UPS
    // =================================================

    GoRoute(
      path: '/follow-ups',
      name: 'follow-ups',
      builder: (context, state) =>
          _officerPage(const FollowUpsScreen()),
    ),

    // =================================================
    // 31. OFFICER SCREENING MONITORING
    // =================================================

    GoRoute(
      path: '/screening-monitoring',
      name: 'screening-monitoring',
      builder: (context, state) =>
          _officerPage(const ScreeningMonitoringScreen()),
    ),

    // =================================================
    // 32. OFFICER SCREENING DETAILS
    // =================================================

    GoRoute(
      path: '/screening-details/:screeningId',
      name: 'screening-details',
      builder: (context, state) {
        return _officerPage(
          ScreeningDetailsScreen(
            screeningId:
                state.pathParameters['screeningId']!,
          ),
        );
      },
    ),

    // =================================================
    // 33. MEDICAL REPORTS
    // =================================================

    GoRoute(
      path: '/medical-reports',
      name: 'medical-reports',
      builder: (context, state) =>
          _officerPage(const MedicalReportsScreen()),
    ),

    // =================================================
    // 34. MEDICAL REPORT DETAILS
    // =================================================

    GoRoute(
      path: '/medical-report-details/:reportId',
      name: 'medical-report-details',
      builder: (context, state) {
        final reportId = int.parse(
          state.pathParameters['reportId']!,
        );

        return _officerPage(
          MedicalReportDetailsScreen(
            reportId: reportId,
          ),
        );
      },
    ),

    // =================================================
    // 35. UPLOAD MEDICAL REPORT
    // =================================================

    GoRoute(
      path: '/upload-medical-report',
      name: 'upload-medical-report',
      builder: (context, state) =>
          _officerPage(const UploadMedicalReportScreen()),
    ),

    // =================================================
    // WORKER APP ROUTES
    // These routes intentionally remain outside the
    // Government Officer responsive shell.
    // =================================================

    // Worker Dashboard

    GoRoute(
      path: '/worker-dashboard',
      name: 'worker-dashboard',
      builder: (context, state) =>
          const WorkerDashboardScreen(),
    ),

    // Worker Households

    GoRoute(
      path: '/worker-households',
      name: 'worker-households',
      builder: (context, state) =>
          const AssignedHouseholdsScreen(),
    ),

    // Worker Household Details

    GoRoute(
      path: '/worker-household-details/:householdId',
      name: 'worker-household-details',
      builder: (context, state) {
        return WorkerHouseholdDetailsScreen(
          householdId:
              state.pathParameters['householdId']!,
        );
      },
    ),

    // Worker Personal Details

    GoRoute(
      path: '/worker-personal-details/:householdId/:individualId',
      builder: (context, state) {
        return PersonalDetailsScreen(
          householdId:
              state.pathParameters['householdId']!,
          individualId:
              state.pathParameters['individualId']!,
        );
      },
    ),

    // Worker Consent

    GoRoute(
      path: '/worker-consent/:householdId/:individualId',
      name: 'worker-consent',
      builder: (context, state) {
        return ConsentCaptureScreen(
          householdId:
              state.pathParameters['householdId']!,
          individualId:
              state.pathParameters['individualId']!,
        );
      },
    ),

    // Worker Medical History

    GoRoute(
      path: '/worker-medical-history/:householdId/:individualId',
      name: 'worker-medical-history',
      builder: (context, state) {
        return MedicalHistoryScreen(
          householdId:
              state.pathParameters['householdId']!,
          individualId:
              state.pathParameters['individualId']!,
        );
      },
    ),

    // Worker Measurements

    GoRoute(
      path: '/worker-measurements/:householdId/:individualId',
      name: 'worker-measurements',
      builder: (context, state) {
        return MeasurementsScreen(
          householdId:
              state.pathParameters['householdId']!,
          individualId:
              state.pathParameters['individualId']!,
        );
      },
    ),

    // Worker Measurement Review

    GoRoute(
      path: '/worker-measurement-review/:householdId/:individualId',
      name: 'worker-measurement-review',
      builder: (context, state) {
        return MeasurementReviewScreen(
          householdId:
              state.pathParameters['householdId']!,
          individualId:
              state.pathParameters['individualId']!,
        );
      },
    ),

    // Worker Screening Summary

    GoRoute(
      path: '/worker-screening-summary/:householdId/:individualId',
      name: 'worker-screening-summary',
      builder: (context, state) {
        return ScreeningSummaryScreen(
          householdId:
              state.pathParameters['householdId']!,
          individualId:
              state.pathParameters['individualId']!,
        );
      },
    ),

    // Worker Screening Result

    GoRoute(
      path: '/worker-screening-result/:householdId/:individualId',
      name: 'worker-screening-result',
      builder: (context, state) {
        return ScreeningResultScreen(
          householdId:
              state.pathParameters['householdId']!,
          individualId:
              state.pathParameters['individualId']!,
        );
      },
    ),

    // Worker Visits

    GoRoute(
      path: '/worker-visits',
      name: 'worker-visits',
      builder: (context, state) =>
          const WorkerVisitsScreen(),
    ),

    // Worker Follow-ups

    GoRoute(
      path: '/worker-followups',
      name: 'worker-followups',
      builder: (context, state) =>
          const WorkerFollowUpsScreen(),
    ),

    // Worker Profile

    GoRoute(
      path: '/worker-profile',
      name: 'worker-profile',
      builder: (context, state) =>
          const WorkerProfileScreen(),
    ),
  ],

  // =====================================================
  // ERROR PAGE
  // =====================================================

  errorBuilder: (context, state) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Center(
        child: Text(
          'Page not found: ${state.uri}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  },
);
