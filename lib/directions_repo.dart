import 'package:dio/dio.dart';

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/api/directions/json?';

  final Dio _dio;

  DirectionsRepository({Dio dio}) : _dio = dio ?? Dio();
}
