
import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

class IndividualService {
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

      if (responseData is Map<String, dynamic>) {
        final detail = responseData['detail'];

        if (detail != null) {
          return detail.toString();
        }
      }

      if (error.message != null) {
        return error.message!;
      }
    }

    return error.toString().replaceFirst(
          'Exception: ',
          '',
        );
  }

  // ============================================================
  // FETCH ALL INDIVIDUALS BELONGING TO A HOUSEHOLD
  // ============================================================

  Future<List<Map<String, dynamic>>> fetchHouseholdIndividuals(
    int householdId,
  ) async {
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
        throw Exception('Invalid individuals response from server');
      }

      final allIndividuals = (response.data as List).map((item) {
        return Map<String, dynamic>.from(item as Map);
      }).toList();

      // Filter individuals using household ID.
      // Handles both integer and string API values.

      final householdIndividuals = allIndividuals.where((individual) {
        final individualHouseholdId = int.tryParse(
          individual['household_id']?.toString() ?? '',
        );

        return individualHouseholdId == householdId;
      }).toList();

      return householdIndividuals;
    } catch (error) {
      throw Exception(
        'Unable to load household members: ${_getErrorMessage(
          error,
          defaultMessage: 'Individual fetching failed',
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
        throw Exception('Invalid individual details response');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(
        'Unable to load individual details: ${_getErrorMessage(
          error,
          defaultMessage: 'Individual details fetching failed',
        )}',
      );
    }
  }

  // ============================================================
  // REGISTER NEW INDIVIDUAL
  // ============================================================

  Future<Map<String, dynamic>> createIndividual(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.post(
        '/individuals/',
        data: data,
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw Exception('Individual registration failed');
      }

      if (response.data is! Map) {
        throw Exception('Invalid registration response from server');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(
        'Individual registration failed: ${_getErrorMessage(
          error,
          defaultMessage: 'Unable to register individual',
        )}',
      );
    }
  }

  // ============================================================
  // UPDATE INDIVIDUAL DETAILS
  // ============================================================

  Future<Map<String, dynamic>> updateIndividual(
    int individualId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.put(
        '/individuals/$individualId',
        data: data,
      );

      if (response.statusCode != 200) {
        throw Exception('Individual update failed');
      }

      if (response.data is! Map) {
        throw Exception('Invalid update response from server');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(
        'Individual update failed: ${_getErrorMessage(
          error,
          defaultMessage: 'Unable to update individual',
        )}',
      );
    }
  }
}
