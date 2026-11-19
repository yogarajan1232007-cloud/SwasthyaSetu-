import '../../../../core/network/api_client.dart';

class HouseholdService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> fetchHouseholds({
    String? search,
  }) async {
    try {
      final response = await _apiClient.get(
        '/households/',
        queryParameters: {
          'skip': 0,
          'limit': 100,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to fetch households');
      }

      return List<Map<String, dynamic>>.from(
        (response.data as List).map(
          (item) => Map<String, dynamic>.from(item),
        ),
      );
    } catch (e) {
      throw Exception('Household API error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchHousehold(int householdId) async {
    try {
      final response = await _apiClient.get(
        '/households/$householdId',
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to fetch household details');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw Exception('Household details API error: $e');
    }
  }

  Future<Map<String, dynamic>> createHousehold(
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.post(
      '/households/',
      data: data,
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<Map<String, dynamic>> updateHousehold(
    int householdId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.put(
      '/households/$householdId',
      data: data,
    );

    return Map<String, dynamic>.from(response.data);
  }
}