// register_services.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://medconnect-one-pi.vercel.app';

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String address,
    required String nationalId,
    required String phone,
    required String licenseNumber,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/api/v1/doctor/register');
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'address': address,
        'national_id': nationalId,
        'phone': phone,
        'license_number': licenseNumber,
      });

      print('🔐 [register_services] register request: ${url.toString()}');
      print('🔐 [register_services] request headers: $headers');
      print('🔐 [register_services] request body: ${jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': '***hidden***',
        'password_confirmation': '***hidden***',
        'address': address,
        'national_id': nationalId,
        'phone': phone,
        'license_number': licenseNumber,
      })}');

      final response = await http.post(url, headers: headers, body: body);
      print('📥 [register_services] response status: ${response.statusCode}');
      print('📥 [register_services] response body: ${response.body}');
      final String rawBody = response.body;
      dynamic responseData;
      try {
        responseData = jsonDecode(rawBody);
      } catch (_) {
        responseData = null;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic data = responseData is Map<String, dynamic> && responseData['data'] is Map<String, dynamic>
            ? responseData['data']
            : responseData;
        final String? profileImageUrl = data is Map<String, dynamic>
            ? (data['profile_image_url']?.toString() ?? data['profile_image']?.toString())
            : null;

        return {
          'success': true,
          'message': responseData['message'] ?? 'Registration successful',
          'data': responseData,
          'profile_Image_Url': profileImageUrl,
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'statusCode': 422,
          'message': responseData['message'] ?? 'Validation failed',
          'errors': responseData['errors'] ?? {},
        };
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        return {
          'success': false,
          'statusCode': 403,
          'error': responseData['error'] ?? 'Registration not permitted',
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': responseData is Map<String, dynamic>
              ? (responseData['message']?.toString() ?? 'Unexpected error')
              : rawBody,
          'errors': responseData is Map<String, dynamic> ? (responseData['errors'] ?? {}) : {},
        };
      }
    } catch (e) {
      print('❌ [register_services] exception: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}