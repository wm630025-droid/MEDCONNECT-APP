import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';



class ApiService {
  static const String baseUrl = 'https://medconnect-one-pi.vercel.app/api/api';
  
  static String? _token;
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    // try {
    //   final response = await http.post(
    //     Uri.parse('$baseUrl/v1/$role/login'),
    //     headers: {
    //       'Accept': 'application/json',
    //       'Content-Type': 'application/json',
    //     },
    //     body: jsonEncode({
    //       'email': email,
    //       'password': password,
    //       'role': role,
    //     }),
    //   );

    //   var data = jsonDecode(response.body);
      
    //   if (response.statusCode == 200) {
    //     // تخزين التوكن
    //     if (data['data'] != null && data['token'] != null) {
    //       await _saveToken(data['token']);
    //       await _saveUserData(data['data']);
    //     }
        
    //     return {
    //       'success': true,
    //       'data': data['data'],
    //     };
    //   } else {
    //     return {
    //       'success': false,
    //       'error': data['error'] ?? 'Sign in is failed',
    //     };
    //   }
    // } catch (e) {
    //   return {
    //     'success': false,
    //     'error': 'خطأ في الاتصال: تأكد من اتصالك بالإنترنت',
    //   };
    // }
     try {
    print('🟢 Login attempt started');
    
    final response = await http.post(
      Uri.parse('$baseUrl/v1/$role/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
    );

    print('📦 Response status: ${response.statusCode}');
    print('📦 Response body: ${response.body}');

    var data = jsonDecode(response.body);
    
    if (response.statusCode == 200) {
      print('✅ Login success - status 200');
      print('📦 Data: ${data['data']}');
      
      // تخزين التوكن
      if (data['data'] != null && data['token'] != null) {
        print('💾 Found token: ${data['token']}');
        await _saveToken(data['token']);
        await _saveUserData(data['data']);
      } else {
        print('❌ Token not found in response!');
        print('🔍 data["data"]: ${data['data']}');
        print('🔍 data["token"]: ${data['token']}');
      }
      
      return {
        'success': true,
        'data': data['data'],
        'message':data['message'],
        'token':data['token']
      };
    } else {
      print('❌ Login failed - status: ${response.statusCode}');
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
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/v1/logout'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      var data = jsonDecode(response.body);
      print("token berfor logout : $_token");
      if (response.statusCode == 200) {
        // ✅ مسح البيانات المحلية
        print("log out sucess from server");
        _token = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_data');
         print("token before log out : $_token");
        
        return {
          'success': true,
          'message': data['message'] ?? 'تم تسجيل الخروج',
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Logout failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }
Future<void> _saveToken(String token) async {
  print('💾 _saveToken called with: $token');
  
  // 1. حفظ في المتغير
  _token = token;
  print('✅ _token after assignment: $_token');
  
  // 2. حفظ في SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
  
  // 3. نتأكد إنه اتحفظ
  String? savedToken = prefs.getString('auth_token');
  print('✅ Token saved to SharedPreferences: $savedToken');
  
  // 4. نحمله تاني نتأكد
  _token = savedToken;
  print('✅ _token after reload: $_token');
}
  // Future<void> _saveToken(String token) async {
  //   print("save token : $_token");
  //   _token = token;
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('auth_token', token);
  // }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    print("loadtoken : $_token");
  }

   static Future<Map<String, dynamic>?> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user_data');
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }


  static String? get token => _token;
  static bool get isLoggedIn => _token != null;
}