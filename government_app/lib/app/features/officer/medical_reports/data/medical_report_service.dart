
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../../core/network/api_client.dart';

class MedicalReportService {
  final ApiClient _apiClient = ApiClient();

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }

      return error.message ?? 'Network error occurred';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  // ============================================================
  // FETCH ALL MEDICAL REPORTS
  // ============================================================

  Future<List<Map<String, dynamic>>> fetchReports({
    int? individualId,
    int? screeningId,
  }) async {
    try {
      final query = <String, dynamic>{};

      if (individualId != null) {
        query['individual_id'] = individualId;
      }

      if (screeningId != null) {
        query['screening_id'] = screeningId;
      }

      final response = await _apiClient.get(
        '/medical-reports/',
        queryParameters: query.isEmpty ? null : query,
      );

      if (response.data is! List) {
        throw Exception('Invalid medical reports response');
      }

      return (response.data as List)
          .map(
            (item) => Map<String, dynamic>.from(item as Map),
          )
          .toList();
    } catch (error) {
      throw Exception(
        'Unable to fetch medical reports: ${_getErrorMessage(error)}',
      );
    }
  }

  // ============================================================
  // FETCH REPORT DETAILS
  // ============================================================

  Future<Map<String, dynamic>> fetchReportDetails(
    int reportId,
  ) async {
    try {
      final response = await _apiClient.get(
        '/medical-reports/$reportId',
      );

      if (response.data is! Map) {
        throw Exception('Invalid report details response');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(
        'Unable to fetch report details: ${_getErrorMessage(error)}',
      );
    }
  }

  // ============================================================
  // UPLOAD MEDICAL REPORT
  // ============================================================

  Future<Map<String, dynamic>> uploadReport({
    required int individualId,
    int? screeningId,
    int? uploadedBy,
    required String reportType,
    required String reportName,
    required String filePath,
    String? notes,
  }) async {
    try {
      final extension = filePath.split('.').last.toLowerCase();

      final mimeTypes = <String, MediaType>{
        'pdf': MediaType('application', 'pdf'),
        'jpg': MediaType('image', 'jpeg'),
        'jpeg': MediaType('image', 'jpeg'),
        'png': MediaType('image', 'png'),
      };

      final mimeType = mimeTypes[extension];

      if (mimeType == null) {
        throw Exception(
          'Only PDF, JPG, JPEG and PNG files are supported',
        );
      }

      final formFields = <String, dynamic>{
        'individual_id': individualId,
        'report_type': reportType,
        'report_name': reportName,
      };

      if (screeningId != null) {
        formFields['screening_id'] = screeningId;
      }

      if (uploadedBy != null) {
        formFields['uploaded_by'] = uploadedBy;
      }

      if (notes != null && notes.isNotEmpty) {
        formFields['notes'] = notes;
      }

      formFields['file'] = await MultipartFile.fromFile(
        filePath,
        filename: filePath.split(RegExp(r'[/\\]')).last,
        contentType: mimeType,
      );

      final formData = FormData.fromMap(formFields);

      final response = await _apiClient.post(
        '/medical-reports/upload',
        data: formData,
      );

      if (response.data is! Map) {
        throw Exception('Invalid upload response');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(
        'Medical report upload failed: ${_getErrorMessage(error)}',
      );
    }
  }

  // ============================================================
  // UPDATE VERIFICATION STATUS
  // ============================================================

  Future<Map<String, dynamic>> updateReportStatus({
    required int reportId,
    required String status,
    String? notes,
  }) async {
    try {
      const allowedStatuses = [
        'pending',
        'verified',
        'rejected',
      ];

      if (!allowedStatuses.contains(status)) {
        throw Exception('Invalid verification status');
      }

      final updateData = <String, dynamic>{
        'verification_status': status,
      };

      if (notes != null) {
        updateData['notes'] = notes;
      }

      final response = await _apiClient.patch(
        '/medical-reports/$reportId',
        data: updateData,
      );

      if (response.data is! Map) {
        throw Exception('Invalid report update response');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(
        'Unable to update report: ${_getErrorMessage(error)}',
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

      if (response.data is! Map) {
        throw Exception('Invalid individual response');
      }

      return Map<String, dynamic>.from(response.data);
    } catch (error) {
      throw Exception(
        'Unable to fetch individual: ${_getErrorMessage(error)}',
      );
    }
  }

  // ============================================================
  // DOWNLOAD MEDICAL REPORT
  // ============================================================

  Future<String> downloadReport({
    required int reportId,
    required String savePath,
  }) async {
    try {
      final response = await _apiClient.download(
        '/medical-reports/$reportId/download',
        savePath,
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to download medical report');
      }

      final file = File(savePath);

      if (!await file.exists()) {
        throw Exception('Downloaded file was not found');
      }

      if (await file.length() == 0) {
        await file.delete();
        throw Exception('Downloaded file is empty');
      }

      return savePath;
    } catch (error) {
      throw Exception(
        'Medical report download failed: ${_getErrorMessage(error)}',
      );
    }
  }
}
