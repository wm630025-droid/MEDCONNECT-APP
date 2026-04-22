 
 import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

 class GetDoctorProfile {
   
 
 static Future<Map<String, dynamic>> doctorProfile() async {
     const String baseUrl = 'https://medconnect-one-pi.vercel.app/api/api/'; // استبدل ده بالـ URL بتاعك

  try {
    // 🔥 نجيب التوكن
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); // تأكد من استخدام نفس المفتاح اللي خزنت فيه التوكن

    if (token == null) {
      return {
        'success': false,
        'message': 'No token found',
      };
    }

    print('🟢 Fetching doctor profile...');

    final response = await http.get(
      Uri.parse('${baseUrl}v1/doctor/profile'), // عدل لو endpoint مختلف
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // 🔥 أهم سطر
      },
    );

    print('📦 Status Code: ${response.statusCode}');
    print('📦 Body: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': data['data'],
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to load profile',
      };
    }
  } catch (e) {
    print('❌ Exception: $e');
    return {
      'success': false,
      'message': 'Error: $e',
    };
  }
  
}
 

 static Future<Map<String, dynamic>> updateAddress(String newAddress) async {
  try {
     final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); // تأكد من استخدام نفس المفتاح اللي خزنت فيه التوكن

    if (token == null) {
      return {
        'success': false,
        'message': 'No token found',
      };
    }
    final response = await http.post(
      Uri.parse("https://medconnect-one-pi.vercel.app/api/api/v1/doctor/update/address"), 
      // 👈 غير اللينك
      headers: {
        "Accept": "application/json",
        "content-type": "application/json",
        "Authorization": "Bearer $token", // تأكد من أنك جلبت التوكن بشكل صحيح
      },
      body: jsonEncode({
        "address": newAddress,
      }),
    );

    print(response.body); // 👈 للتأكد

    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      print("✅ Address Updated");
      return {
        'success': true,
        'message': 'Address updated successfully',
      };
    } else {
      print("❌ Failed: ${data['message']}");
      return {
        'success': false,
        'message': data['message'] ?? 'Failed to update address',
      };
    }
  } catch (e) {
    print("🔥 Error: $e");
    return {
      'success': false,
      'message': 'Error: $e',
    };
  }
}
 }