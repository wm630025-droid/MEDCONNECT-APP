//pubspec.lock  row 488 i delete
// typed_data:
// dependency: transitive
// description:
//   name: typed_data
//   sha256: f9049c039ebfeb4cf7a7104a675823cd72dba8297f264b6637062516699fa006
//   url: "https://pub.dev"
// source: hosted
// version: "1.4.0"

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medconnect_app/models/category.dart';
import 'package:medconnect_app/models/custom_request_model.dart';
import 'package:medconnect_app/models/offer_request.dart';
import 'package:medconnect_app/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://medconnect-one-pi.vercel.app/api/api';

  static String? _token;
//static Map<String, dynamic>? _cachedSupplierData;
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
        body: jsonEncode({'email': email, 'password': password, 'role': role}),
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
          'message': data['message'],
          'token': data['token'],
        };
      } else {
        print('❌ Login failed - status: ${response.statusCode}');
        return {'success': false, 'error': data['error'] ?? 'فشل تسجيل الدخول'};
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
      if (response.statusCode == 200 || response.statusCode == 401) {
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
        return {'success': false, 'error': data['message'] ?? 'Logout failed'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  //##################################
  // ------------------- Fetch Categories (Doctor) -------------------
  Future<List<Category>> fetchCategories({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      // ✅ التأكد من وجود التوكن
      if (_token == null) {
        throw Exception('Please login first to view categories');
      }

      final uri = Uri.parse('$baseUrl/v1/category/doctor/show').replace(
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );

      print('🌐 Fetching categories: $uri');
      print('🔑 Token: $_token');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('📦 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        if (data['success'] == true) {
          List<Category> categories = (data['data'] as List)
              .map((json) => Category.fromJson(json))
              .toList();

          print('✅ Loaded ${categories.length} categories');
          return categories;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch categories');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
      throw Exception('Error loading categories: $e');
    }
  }

  //##################################
  // ------------------- Fetch Products -------------------
  // في api_service.dart
  Future<Map<String, dynamic>> fetchProductsWithPagination({
    int page = 1,
    int perPage = 2,
  }) async {
    try {
      if (_token == null) {
        print('❌ No token found!');
        throw Exception('Please login first');
      }
      print('🔑 Token exists: ${_token?.substring(0, 20)}...');
      final uri = Uri.parse('$baseUrl/v1/product/doctor/show').replace(
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
          'sort_by': 'id',
          'sort_order': 'asc',
        },
      );
      print('🌐 ========== FETCHING PRODUCTS ==========');
      print('📡 URL: $uri');
      print('📄 Page: $page, Per Page: $perPage');
      print('🔐 Token: ${_token?.substring(0, 20)}...');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body Length: ${response.body.length} chars');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('resonse body ${response.body}');
        print('✅ Success flag: ${data['success']}');
        print('📊 Total products in DB: ${data['total']}');
        print('📄 Last page: ${data['last_page']}');
        print('📦 Products in this page: ${data['data']?.length ?? 0}');

        if (data['success'] == true) {
          List<Product> products = (data['data'] as List)
              .map((json) => Product.fromJson(json))
              .toList();

          print('✅ Loaded ${products.length} products from page $page');
          print('🏷️ Product names: ${products.map((p) => p.name).join(', ')}');
          print('=====================================');

          return {
            'products': products,
            
            'lastPage': data['last_page'] ?? 1,
            'total': data['total'] ?? 0,
            'perPage': 2,
          };
        } else {
          print('❌ API returned success=false: ${data['message']}');
          throw Exception(data['message'] ?? 'Failed to fetch products');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('📦 Response body: ${response.body}');
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching products: $e');
      throw Exception('Error loading products: $e');
    }
  }
  //###################################
  // ------------------- Fetch Product By ID -------------------
Future<Product> fetchProductById(int productId) async {
  try {
    if (_token == null) {
      throw Exception('Please login first');
    }

    final uri = Uri.parse('$baseUrl/v1/product/doctor/show/$productId');
    print('🌐 Fetching product details: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    print('📦 Product Details Response status: ${response.statusCode}');
    print('📦 Product Details Response body: ${response.body}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        return Product.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch product details');
      }
    } else if (response.statusCode == 401) {
      throw 'Session expired. Please login again.';
    } else if (response.statusCode == 404) {
      throw 'Product not found';
    } else {
      throw 'HTTP Error: ${response.statusCode}';
    }
  } catch (e) {
    print('❌ Error fetching product details: $e');
    throw 'Error loading product: $e';
  }
}


// ------------------- Fetch Products by Supplier ID -------------------
Future<Map<String, dynamic>> fetchProductsBySupplierId({
  required int supplierId,
  int page = 1,
  int perPage = 10,
}) async {
  try {
       print('🔵 fetchProductsBySupplierId called - supplierId: $supplierId, page: $page');
    if (_token == null) {
      print('❌ No token found for supplier products');
      throw 'Please login first';
      
    }

    final uri = Uri.parse('$baseUrl/v1/product/supplier-profile/show/$supplierId')
        .replace(queryParameters: {
      'page': page.toString(),
      'per_page': perPage.toString(),
    });

    print('🌐 Fetching products for supplier $supplierId: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    print('📦 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
       print('✅ Supplier products API success: ${data['success']}');
        print('📊 Total: ${data['total']}');
        print('📄 Last page: ${data['last_page']}');
        print('📄 Current page: $page');
      if (data['success'] == true) {
        List<Product> products = (data['data'] as List)
            .map((json) => Product.fromJson(json))
            .toList();
           // print("supplier response body: ${response.body}");
         print('✅ Loaded ${products.length} products for supplier $supplierId');
           print('🔍 Supplier data from API: ${data['data']?.first?['supplier']}');
        // استخراج بيانات المورد من أول منتج (لو موجود)
        // if (products.isNotEmpty && products.first.supplierData != null) {
        //   _cachedSupplierData = products.first.supplierData;
        
      //     print('✅ Cached supplier data: ${_cachedSupplierData?['company_name']}');
      // //  }
        
        return {
          'products': products,
          'lastPage': data['last_page'] ?? 1,
          'total': data['total'] ?? 0,
          'perPage': data['per_page'] ?? perPage,
        };
      } else {
        throw data['message'] ?? 'Failed to fetch supplier products';
      }
    } else if (response.statusCode == 401) {
      throw 'Session expired. Please login again.';
    } else if (response.statusCode == 404) {
        print('❌ Supplier not found: $supplierId');
      throw 'Supplier not found';
    } else {
        print('❌ Supplier products HTTP error: ${response.statusCode}');
      throw 'HTTP Error: ${response.statusCode}';
    }
  } catch (e) {
    print('❌ Error fetching supplier products: $e');
    throw 'Error loading supplier products: $e';
  }
}


//#################################
// في lib/services/api_service.dart

// ------------------- Create Custom Request -------------------
// Future<Map<String, dynamic>> createCustomRequest(CustomRequestModel request) async {
//   try {
//     if (_token == null) throw Exception('Please login first');

//     final response = await http.post(
//       Uri.parse('$baseUrl/v1/customRequest/create'),
//       headers: {
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $_token',
//         'Content-Type': 'application/json',
//       },
//       body: jsonEncode(request.toJson()),
//     );

//     print('📦 Create Custom Request Response: ${response.body}');

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to createxxxxxxxxxxx custom request');
//     }
//   } catch (e) {
//     print('❌ Error creating custom request: $e');
//     throw Exception('Error: $e');
//   }
// }
Future<CustomRequest> createCustomRequest(CustomRequest request) async {
  try {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print("Token : $_token");

      if (_token == null || _token!.isEmpty) {
      print('❌ No token found! Please login again.');
      throw Exception('No authentication token. Please login again.');
    }
    if (_token == null) throw 'Please login first';
 
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📤 [CREATE CUSTOM REQUEST] Sending request');
    print('📦 Request Body: ${jsonEncode(request.toJson())}');

    final response = await http.post(
      Uri.parse('$baseUrl/v1/customRequest/create'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('✅ Custom request created successfully!');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      // ✅ الـ Response ممكن يرجع نفس الـ data أو data['data']
      if (data['data'] != null) {
        return CustomRequest.fromJson(data['data']);
      }
      return CustomRequest.fromJson(data);
    } else if (response.statusCode == 401) {
      throw 'Session expired. Please login again.';
    }
    // else if (response.statusCode == 422) {
    //   throw 'Rental end date must by after or equal expired date.';
    // }
     else {
      throw 'Failed to create custom request';
    }
  } catch (e) {
    print('❌22 Error: $e');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    throw 'Error :';
  }
}
// ------------------- Get Custom Requests -------------------
// Future<Map<String, dynamic>> getCustomRequests({
//   int page = 1,
//   int perPage = 15,
//   String status = 'open', // open, applied, cancelled, expired, all
// }) async {
//   try {
//     if (_token == null) throw Exception('Please login first');

//     final uri = Uri.parse('$baseUrl/v1/customRequest/doctor/show').replace(queryParameters: {
//       'page': page.toString(),
//       'per_page': perPage.toString(),
//       'status': status,
//     });

//     final response = await http.get(
//       uri,
//       headers: {
//         'Accept': 'application/json',
//         'Authorization': 'Bearer $_token',
//       },
//     );

//     print('📦 Get Custom Requests Response: ${response.body}');

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to fetch custom requests');
//     }
//   } catch (e) {
//     print('❌ Error fetching custom requests: $e');
//     throw Exception('Error: $e');
//   }
// }
Future<List<CustomRequest>> getCustomRequests({
  int page = 1,
  int perPage = 15,
  String status = 'open',
}) async {
  try {
    
    if (_token == null) throw Exception('Please login first');
   
    final uri = Uri.parse('$baseUrl/v1/customRequest/doctor/show').replace(queryParameters: {
      'page': page.toString(),
      'per_page': perPage.toString(),
      'status': status,
    });

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📤 [GET CUSTOM REQUESTS] URL: $uri');


    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data['success'] == true) {
        final List<dynamic> requestsData = data['data'];
        final requests = requestsData.map((json) => CustomRequest.fromJson(json)).toList();
        
        print('✅ Loaded ${requests.length} custom requests');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return requests;
      } else {
        throw data['message'] ?? 'Failed to fetch requests';
      }

    } else if (response.statusCode == 401) {
      throw 'Session expired. Please login again.';
    }
     else {
      throw 'Failed to fetch custom requests';
    }
  } catch (e) {
    print('❌ EError: $e');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    if(e is Exception){
    throw e.toString().replaceAll('Exeption', '').trim();
    }
    rethrow;
  }
}



// ------------------- Cancel Custom Request -------------------
Future<Map<String, dynamic>> cancelCustomRequest(int requestId) async {
  try {
    if (_token == null) throw Exception('Please login first');

    final response = await http.post(
      Uri.parse('$baseUrl/v1/customRequest/cancel/$requestId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    print('📦 Cancel Request Response (${response.statusCode}): ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw data['error'] ?? 'Failed to cancel request';
    }
  } catch (e) {
    print('❌ Error cancelling request: $e');
    throw 'Error: $e';
  }
}

// ------------------- Delete Custom Request -------------------
Future<Map<String, dynamic>> deleteCustomRequest(int requestId) async {
  try {
    if (_token == null) throw Exception('Please login first');

    final response = await http.delete(
      Uri.parse('$baseUrl/v1/customRequest/delete/$requestId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    print('📦 Delete Request Response (${response.statusCode}): ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);
      throw data['error'] ?? 'Failed to delete request';
    }
  } catch (e) {
    print('❌ Error deleting request: $e');
    throw 'Error: $e';
  }
}

// ------------------- Get Offer Requests by Custom Request ID -------------------
Future<List<OfferRequest>> getOfferRequests(int customRequestId) async {
  try {
    if (_token == null) throw Exception('Please login first');

    final response = await http.get(
      Uri.parse('$baseUrl/v1/offerRequest/doctor/show/$customRequestId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
      },
    );

    print('📦 Offer Requests Response (${response.statusCode}): ${response.body}');
String cleanBody = response.body;
    
    // لو في حروف قبل {، نشيلهم
    final startIndex = cleanBody.indexOf('{');
    if (startIndex > 0) {
      cleanBody = cleanBody.substring(startIndex);
      print('🧹 Cleaned Response Body: $cleanBody');
    }

    final data = jsonDecode(cleanBody);
    
    print('📦 Offer Requests Response (${response.statusCode}): $data');
    if (response.statusCode == 200) {
     // final data = jsonDecode(response.body);
     

      if (data['success'] == true) {
         List<dynamic> offersData = [];
      if (data['data'] is List) {
          offersData = data['data'];
        } else if (data['data'] is Map && data['data'].containsKey('id')) {
          // لو كانت { "id": [] }، نعتبرها قائمة فاضية
          offersData = [];
        } else if (data['data'] is Map) {
          // لو كانت Object عادي (مش قائمة)
          offersData = [data['data']];
        }
        
        return offersData.map((json) => OfferRequest.fromJson(json)).toList();
      } else {
        throw data['message'] ?? 'Failed to fetch offers';
      }
    } else {
      throw 'Failed to fetch offers';
    }
  } catch (e) {
    print('❌ Error fetching offers: $e');
    throw 'Error: $e';
  }
}
//##################################
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
