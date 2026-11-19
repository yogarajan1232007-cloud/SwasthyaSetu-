import '../../../../core/network/api_client.dart';
import '../models/worker_performance.dart';

class WorkerPerformanceService {
  final ApiClient _apiClient = ApiClient();

  Future<List<WorkerPerformance>> fetchWorkerPerformance() async {
    try {
      // 1. Fetch all workers
      final workerResponse = await _apiClient.get(
        '/workers/',
        queryParameters: {
          'skip': 0,
          'limit': 100,
        },
      );

      if (workerResponse.statusCode != 200) {
        throw Exception('Failed to fetch workers');
      }

      final workers = List<Map<String, dynamic>>.from(
        (workerResponse.data as List).map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );

      // 2. Fetch individual dashboard statistics
      final results = await Future.wait(
        workers.map((worker) async {
          final workerId = worker['id'];

          final dashboardResponse = await _apiClient.get(
            '/dashboard/worker/$workerId',
          );

          if (dashboardResponse.statusCode != 200) {
            throw Exception(
              'Failed to fetch dashboard for worker $workerId',
            );
          }

          final dashboard = Map<String, dynamic>.from(
            dashboardResponse.data,
          );

          // 3. Combine worker information and statistics
          return WorkerPerformance.fromJson(
            worker,
            dashboard,
          );
        }),
      );

      return results;
    } catch (e) {
      throw Exception('Worker performance API error: $e');
    }
  }
}