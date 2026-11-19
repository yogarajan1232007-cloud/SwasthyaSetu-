import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

class ScreeningService {
  final ApiClient _apiClient = ApiClient();

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  String _getErrorMessage(
    dynamic error, {
    required String defaultMessage,
  }) {
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
  // FETCH ALL SCREENINGS
  // ============================================================

  Future<List<Map<String, dynamic>>> fetchScreenings({
    int? individualId,
    int? workerId,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {};

      if (individualId != null) {
        queryParameters['individual_id'] = individualId;
      }

      if (workerId != null) {
        queryParameters['worker_id'] = workerId;
      }

      final response = await _apiClient.get(
        '/screenings/',
        queryParameters: queryParameters.isEmpty
            ? null
            : queryParameters,
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to fetch screenings');
      }

      if (response.data is! List) {
        throw Exception('Invalid screening response from server');
      }

      return (response.data as List).map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();
    } catch (error) {
      throw Exception(
        'Unable to load screenings: ${_getErrorMessage(
          error,
          defaultMessage: 'Screening fetching failed',
        )}',
      );
    }
  }

  // ============================================================
  // FETCH SCREENING DETAILS
  // ============================================================

  Future<Map<String, dynamic>> fetchScreeningDetails(
    int screeningId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/screenings/$screeningId',
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to fetch screening details');
      }

      if (response.data is! Map) {
        throw Exception('Invalid screening details response');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(
        'Unable to load screening details: ${_getErrorMessage(
          error,
          defaultMessage: 'Screening details fetching failed',
        )}',
      );
    }
  }

  // ============================================================
  // FETCH MEASUREMENTS FOR A SCREENING
  // ============================================================

  Future<List<Map<String, dynamic>>> fetchMeasurements(
    int screeningId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/measurements/',
        queryParameters: {
          'screening_id': screeningId,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to fetch measurements');
      }

      if (response.data is! List) {
        throw Exception('Invalid measurements response');
      }

      return (response.data as List).map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();
    } catch (error) {
      throw Exception(
        'Unable to load measurements: ${_getErrorMessage(
          error,
          defaultMessage: 'Measurement fetching failed',
        )}',
      );
    }
  }

  // ============================================================
  // FETCH INDIVIDUAL DETAILS
  // ============================================================

  Future<Map<String, dynamic>> fetchIndividual(
    int individualId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/individuals/$individualId',
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to fetch individual details');
      }

      if (response.data is! Map) {
        throw Exception('Invalid individual response');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(
        'Unable to load individual: ${_getErrorMessage(
          error,
          defaultMessage: 'Individual fetching failed',
        )}',
      );
    }
  }
}