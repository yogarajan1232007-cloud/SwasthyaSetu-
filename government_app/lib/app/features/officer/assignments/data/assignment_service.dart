import '../../../../core/network/api_client.dart';

class AssignmentService {
  final ApiClient _apiClient = ApiClient();

  // Fetch all assignments
  Future<List<Map<String, dynamic>>> fetchAssignments({
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final response = await _apiClient.get(
        '/assignments/',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to fetch assignments');
      }

      return List<Map<String, dynamic>>.from(
        (response.data as List).map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );
    } catch (e) {
      throw Exception('Assignment API error: $e');
    }
  }

  // Fetch assignments for a particular worker
  Future<List<Map<String, dynamic>>> fetchWorkerAssignments(
    int workerId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/assignments/worker/$workerId',
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to fetch worker assignments');
      }

      return List<Map<String, dynamic>>.from(
        (response.data as List).map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );
    } catch (e) {
      throw Exception('Worker assignment API error: $e');
    }
  }

  // Fetch one assignment
  Future<Map<String, dynamic>> fetchAssignment(
    int assignmentId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/assignments/$assignmentId',
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to fetch assignment details');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Assignment details API error: $e');
    }
  }

  // Create one household assignment
  Future<Map<String, dynamic>> createAssignment(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post(
        '/assignments/',
        data: data,
      );

      if (response.statusCode != 201) {
        throw Exception('Unable to create assignment');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Create assignment API error: $e');
    }
  }

  // Update assignment status, due date or remarks
  Future<Map<String, dynamic>> updateAssignment(
    int assignmentId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/assignments/$assignmentId',
        data: data,
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to update assignment');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Update assignment API error: $e');
    }
  }
}