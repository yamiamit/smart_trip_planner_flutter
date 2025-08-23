import 'package:dio/dio.dart';


Dio buildDio() {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
    ),
  );
  dio.interceptors.add(
    LogInterceptor(responseBody: false, requestBody: false),
  );
  return dio;
}