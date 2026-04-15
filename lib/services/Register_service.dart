import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  static const String baseUrl = 'https://medconnect-one-pi.vercel.app/api/api/'; // استبدل ده بالـ URL بتاعك

  // دالة التسجيل
  static Future<Map<String, dynamic>> signUp({
    required String fullname,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String address,
    required String governorate,
    required String nationalId,
    required String phone,
    required String licenseNumber,
    required String specialty,
    File? profileImage,
  }) async {
    try {
       print('🟢 sign up attempt started');
       
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://medconnect-one-pi.vercel.app/api/api/v1/doctor/register'), // عدل المسار حسب API بتاعك
      );

      // إضافة headers
      request.headers.addAll({
        'Accept': 'application/json',
         'Content-Type': 'multipart/form-data', // http package بيضيفها تلقائياً
      });

      // إضافة الحقول النصية
      request.fields['fullname'] = fullname;
      request.fields['email'] = email;
      request.fields['password'] = password;
      request.fields['password_confirmation'] = passwordConfirmation;
      request.fields['address'] = address;
      request.fields['governorate'] = governorate;
      request.fields['nationalId'] = nationalId;
      request.fields['phone'] = phone;
      request.fields['license_number'] = licenseNumber;
      request.fields['specialty'] = specialty;

      // إضافة الصورة لو موجودة
      if (profileImage != null) {
        var mimeType = lookupMimeType(profileImage.path) ?? 'image/jpeg';
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image', // اسم الحقل اللي بيستقبل الصورة في الـ API
            profileImage.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      // إرسال الطلب
      var streamedResponse = await request.send();
var response = await http.Response.fromStream(streamedResponse);

// ========== طباعة الـ Response بالكامل ==========

print('📦 Response status: ${response.statusCode}');
   print('📤 Sending Form Data:');
request.fields.forEach((key, value) {
  print('➡️ $key: $value');
});

      var data = jsonDecode(response.body);    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ signUP success - status 200');
      print('📦 Data: ${data['data']}');
      return {
        'success': true,
        'data': data['data'],
      };
    }  else if (response.statusCode == 422) {
        Map<String, dynamic> fieldErrors = {};
        data['errors'].forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            fieldErrors[key] = value[0]; // ناخد أول رسالة فقط
          } else if (value is String && value.isNotEmpty) {
            fieldErrors[key] = value; // لو رجع String مباشر
          }
        });
      
      return {
        'success': false,
        'errors': fieldErrors,
      };
    }
      else {
      print('❌ sign up failed - status: ${response.statusCode}');
      print("Registration not permitted. Please check your license details.");
      return {
        'success': false,
        'error': data['error'] ?? 'فشل تسجيل الدخول',
      };
    }
    
  } catch (e) {
    print('❌ Exception: $e');
    return {
      'success': false,
      'error': 'خطأ في الاتصال: تأكد من اتصالك بالإنترنت',
    };
  }
  }
 
}

// طباعة الـ Headers
