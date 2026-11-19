import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

class AiService {
  final ApiClient _apiClient = ApiClient();

  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      final responseData = error.response?.data;

      if (responseData is Map && responseData['detail'] != null) {
        final detail = responseData['detail'];

        if (detail is String) return detail;

        return detail.toString();
      }

      return error.message ?? 'Unable to connect to AI service.';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  // RUN DIABETES PREDICTION
  Future<Map<String, dynamic>> runDiabetesPrediction(
    int screeningId,
  ) async {
    try {
      final response = await _apiClient.post(
        '/ai-predictions/run/$screeningId/diabetes',
      );

      if (response.data is! Map) {
        throw Exception('Invalid diabetes prediction response.');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(_getErrorMessage(error));
    }
  }

  // RUN CARDIOVASCULAR PREDICTION
  Future<Map<String, dynamic>> runCardiovascularPrediction(
    int screeningId,
  ) async {
    try {
      final response = await _apiClient.post(
        '/ai-predictions/run/$screeningId/cardiovascular',
      );

      if (response.data is! Map) {
        throw Exception('Invalid cardiovascular prediction response.');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(_getErrorMessage(error));
    }
  }

  // FETCH PREDICTION HISTORY
  Future<List<Map<String, dynamic>>> fetchPredictions({
    int? individualId,
    int? screeningId,
    String? predictionType,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (individualId != null) {
        queryParameters['individual_id'] = individualId;
      }

      if (screeningId != null) {
        queryParameters['screening_id'] = screeningId;
      }

      if (predictionType != null) {
        queryParameters['prediction_type'] = predictionType;
      }

      final response = await _apiClient.get(
        '/ai-predictions/',
        queryParameters: queryParameters.isEmpty
            ? null
            : queryParameters,
      );

      if (response.data is! List) {
        throw Exception('Invalid prediction history response.');
      }

      return (response.data as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } catch (error) {
      throw Exception(_getErrorMessage(error));
    }
  }

  // FETCH PREDICTION BY ID
  Future<Map<String, dynamic>> fetchPrediction(int predictionId) async {
    try {
      final response = await _apiClient.get(
        '/ai-predictions/$predictionId',
      );

      if (response.data is! Map) {
        throw Exception('Invalid prediction response.');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(_getErrorMessage(error));
    }
  }

  // GENERATE DIABETES FORECAST
  Future<Map<String, dynamic>> generateDiabetesForecast(
    int individualId,
  ) async {
    try {
      final response = await _apiClient.post(
        '/forecasts/diabetes/$individualId',
      );

      if (response.data is! Map) {
        throw Exception('Invalid diabetes forecast response.');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(_getErrorMessage(error));
    }
  }

  // GENERATE CARDIOVASCULAR FORECAST
  Future<Map<String, dynamic>> generateCardiovascularForecast(
    int individualId,
  ) async {
    try {
      final response = await _apiClient.post(
        '/forecasts/cardiovascular/$individualId',
      );

      if (response.data is! Map) {
        throw Exception('Invalid cardiovascular forecast response.');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(_getErrorMessage(error));
    }
  }
}