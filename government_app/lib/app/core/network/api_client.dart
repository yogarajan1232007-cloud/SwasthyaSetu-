
import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  // GET
  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(
      endpoint,
      queryParameters: queryParameters,
    );
  }

  // POST
  Future<Response<dynamic>> post(
    String endpoint, {
    dynamic data,
  }) async {
    return await _dio.post(
      endpoint,
      data: data,
    );
  }

  // PUT
  Future<Response<dynamic>> put(
    String endpoint, {
    dynamic data,
  }) async {
    return await _dio.put(
      endpoint,
      data: data,
    );
  }

  // PATCH
  Future<Response<dynamic>> patch(
    String endpoint, {
    dynamic data,
  }) async {
    return await _dio.patch(
      endpoint,
      data: data,
    );
  }

  // DELETE
  Future<Response<dynamic>> delete(
    String endpoint,
  ) async {
    return await _dio.delete(endpoint);
  }

  // DOWNLOAD
  Future<Response<dynamic>> download(
    String endpoint,
    String savePath,
  ) async {
    return await _dio.download(
      endpoint,
      savePath,
    );
  }
}
