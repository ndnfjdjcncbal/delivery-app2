import 'package:delivert_app2/core/network/network_info.dart';
import 'package:dio/dio.dart';

import '../constants/api_client/link_api.dart';
import '../errors/exceptions.dart';
import 'api_consumer.dart';

class DioConsumer implements ApiConsumer {
  final Dio dio;
  final NetworkInfo networkInfo = NetworkInfo();
  DioConsumer(this.dio) {
    dio.options.baseUrl = ApiConstants.Api;

    dio.options.connectTimeout = const Duration(seconds: 40);

    dio.options.receiveTimeout = const Duration(seconds: 20);

    dio.options.sendTimeout = const Duration(seconds: 20);
  }

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(
      () => dio.get(path, queryParameters: queryParameters, options: options),
    );
  }

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(
      () => dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  @override
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(
      () => dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  @override
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(
      () => dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  @override
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _request(
      () => dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response> _request(Future<Response> Function() request) async {
    try {
      final response = await request();
      print(response);

      _checkResponse(response);
      return response;
    } on DioException catch (error) {
      print('TYPE: ${error.type}');
      print('MESSAGE: ${error.message}');
      print('ERROR: ${error.error}');
      print('REQUEST URL: ${error.requestOptions.uri}');
      print('RESPONSE: ${error.response?.data}');

      if (error.response != null) {
        throw ServerException(
          _messageFrom(error.response) ??
              error.message ??
              'Server request failed',
          statusCode: error.response?.statusCode,
        );
      }

      throw NetworkException(
        error.message ?? error.error?.toString() ?? 'Network error',
      );
    }
  }

  void _checkResponse(Response response) {
    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw ServerException(
        _messageFrom(response.data) ?? 'Server request failed',
        statusCode: statusCode,
      );
    }

    if (response.data is! Map) return;

    final data = response.data as Map<String, dynamic>;
    print(data);
    final status = data['status']?.toString().toLowerCase();
    final failed =
        status == 'failure' || status == 'error' || status == 'false';

    if (failed) {
      throw ServerException(
        _messageFrom(data) ?? 'Server request failed',
        statusCode: statusCode,
      );
    }
  }

  String? _messageFrom(dynamic data) {
    if (data is! Map) return null;

    return data['message'] ?? data['status'];
  }
}
