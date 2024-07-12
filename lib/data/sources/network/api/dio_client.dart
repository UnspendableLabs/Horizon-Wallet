import 'package:dio/dio.dart';

Dio buildDioClient() {
  final dio = Dio();

  // Log interceptor to log all requests and responses
  // dio.interceptors.add(LogInterceptor(
  //     request: true,
  //     requestHeader: false,
  //     requestBody: false,
  //     responseHeader: false,
  //     responseBody: true,
  //     error: true));
  return dio;
}
