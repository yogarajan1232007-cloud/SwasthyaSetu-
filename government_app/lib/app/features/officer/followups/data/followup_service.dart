import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

class FollowUpService {
  final ApiClient _apiClient = ApiClient();

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      final responseData = error.response?.data;

      if (responseData is Map) {
        final detail = responseData['detail'];

        if (detail != null) {
          return detail.toString();
        }
      }

      if (error.message != null) {
        return error.message!;
      }
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  // ============================================================
  // FETCH FOLLOW-UPS
  // ============================================================

  Future<List<Map<String, dynamic>>> fetchFollowUps({
    int? individualId,
    int? workerId,
    int? screeningId,
    String? status,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (individualId != null) {
        queryParameters['individual_id'] = individualId;
      }

      if (workerId != null) {
        queryParameters['worker_id'] = workerId;
      }

      if (screeningId != null) {
        queryParameters['screening_id'] = screeningId;
      }

      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status.toLowerCase();
      }

      final response = await _apiClient.get(
        '/followups/',
        queryParameters: queryParameters.isEmpty
            ? null
            : queryParameters,
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to fetch follow-ups');
      }

      if (response.data is! List) {
        throw Exception('Invalid follow-up response from server');
      }

      return (response.data as List).map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();
    } catch (error) {
      throw Exception(
        'Unable to load follow-ups: ${_getErrorMessage(error)}',
      );
    }
  }

  // ============================================================
  // FETCH FOLLOW-UP DETAILS
  // ============================================================

  Future<Map<String, dynamic>> fetchFollowUpDetails(
    int followUpId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/followups/$followUpId',
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to fetch follow-up details');
      }

      if (response.data is! Map) {
        throw Exception('Invalid follow-up details response');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(
        'Unable to load follow-up details: ${_getErrorMessage(error)}',
      );
    }
  }

  // ============================================================
  // CREATE FOLLOW-UP
  // ============================================================

  Future<Map<String, dynamic>> createFollowUp({
    required int individualId,
    int? workerId,
    int? screeningId,
    required String followUpType,
    required DateTime dueDate,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'individual_id': individualId,
        'followup_type': followUpType.trim(),
        'due_date': _formatDate(dueDate),
        'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
      };

      if (workerId != null) {
        data['worker_id'] = workerId;
      }

      if (screeningId != null) {
        data['screening_id'] = screeningId;
      }

      final response = await _apiClient.post(
        '/followups/',
        data: data,
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw Exception('Follow-up creation failed');
      }

      if (response.data is! Map) {
        throw Exception('Invalid follow-up creation response');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(
        'Follow-up creation failed: ${_getErrorMessage(error)}',
      );
    }
  }

  // ============================================================
  // UPDATE FOLLOW-UP
  // ============================================================

  Future<Map<String, dynamic>> updateFollowUp(
    int followUpId, {
    int? workerId,
    String? followUpType,
    DateTime? dueDate,
    String? status,
    String? notes,
    bool updateWorker = false,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (updateWorker) {
        data['worker_id'] = workerId;
      }

      if (followUpType != null) {
        data['followup_type'] = followUpType.trim();
      }

      if (dueDate != null) {
        data['due_date'] = _formatDate(dueDate);
      }

      if (status != null) {
        data['status'] = status.toLowerCase();
      }

      if (notes != null) {
        data['notes'] = notes.trim();
      }

      if (data.isEmpty) {
        throw Exception('No changes provided');
      }

      final response = await _apiClient.patch(
        '/followups/$followUpId',
        data: data,
      );

      if (response.statusCode != 200) {
        throw Exception('Follow-up update failed');
      }

      if (response.data is! Map) {
        throw Exception('Invalid follow-up update response');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(
        'Follow-up update failed: ${_getErrorMessage(error)}',
      );
    }
  }

  // ============================================================
  // COMPLETE FOLLOW-UP
  // ============================================================

  Future<Map<String, dynamic>> completeFollowUp(
    int followUpId,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/followups/$followUpId/complete',
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to complete follow-up');
      }

      if (response.data is! Map) {
        throw Exception('Invalid completion response');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(
        'Follow-up completion failed: ${_getErrorMessage(error)}',
      );
    }
  }

  // ============================================================
  // FETCH INDIVIDUALS
  // ============================================================

  Future<List<Map<String, dynamic>>> fetchIndividuals() async {
    try {
      final response = await _apiClient.get(
        '/individuals/',
        queryParameters: {
          'skip': 0,
          'limit': 100,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to fetch individuals');
      }

      if (response.data is! List) {
        throw Exception('Invalid individuals response');
      }

      return (response.data as List).map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();
    } catch (error) {
      throw Exception(
        'Unable to load individuals: ${_getErrorMessage(error)}',
      );
    }
  }

  // ============================================================
  // FETCH WORKERS
  // ============================================================

  Future<List<Map<String, dynamic>>> fetchWorkers({
    bool availableOnly = true,
  }) async {
    try {
      final response = await _apiClient.get(
        '/workers/',
        queryParameters: {
          'skip': 0,
          'limit': 100,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to fetch workers');
      }

      if (response.data is! List) {
        throw Exception('Invalid workers response');
      }

      final workers = (response.data as List).map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();

      if (!availableOnly) {
        return workers;
      }

      return workers.where((worker) {
        return worker['is_available'] == true &&
            worker['is_active'] == true;
      }).toList();
    } catch (error) {
      throw Exception(
        'Unable to load workers: ${_getErrorMessage(error)}',
      );
    }
  }

  // ============================================================
  // DATE FORMATTER
  // ============================================================

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}