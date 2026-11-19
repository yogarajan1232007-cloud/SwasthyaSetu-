import '../../../../core/network/api_client.dart';
import '../models/government_dashboard.dart';

class GovernmentDashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<GovernmentDashboard> fetchDashboard() async {
    try {
      final response = await _apiClient.get(
        '/dashboard/government',
      );

      if (response.statusCode == 200) {
        return GovernmentDashboard.fromJson(
          Map<String, dynamic>.from(response.data),
        );
      }

      throw Exception(
        'Failed to load dashboard: ${response.statusCode}',
      );
    } catch (e) {
      throw Exception('Dashboard API error: $e');
    }
  }
}