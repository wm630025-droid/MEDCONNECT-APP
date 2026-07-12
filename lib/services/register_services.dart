import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class RegisterService {
  static const String baseUrl = 'https://med-connect-backend-ten.vercel.app';
    //    "https://med-connect-backend-ten.vercel.app/api/api/v1/category/doctor/show?per_page=$perPage&page=$page");

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String address,
    required String nationalId,
    required String phone,
    required String licenseNumber,
    XFile? profileImage,
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

      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = responseData['data']?['token'] ?? responseData['token'];
  if (token != null) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
        // ✅ لو في صورة، ارفعها بعد التسجيل
        if (profileImage != null) {
          await updateProfileImage(profileImage);
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'Registration successful',
          'data': responseData,
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
          'message': responseData['message'] ?? 'Unexpected error',
          'errors': responseData['errors'] ?? {},
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> updateProfileImage(XFile imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final uri = Uri.parse('$baseUrl/api/api/v1/doctor/update/image');
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'profile_image_url',
          bytes,
          filename: imageFile.name,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'image_url': data['data']['profile_image_url'],
          'message': data['message'] ?? 'Profile image updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Update failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final uri = Uri.parse('$baseUrl/api/api/v1/doctor/delete/image');
      final response = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'image_url': data['data']['profile_image_url'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Delete failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}