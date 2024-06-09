import 'package:dio/dio.dart';

Dio buildDioClient() {
  final dio = Dio();

  dio.interceptors.add(LogInterceptor());
  return dio;
}
