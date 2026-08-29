import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;
  static const String baseUrl = 'http://localhost:8000/api/v1';

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, handled by AuthService
        }
        return handler.next(error);
      },
    ));
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final response = await _dio.post('/auth/login', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> refreshToken(Map<String, dynamic> data) async {
    final response = await _dio.post('/auth/refresh', data: data);
    return response.data;
  }

  // User endpoints
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dio.get('/users/me');
    return response.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/users/me', data: data);
    return response.data;
  }

  // Enrollment endpoints
  Future<Map<String, dynamic>> giveConsent() async {
    final response = await _dio.post('/enrollment/consent');
    return response.data;
  }

  Future<Map<String, dynamic>> enrollFace(FormData formData) async {
    final response = await _dio.post('/enrollment/face', data: formData);
    return response.data;
  }

  Future<Map<String, dynamic>> getEnrollmentStatus() async {
    final response = await _dio.get('/enrollment/status');
    return response.data;
  }

  // Attendance endpoints
  Future<List<dynamic>> getAttendanceHistory({
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dio.get('/attendance/history', queryParameters: {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getAttendanceStats() async {
    final response = await _dio.get('/attendance/stats');
    return response.data;
  }

  // Mess endpoints
  Future<List<dynamic>> getMessRecords() async {
    final response = await _dio.get('/mess/records');
    return response.data;
  }

  Future<Map<String, dynamic>> getMessStats() async {
    final response = await _dio.get('/mess/stats');
    return response.data;
  }

  // Leave endpoints
  Future<List<dynamic>> getLeaveRequests() async {
    final response = await _dio.get('/leave/requests');
    return response.data;
  }

  Future<Map<String, dynamic>> createLeaveRequest(Map<String, dynamic> data) async {
    final response = await _dio.post('/leave/requests', data: data);
    return response.data;
  }

  Future<void> cancelLeaveRequest(String requestId) async {
    await _dio.delete('/leave/requests/$requestId');
  }

  // Complaints endpoints
  Future<List<dynamic>> getComplaints() async {
    final response = await _dio.get('/complaints');
    return response.data;
  }

  Future<Map<String, dynamic>> createComplaint(Map<String, dynamic> data) async {
    final response = await _dio.post('/complaints', data: data);
    return response.data;
  }

  // Emergency endpoints
  Future<void> triggerEmergencyAlert(Map<String, dynamic> data) async {
    await _dio.post('/emergency/alert', data: data);
  }

  Future<List<dynamic>> getEmergencyContacts() async {
    final response = await _dio.get('/emergency/contacts');
    return response.data;
  }

  // Parent portal endpoints
  Future<Map<String, dynamic>> getStudentActivity(String studentId) async {
    final response = await _dio.get('/parent/student/$studentId/activity');
    return response.data;
  }

  // Recognition endpoints
  Future<Map<String, dynamic>> recognizeFace(FormData formData) async {
    final response = await _dio.post('/recognition/face-crop', data: formData);
    return response.data;
  }

  Future<List<dynamic>> getUnknownFaces() async {
    final response = await _dio.get('/recognition/unknown-faces');
    return response.data;
  }
}
