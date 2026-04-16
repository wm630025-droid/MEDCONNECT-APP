import 'dart:convert';
import 'package:http/http.dart' as http;

class PasswordService {
  static Future<Map<String, dynamic>> forgetPassword(String email) async {
    try {
     

      final response = await http.post(
        Uri.parse("https://medconnect-one-pi.vercel.app/api/api/v1/password/forget"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
        }),
      );

      final decoded = jsonDecode(response.body);

      if (decoded['success'] == true) {
        return {
          'success': true,
          'message': decoded['message'],
        };
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Email address not found. please check and try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
     
      final response = await http.post(
        Uri.parse("https://medconnect-one-pi.vercel.app/api/api/v1/otp/verify"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "otp": otp,
        }),
      );

      final decoded = jsonDecode(response.body);
      print('Verify OTP Response Status: ${response.statusCode}');
      print('Verify OTP Response Body: ${response.body}');

      if (decoded['success'] == true) {
        return {
          'success': true,
          'message': decoded['message'],
          'token': decoded['token'] ??  '',
          
        };
      } else {
        return {
          'success': false,
          'message': decoded['error']
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
 static Future<Map<String, dynamic>> resetPassword({
  required String email,
  required String token, // إضافة token
  required String newPassword,
  required String newPasswordConfirmation,
}) async {
  try {
          


    // لا ترسل token في reset password
    final response = await http.post(
      Uri.parse("https://medconnect-one-pi.vercel.app/api/api/v1/password/reset"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",

        // إزالة Authorization header تماماً
      },
      body: ({
        "email": email,
        "password": newPassword,
        "password_confirmation": newPasswordConfirmation,
      }),
    );
    print('Reset Password Response Status: ${response.statusCode}');
    print('Reset Password Response Body: ${response.body}');
    print('Reset Password Response Headers: ${response.headers}');
    
    final decoded = jsonDecode(response.body);
    
    
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded['success'] == true || decoded['message'] != null) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Password reset successfully!',
        };
      } else {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Failed to reset password',
        };
      }
    } else if (response.statusCode == 401) {
      return {
        'success': false,
        'message': 'Unauthenticated.',
      };
    } else if (response.statusCode == 419) {
      return {
        'success': false,
        'message': 'Session expired. Please request a new OTP.',
        'csrf_error': true,
      };
    } else {
      return {
        'success': false,
        'message': decoded['message'] ?? decoded['error'] ?? 'Server error. Please try again.',
      };
    }
  } catch (e) {
    print('Reset Password Error: $e');
    return {
      'success': false,
      'message': 'Network error: ${e.toString()}',
    };
  }
}
}