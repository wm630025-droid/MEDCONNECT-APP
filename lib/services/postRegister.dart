import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  static const String baseUrl = 'https://medconnect-one-pi.vercel.app/api/api/'; // استبدل ده بالـ URL بتاعك

  // دالة التسجيل
  static Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String password,
    required String address,
    required String governorate,
    required String nationalId,
    required String phone,
    required String licenseNumber,
    File? profileImage,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://medconnect-one-pi.vercel.app/api/api/v1/doctor/register'), // عدل المسار حسب API بتاعك
      );

      // إضافة headers
      request.headers.addAll({
        'Accept': 'application/json',
        // 'Content-Type': 'multipart/form-data', // http package بيضيفها تلقائياً
      });

      // إضافة الحقول النصية
      request.fields['full_name'] = 'دكتورة هبة عماد الدين';
      request.fields['email'] = 'hagertestingacc@gmail.com';
      request.fields['password'] = 'P@ssword123';
      request.fields['address'] = 'zagazig';
      request.fields['governorate'] = 'elsharqia';
      request.fields['national_id'] = '28809181234570';
      request.fields['phone'] = '12345678910';
      request.fields['license_number'] = 'LIC-2022-004-CAI';

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
print('\n📥 ========== API RESPONSE ==========');
print('📊 Status Code: ${response.statusCode}');
print('📊 Status Message: ${response.reasonPhrase}');

// طباعة الـ Headers
print('\n📋 Headers:');
response.headers.forEach((key, value) {
  print('   $key: $value');
});

// طباعة الـ Body
print('\n📄 Response Body:');
print('────────────────────────────');

try {
  // محاولة تنسيق الـ JSON بشكل جميل
  var responseData = json.decode(response.body);
  print(JsonEncoder.withIndent('  ').convert(responseData));
  
  // طباعة ملخص سريع
  print('\n📌 Summary:');
  print('   Success: ${responseData['success'] ?? 'N/A'}');
  print('   Message: ${responseData['message'] ?? 'N/A'}');
  
  if (responseData['errors'] != null) {
    print('   Errors: ${responseData['errors']}');
  }
  if (responseData['data'] != null) {
    print('   Data: ${responseData['data']}');
  }
  
} catch (e) {
  // لو مش JSON، اطبع النص العادي
  print(response.body);
}

print('────────────────────────────');
print('🔄 ========== END OF RESPONSE ==========\n');
// ============================================

var responseData = json.decode(response.body);

if (response.statusCode == 200 || response.statusCode == 201) {
  print('✅ SUCCESS: Registration successful'); // رسالة نجاح
  return {
    'success': true,
    'data': responseData,
  };
} else {
  print('❌ ERROR: Registration failed');
  print('   Status Code: ${response.statusCode}');
  print('   Message: ${responseData['message'] ?? 'Unknown error'}');
  
  return {
    'success': false,
    'message': responseData['message'] ?? 'Registration failed',
    'errors': responseData['errors'] ?? {},
  };
}
    } catch (e) {
      print('\n💥 ========== NETWORK ERROR ==========');
  print('❌ Error Type: ${e.runtimeType}');
  print('❌ Error Message: $e');
  print('❌ Stack Trace:');
  print(StackTrace.current);
  print('💥 ====================================\n');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}