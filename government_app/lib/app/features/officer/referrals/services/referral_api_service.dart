import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

class ReferralApiService {
  final ApiClient _apiClient = ApiClient();

  // GET: Fetch all referrals
  Future<List<Map<String, dynamic>>> getReferrals({
    int? individualId,
    int? screeningId,
    String? status,
    String? urgency,
    int? createdBy,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (individualId != null) {
        queryParameters['individual_id'] = individualId;
      }

      if (screeningId != null) {
        queryParameters['screening_id'] = screeningId;
      }

      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status.toLowerCase();
      }

      if (urgency != null && urgency.isNotEmpty) {
        queryParameters['urgency'] = urgency.toLowerCase();
      }

      if (createdBy != null) {
        queryParameters['created_by'] = createdBy;
      }

      final response = await _apiClient.get(
        '/referrals/',
        queryParameters: queryParameters,
      );

      return (response.data as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to fetch referrals',
      );
    }
  }

  // GET: Fetch referral by ID
  Future<Map<String, dynamic>> getReferralById(
    int referralId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/referrals/$referralId',
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to fetch referral details',
      );
    }
  }

  // POST: Create new referral
  Future<Map<String, dynamic>> createReferral({
    required int individualId,
    int? screeningId,
    required int createdBy,
    required String facilityName,
    String? clinicianName,
    required String reason,
    String urgency = 'routine',
    DateTime? appointmentAt,
    String? notes,
  }) async {
    try {
      final data = <String, dynamic>{
        'individual_id': individualId,
        'created_by': createdBy,
        'facility_name': facilityName,
        'reason': reason,
        'urgency': urgency.toLowerCase(),
      };

      if (screeningId != null) {
        data['screening_id'] = screeningId;
      }

      if (clinicianName != null && clinicianName.trim().isNotEmpty) {
        data['clinician_name'] = clinicianName.trim();
      }

      if (appointmentAt != null) {
        data['appointment_at'] = appointmentAt.toIso8601String();
      }

      if (notes != null && notes.trim().isNotEmpty) {
        data['notes'] = notes.trim();
      }

      final response = await _apiClient.post(
        '/referrals/',
        data: data,
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to create referral',
      );
    }
  }

  // PATCH: Update referral
  Future<Map<String, dynamic>> updateReferral({
    required int referralId,
    String? status,
    String? urgency,
    DateTime? appointmentAt,
    String? clinicianName,
    String? notes,
    String? outcome,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (status != null) {
        data['status'] = status.toLowerCase();
      }

      if (urgency != null) {
        data['urgency'] = urgency.toLowerCase();
      }

      if (appointmentAt != null) {
        data['appointment_at'] = appointmentAt.toIso8601String();
      }

      if (clinicianName != null) {
        data['clinician_name'] = clinicianName;
      }

      if (notes != null) {
        data['notes'] = notes;
      }

      if (outcome != null) {
        data['outcome'] = outcome;
      }

      final response = await _apiClient.patch(
        '/referrals/$referralId',
        data: data,
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to update referral',
      );
    }
  }
}